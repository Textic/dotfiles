import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import "../"

Item {
    id: root

    property var menuRef: null
    
    implicitHeight: innerRow.implicitHeight
    
    implicitWidth: innerRow.implicitWidth
    anchors.verticalCenter: parent.verticalCenter
    width: implicitWidth

    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

    clip: true

    Row {
        id: innerRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left 
        spacing: 5

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
                        if (root.menuRef.visible && root.menuRef.activeData === modelData) {
                            root.menuRef.close();
                        } else {
                            let pos = trayIcon.mapToGlobal(trayIcon.width / 2, 0);
                            root.menuRef.open(pos.x, "tray", modelData);
                        }
                    }
                }
            }
        }
    }
}