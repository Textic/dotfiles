import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import "../.."

Row {
    id: root
    spacing: 0

    property var menuRef: null

    property var audioSink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: root.audioSink ? [root.audioSink] : [] }

    function getSafeVolume() {
        if (!audioSink || !audioSink.audio) return 0;
        return audioSink.audio.volume ?? 0;
    }
    property real vol: getSafeVolume()
    property bool isMuted: audioSink?.audio?.muted ?? true

    property bool showText: false
    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.showText = false
    }
    
    onVolChanged: { 
        root.showText = true; 
        hideTimer.restart() 
    }
    
    function changeVolume(delta) {
        if (root.audioSink?.audio) {
            var step = 0.05
            var newVol = root.vol + (delta > 0 ? step : -step)
            root.audioSink.audio.volume = Math.max(0, Math.min(1.5, newVol))
            if (delta > 0 && root.isMuted) root.audioSink.audio.muted = false
            root.showText = true; hideTimer.restart()
        }
    }

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        text: {
            if (root.isMuted) return "no_sound";
            if (root.vol >= 0.5) return "volume_up";
            if (root.vol > 0) return "volume_down";
            return "volume_mute";
        }
        color: root.isMuted ? Colours.palette.m3surfaceContainerHigh : Colours.foreground
        font.pixelSize: 22

        MouseArea {
            id: interactArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    if (root.menuRef) {
                        let pos = interactArea.mapToGlobal(interactArea.width / 2, 0);
                        root.menuRef.open(pos.x, "volume", root.audioSink);
                    }
                } else {
                    if (root.audioSink?.audio) root.audioSink.audio.muted = !root.isMuted
                }
            }
            onWheel: (wheel) => root.changeVolume(wheel.angleDelta.y)
        }
    }

    Item {
        id: textContainer
        anchors.verticalCenter: parent.verticalCenter
        height: 24
        
        property bool revealed: !root.isMuted && (root.showText || textMouseArea.containsMouse)
        property real targetWidth: revealed ? (volText.implicitWidth + 10) : 0
        
        width: targetWidth
        clip: true

        // Smooth animation
        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
        
        // Opacity animation
        opacity: revealed ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Text {
            id: volText
            
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
            
            text: Math.round(root.vol * 100) + "%"
            color: Colours.foreground
            font.family: "Lexend"
            font.bold: true
            font.pixelSize: 14
        }
        
        MouseArea {
            id: textMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onWheel: (wheel) => root.changeVolume(wheel.angleDelta.y)
        }
    }
}