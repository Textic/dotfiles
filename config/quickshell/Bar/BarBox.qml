import QtQuick

Rectangle {
    id: root

    default property alias content: innerRow.data
    property alias spacing: innerRow.spacing

    color: "#313244"
    radius: 15
    height: 30
    
    width: innerRow.width + 20

	Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad 
        }
    }

    Row {
        id: innerRow
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

		move: Transition {
            NumberAnimation { properties: "x"; duration: 300; easing.type: Easing.OutQuad }
        }
    }
}