import Quickshell
import Quickshell.Services.SystemTray
import QtQuick

Row {
    spacing: 5
    anchors.verticalCenter: parent.verticalCenter
    
    TrayMenu {
        id: connectedMenu
    }

    add: Transition {
        NumberAnimation { properties: "scale"; from: 0; to: 1; duration: 300; easing.type: Easing.OutBack }
    }
    move: Transition {
        NumberAnimation { properties: "x"; duration: 300; easing.type: Easing.OutQuad }
    }

    Repeater {
        model: SystemTray.items
        
        Image {
            id: trayIcon
            width: 20
            height: 20
            source: modelData.icon 
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        if (connectedMenu.visible && connectedMenu.activeEntry === modelData) {
                            connectedMenu.close();
                        } else {
                            let pos = trayIcon.mapToGlobal(trayIcon.width / 2, 0);
                            connectedMenu.open(pos.x, modelData);
                        }
                    } else {
                        modelData.activate();
                    }
                }
            }
        }
    }
}