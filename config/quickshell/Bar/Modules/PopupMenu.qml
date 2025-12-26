import Quickshell
import QtQuick

PopupWindow {
    id: root

    // Propiedades visuales
    property color backgroundColor: "#1e1e2e"
    property int cornerRadius: 15
    
    // Esta línea permite que cuando uses PopupMenu { Text {} }, el texto vaya al lugar correcto
    default property alias content: innerContent.data

    // Configuración de la ventana
    dim: false
    modal: true // Cierra el popup si haces click fuera
    
    // Anclaje al padre (el botón de la barra)
    anchor.window: parent
    anchor.on: Anchor.Bottom
    anchor.rect: Anchor.Center

    // --- CORRECCIÓN ---
    // Quitamos "body:" y dejamos el Item directamente aquí
    Item {
        id: container
        
        // El Item calcula su tamaño basado en el contenido (innerContent)
        width: innerContent.childrenRect.width
        height: innerContent.childrenRect.height

        // --- ANIMACIONES ---
        transform: Translate {
            id: trans
            y: -10
        }
        
        opacity: 0
        scale: 0.9

        Component.onCompleted: animIn.start()
        
        ParallelAnimation {
            id: animIn
            NumberAnimation { target: container; property: "opacity"; to: 1; duration: 200; easing.type: Easing.OutQuad }
            NumberAnimation { target: container; property: "scale"; to: 1; duration: 300; easing.type: Easing.OutBack }
            NumberAnimation { target: trans; property: "y"; to: 0; duration: 300; easing.type: Easing.OutQuad }
        }

        // --- ESTRUCTURA VISUAL ---
        
        // 1. Esquinas Invertidas (Conectores)
        ReverseCorner {
            type: ReverseCorner.CornerType.TopLeft
            color: root.backgroundColor
            anchors.right: mainRect.left
            anchors.top: mainRect.top
        }

        ReverseCorner {
            type: ReverseCorner.CornerType.TopRight
            color: root.backgroundColor
            anchors.left: mainRect.right
            anchors.top: mainRect.top
        }

        // 2. Fondo Principal
        Rectangle {
            id: mainRect
            anchors.fill: innerContent
            color: root.backgroundColor
            radius: root.cornerRadius
            
            // Parche para esquinas superiores planas
            Rectangle {
                width: parent.width
                height: parent.radius
                color: parent.color
                anchors.top: parent.top
            }
        }

        // 3. Contenedor de los Items
        Column {
            id: innerContent
            padding: 15
            spacing: 10
        }
    }
}