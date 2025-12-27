import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../.."

Rectangle {
    id: root
    
    // color: Colours.palette.m3surfaceContainer
    color: "transparent"
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
                property bool isActive: Hyprland.focusedWorkspace?.id === wsId ?? false
                property bool isOccupied: root.occupied[wsId] ?? false

                text: isActive ? "" : (isOccupied ? "" : "") 
                color: isActive ? Colours.m3primary : (isOccupied ? Colours.m3secondary : Colours.m3outline) // test
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