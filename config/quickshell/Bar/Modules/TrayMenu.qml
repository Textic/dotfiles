import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import "../.."

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

    Timer {
        id: layoutTimer
        interval: 10
        onTriggered: menuBox.state = "visible"
    }

    function open(globalX, entry) {
        targetX = globalX
        activeEntry = entry
        root.visible = true
        menuBox.state = "hidden" 
        // menuBox.state = "visible"
        layoutTimer.restart()
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
        
        height: menuList.implicitHeight + 20
        width: 200
        
        color: Colours.background
        radius: 20

        opacity: 1 
        y: -height 
        
        state: "hidden"

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: menuBox
                    y: 0
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: menuBox
                    y: -menuBox.height - 20
                }
            }
        ]

        transitions: [
            Transition {
                from: "hidden"
                to: "visible"
                
                NumberAnimation {
                    target: menuBox
                    property: "y"
                    duration: 250
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.0
                }
            },
            Transition {
                from: "visible"
                to: "hidden"

                SequentialAnimation {
                    NumberAnimation {
                        target: menuBox
                        property: "y"
                        duration: 200
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.2, 0.0, 0.0, 1.0]
                    }
                    
                    ScriptAction {
                        script: {
                            root.visible = false
                            root.activeEntry = null
                        }
                    }
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
            // anchors.top: parent.top
            y: -Math.max(0, parent.y)
            height: parent.radius
            width: height
            color: parent.color
            type: ReverseCorner.CornerType.TopRight
        }

        ReverseCorner {
            anchors.left: parent.right
            // anchors.top: parent.top
            y: -Math.max(0, parent.y)
            height: parent.radius
            width: height
            color: parent.color
            type: ReverseCorner.CornerType.TopLeft
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: (mouse) => mouse.accepted = true
        }

        Column {
            id: menuList
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 20

            QsMenuOpener {
                id: menuOpener
                menu: root.activeEntry?.menu ?? null
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
                        width: parent.width
                        height: 1
                        color: "#585b70"
                        anchors.centerIn: parent
                    }

                    Item {
                        visible: !modelData.isSeparator
                        anchors.fill: parent
                        
                        Text {
                            text: modelData.text
                            color: "white"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !modelData.isSeparator
                            onEntered: parent.parent.color = "#45475a"
                            onExited: parent.parent.color = "transparent"
                            onClicked: {
                                modelData.triggered()
                                root.close()
                            }
                        }
                    }
                    radius: 8
                }
            }
        }
    }
}