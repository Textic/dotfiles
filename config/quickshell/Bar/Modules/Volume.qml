import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Row {
    id: root
    spacing: 5

    // 1. Get the default Sink
    property var audioSink: Pipewire.defaultAudioSink

    // 2. [CRITICAL SOLUTION] Object Tracker
    // This was what was missing. Without this, the Sink remains "unbound" (disconnected)
    // and that's why it errors when trying to change volume and returns 0% when reading it.
    PwObjectTracker {
        // We tell Quickshell: "Keep this object alive and updated"
        objects: root.audioSink ? [root.audioSink] : []
    }

    // 3. Safe reading logic
    function getSafeVolume() {
        if (!audioSink || !audioSink.audio) return 0;
        return audioSink.audio.volume ?? 0;
    }

    property real vol: getSafeVolume()
    
    property bool isMuted: {
        if (!audioSink || !audioSink.audio) return true;
        return audioSink.audio.muted ?? true;
    }

    // 4. Icon and visual logic
    function getVolumeIcon(volume, muted) {
        if (muted) return "no_sound";
        if (volume >= 0.5) return "volume_up";
        if (volume > 0) return "volume_down";
        return "volume_mute";
    }

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        
        text: root.getVolumeIcon(root.vol, root.isMuted)
        color: root.isMuted ? "#a6adc8" : "white" 
        font.pixelSize: 22

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            
            // Click: Mute / Unmute
            onClicked: {
                if (root.audioSink && root.audioSink.audio) {
                    // Now that we have the Tracker, this should work without "unbound" error
                    root.audioSink.audio.muted = !root.isMuted
                }
            }

            // Wheel: Increase / Decrease volume
            onWheel: (wheel) => {
                if (root.audioSink && root.audioSink.audio) {
                    var step = 0.05
                    var current = root.getSafeVolume()
                    var newVol = current + (wheel.angleDelta.y > 0 ? step : -step)
                    
                    if (newVol < 0) newVol = 0
                    if (newVol > 1.5) newVol = 1.5
                    
                    root.audioSink.audio.volume = newVol
                    
                    // If volume is increased, automatically unmute
                    if (wheel.angleDelta.y > 0 && root.isMuted) {
                        root.audioSink.audio.muted = false
                    }
                }
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        
        text: Math.round(root.vol * 100) + "%"
        visible: !root.isMuted
        color: "white"
        font.family: "Lexend"
        font.bold: true
        font.pixelSize: 14
    }
    
    // Debug to confirm it is now "bound" (connected)
    onAudioSinkChanged: {
        if (audioSink) console.log("[Volume] Sink connected and tracked:", audioSink.description)
    }
}