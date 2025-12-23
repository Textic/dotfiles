import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

PanelWindow {
    id: root

    WlrLayershell.namespace: "tray-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    
    color: "transparent"

    property int targetX: 0
    property var activeEntry: null

    function open(globalX, entry) {
        targetX = globalX
        activeEntry = entry
        root.visible = true
    }

    function close() {
        root.visible = false
        activeEntry = null
    }

    visible: false

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons 
        onClicked: root.close()
        onWheel: root.close()
    }

    Rectangle {
        id: menuBox
        x: Math.max(10, Math.min(root.width - width - 10, root.targetX - (width / 2)))
        y: 0
        
        width: 200
        height: menuList.implicitHeight + 20 
        
        color: "#313244"
        radius: 15
        
        Rectangle {
            width: 40; height: 15; color: parent.color
            anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: (mouse) => mouse.accepted = true // No hacer nada, solo consumir el evento
        }

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
        opacity: root.visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Column {
            id: menuList
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 15
            
            QsMenuOpener {
                id: menuOpener
                menu: root.activeEntry?.menu ?? null
            }

            Repeater {
                model: menuOpener.children

                Rectangle {
                    width: parent.width - 20
                    height: modelData.isSeparator ? 10 : 30
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "transparent"
                    
                    Rectangle {
                        visible: modelData.isSeparator
                        width: parent.width; height: 1; color: "#585b70"
                        anchors.centerIn: parent
                    }

                    Text {
                        visible: !modelData.isSeparator
                        text: modelData.text
                        color: "white"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        elide: Text.ElideRight
                        width: parent.width - 20
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !modelData.isSeparator
                        
                        onEntered: parent.color = "#45475a"
                        onExited: parent.color = "transparent"
                        
                        onClicked: {
                            modelData.triggered()
                            root.close()
                        }
                    }
                    radius: 5
                }
            }
        }
    }
}