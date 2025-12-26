import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Row {
    id: root
    spacing: 5

    // 1. Obtenemos el Sink por defecto
    property var audioSink: Pipewire.defaultAudioSink

    // 2. [SOLUCIÓN CRÍTICA] Tracker de Objetos
    // Esto es lo que faltaba. Sin esto, el Sink se queda "unbound" (desconectado)
    // y por eso da error al intentar cambiar el volumen y devuelve 0% al leerlo.
    PwObjectTracker {
        // Le decimos a Quickshell: "Mantén este objeto vivo y actualizado"
        objects: root.audioSink ? [root.audioSink] : []
    }

    // 3. Lógica segura de lectura
    function getSafeVolume() {
        if (!audioSink || !audioSink.audio) return 0;
        return audioSink.audio.volume ?? 0;
    }

    property real vol: getSafeVolume()
    
    property bool isMuted: {
        if (!audioSink || !audioSink.audio) return true;
        return audioSink.audio.muted ?? true;
    }

    // 4. Icono y lógica visual
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
                    // Ahora que tenemos el Tracker, esto debería funcionar sin error "unbound"
                    root.audioSink.audio.muted = !root.isMuted
                }
            }

            // Rueda: Subir / Bajar volumen
            onWheel: (wheel) => {
                if (root.audioSink && root.audioSink.audio) {
                    var step = 0.05
                    var current = root.getSafeVolume()
                    var newVol = current + (wheel.angleDelta.y > 0 ? step : -step)
                    
                    if (newVol < 0) newVol = 0
                    if (newVol > 1.5) newVol = 1.5
                    
                    root.audioSink.audio.volume = newVol
                    
                    // Si subes volumen, quitar mute automáticamente
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
    
    // Debug para confirmar que ahora sí está "bound" (conectado)
    onAudioSinkChanged: {
        if (audioSink) console.log("[Volume] Sink conectado y rastreado:", audioSink.description)
    }
}