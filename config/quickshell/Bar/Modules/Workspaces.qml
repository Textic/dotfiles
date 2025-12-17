import Quickshell
import Quickshell.Hyprland
import QtQuick

Rectangle {
    id: root
    
    // ESTILO DE LA CÁPSULA
    color: "#313244"        // Fondo grisáceo
    radius: 15              // Bordes redondeados
    height: 30              // Altura fija
    width: row.width + 20   // El ancho se ajusta al contenido automáticamente

    anchors.verticalCenter: parent.verticalCenter

    // Lógica para detectar ventanas
    property var occupied: Hyprland.workspaces.values.reduce((acc, curr) => {
        acc[curr.id] = curr.windows > 0;
        return acc;
    }, {})

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: 5 // Cantidad de workspaces a mostrar

            Text {
                property int wsId: index + 1
                property bool isActive: Hyprland.focusedWorkspace.id === wsId
                property bool isOccupied: root.occupied[wsId] ?? false

                text: isActive ? "" : (isOccupied ? "" : "") 
                color: isActive ? "#fab387" : (isOccupied ? "#f38ba8" : "#585b70")
                font.family: "Material Symbols Rounded" // Asegúrate de tener esta fuente o usa otra
                font.pixelSize: 13
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + parent.wsId)
                }
            }
        }
    }
}