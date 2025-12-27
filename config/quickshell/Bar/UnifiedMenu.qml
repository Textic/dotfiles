import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import "./Modules"
import ".."

PanelWindow {
    id: root

    WlrLayershell.namespace: "unified-menu"
    WlrLayershell.layer: WlrLayer.Overlay

	screen: root.screen
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"

    property int targetX: 0
    property string activeType: "" 
    property var activeData: null

    Item {
        id: screenCanvas
        anchors.fill: parent
    }

    Timer {
        id: layoutTimer
        interval: 10
        onTriggered: menuBox.state = "visible"
    }

    function open(globalX, type, data) {
		let localPos = screenCanvas.mapFromGlobal(globalX, 0);
        targetX = localPos.x
        activeType = type
        activeData = data

        console.log("[UnifiedMenu] Global X:", globalX, " -> Local X:", localPos.x)

        if (!root.visible) {
            root.visible = true
            menuBox.state = "hidden"
            layoutTimer.restart()
        }
    }

    function close() {
        menuBox.state = "hidden"
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
        
        width: contentLoader.implicitWidth
        height: contentLoader.implicitHeight + 20
        
        color: Colours.background
        radius: 20

        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }

        state: "hidden"

        states: [
            State {
                name: "visible"
                PropertyChanges { target: menuBox; y: 0 }
            },
            State {
                name: "hidden"
                PropertyChanges { target: menuBox; y: -menuBox.height - 20 }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"; to: "visible"
                NumberAnimation { target: menuBox; property: "y"; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.0 }
            },
            Transition {
                from: "visible"; to: "hidden"
                SequentialAnimation {
                    NumberAnimation { target: menuBox; property: "y"; duration: 200; easing.type: Easing.InBack }
                    ScriptAction { script: { root.visible = false; root.activeData = null } }
                }
            }
        ]

		// Adjustment to hide the gap during the bounce animation
        Rectangle {
            color: parent.color
            width: parent.width
            height: 300
            anchors.bottom: parent.top
        }

        Rectangle {
            width: parent.width
            height: parent.radius
            color: parent.color
            anchors.top: parent.top
        }
        
        ReverseCorner {
            anchors.right: parent.left
            y: -Math.max(0, parent.y)
            height: parent.radius
            width: height
            color: parent.color
            type: ReverseCorner.CornerType.TopRight
        }
		
        ReverseCorner {
            anchors.left: parent.right
            y: -Math.max(0, parent.y)
            height: parent.radius
            width: height
            color: parent.color
            type: ReverseCorner.CornerType.TopLeft
        }

        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onClicked: (mouse) => mouse.accepted = true }

        Loader {
            id: contentLoader
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            
            sourceComponent: {
                if (root.activeType === "tray") return trayComponent;
                if (root.activeType === "volume") return volumeComponent;
                return null;
            }
        }

        // 1. Componente del TRAY (Iconos del sistema)
        Component {
            id: trayComponent
            // Envolvemos la columna en un Item para poder usar implicitWidth
            Item {
                implicitWidth: 200
                implicitHeight: menuColumn.implicitHeight

                Column {
                    id: menuColumn
                    width: parent.width
                    spacing: 5
                    bottomPadding: 10

                    QsMenuOpener {
                        id: menuOpener
                        menu: root.activeData?.menu ?? null
                    }

                    Repeater {
                        model: menuOpener.children
                        Rectangle {
                            width: parent.width - 20
                            height: modelData.isSeparator ? 10 : 36
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "transparent"
                            
                            Rectangle {
                                visible: modelData.isSeparator
                                width: parent.width; height: 1; color: "#585b70"; anchors.centerIn: parent
                            }

                            Item {
                                visible: !modelData.isSeparator
                                anchors.fill: parent
                                Text {
                                    text: modelData.text
                                    color: "white"; font.pixelSize: 14; font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left; anchors.leftMargin: 12
                                    anchors.right: parent.right; anchors.rightMargin: 12
                                    elide: Text.ElideRight
                                }
                                MouseArea {
                                    anchors.fill: parent; hoverEnabled: true
                                    onEntered: parent.parent.color = "#45475a"
                                    onExited: parent.parent.color = "transparent"
                                    onClicked: { modelData.triggered(); root.close() }
                                }
                            }
                            radius: 8
                        }
                    }
                }
            }
        }

        Component {
            id: volumeComponent
            Item {
                implicitWidth: 220
                implicitHeight: 50
                
                property var audio: root.activeData

                Rectangle {
                    width: parent.width - 30
                    height: 24
                    anchors.centerIn: parent
                    color: "#45475a"
                    radius: height / 2

                    Rectangle {
                        height: parent.height
                        width: parent.width * Math.min(1, Math.max(0, (audio?.audio?.volume ?? 0)))
                        color: "#89b4fa"
                        radius: parent.radius
                    }
                    MouseArea {
                        anchors.fill: parent
                        function setVolume(mouseX) {
                            if (audio?.audio) audio.audio.volume = Math.max(0, Math.min(1.5, mouseX / width));
                        }
                        onPressed: (mouse) => setVolume(mouse.x)
                        onPositionChanged: (mouse) => setVolume(mouse.x)
                    }
                }
            }
        }
    }
}