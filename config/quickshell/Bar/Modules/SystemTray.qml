import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Row {
    spacing: 5
    anchors.verticalCenter: parent.verticalCenter

    add: Transition {
        NumberAnimation { 
            properties: "scale"; from: 0; to: 1; duration: 300; easing.type: Easing.OutBack 
        }
    }
    move: Transition {
        NumberAnimation { 
            properties: "x"; duration: 300; easing.type: Easing.OutQuad 
        }
    }

    Repeater {
        model: SystemTray.items
        Image {
            width: 20
            height: 20
            
            source: modelData.icon 
            fillMode: Image.PreserveAspectFit

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: modelData.menu.display() 
            }
        }
    }
}
