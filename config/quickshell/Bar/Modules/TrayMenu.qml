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

    property int animDuration: 300
    property var animCurve: [0.05, 0.7, 0.1, 1.0]

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
        radius: 20

        // HACK: Patch rectangle to make top corners square
        // This allows "ReverseCorners" to connect without gaps.
        Rectangle {
            width: parent.width
            height: parent.radius
            color: parent.color
            anchors.top: parent.top
        }

        // Left corner (connects the bar with the left side of the menu)
        ReverseCorner {
            anchors.right: parent.left
            anchors.top: parent.top
            height: parent.radius
            width: height
            color: parent.color
            type: ReverseCorner.CornerType.TopRight
        }

        // Right corner (connects the bar with the right side of the menu)
        ReverseCorner {
            anchors.left: parent.right
            anchors.top: parent.top
            height: parent.radius
            width: height
            color: parent.color
            type: ReverseCorner.CornerType.TopLeft
        }

        // Small decorative top bar (iOS style)
        // Rectangle {
        //     width: 40; height: 4;
        //     color: Qt.lighter(parent.color, 1.2)
        //     anchors.top: parent.top;
        //     anchors.topMargin: 8
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     radius: 2
        // }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onClicked: (mouse) => mouse.accepted = true
        }

        opacity: root.visible ? 1 : 0
        
        transform: Scale {
            origin.x: menuBox.width / 2
            origin.y: 0
            yScale: root.visible ? 1 : 0
            Behavior on yScale {
                NumberAnimation {
                    duration: root.animDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.animCurve
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.animCurve
            }
        }
        
        // Smooth animation if content changes size
        Behavior on height {
            NumberAnimation {
                duration: root.animDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.animCurve
            }
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
                    height: modelData.isSeparator ? 10 : 36 // A bit taller to facilitate clicking
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "transparent"

                    Rectangle {
                        visible: modelData.isSeparator
                        width: parent.width
                        height: 1
                        color: "#585b70"
                        anchors.centerIn: parent
                    }

                    // Container for the interactive item
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