import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Row {
    id: root
    spacing: 5

    property var audioSink: Pipewire.defaultAudioSink

    // Lectura segura: Verificamos si existe, si tiene audio y asignamos un valor por defecto
    property real vol: (audioSink && audioSink.audio) ? audioSink.audio.volume : 0
    property bool isMuted: (audioSink && audioSink.audio) ? audioSink.audio.muted : true
    
    // Propiedad auxiliar para saber si es seguro interactuar
    property bool isReady: audioSink && audioSink.ready

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
            
            onClicked: {
                // SOLO actuamos si el dispositivo está 'ready'
                if (root.isReady && root.audioSink.audio) {
                    root.audioSink.audio.muted = !root.isMuted
                }
            }

            onWheel: (wheel) => {
                // SOLO actuamos si el dispositivo está 'ready'
                if (root.isReady && root.audioSink.audio) {
                    var step = 0.05
                    var newVol = root.vol + (wheel.angleDelta.y > 0 ? step : -step)
                    
                    if (newVol < 0) newVol = 0
                    if (newVol > 1.5) newVol = 1.5
                    
                    root.audioSink.audio.volume = newVol
                    if (wheel.angleDelta.y > 0) root.audioSink.audio.muted = false
                }
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        
        // Texto seguro: Si no está listo, mostramos "..." o "0%" sin romper nada
        text: {
            if (!root.isReady) return "...";
            return Math.round(root.vol * 100) + "%"
        }
        
        visible: !root.isMuted
        color: "white"
        font.family: "Lexend"
        font.bold: true
        font.pixelSize: 14
    }
}