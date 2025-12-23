import Quickshell
import Quickshell.Hyprland
import QtQuick

Rectangle {
    id: root
    
    color: "#313244"
    radius: 15
    height: 30
    width: row.width + 10

    anchors.verticalCenter: parent.verticalCenter

    property var occupied: Hyprland.workspaces.values.reduce((acc, curr) => {
        acc[curr.id] = curr.windows > 0;
        return acc;
    }, {})

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: 5

            Text {
                property int wsId: index + 1
                property bool isActive: Hyprland.focusedWorkspace.id === wsId
                property bool isOccupied: root.occupied[wsId] ?? false

                text: isActive ? "" : (isOccupied ? "" : "") 
                color: isActive ? "#fab387" : (isOccupied ? "#f38ba8" : "#585b70")
                font.family: "Material Symbols Rounded"
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