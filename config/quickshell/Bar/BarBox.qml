import QtQuick
import ".."

Rectangle {
    id: root

    default property alias content: innerRow.data
    property alias spacing: innerRow.spacing
    property bool idRight: false

    color: Colours.palette.m3surfaceContainer
    radius: 15
    height: 30
    
    width: innerRow.width + 20

	Behavior on width {
        NumberAnimation {
            duration: 0; // 0 because it moves with the movements of the other modules
            easing.type: Easing.OutQuad 
        }
    }

    Row {
        id: innerRow
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

		move: Transition {
            NumberAnimation {
				properties: "x";
				duration: 0; // 0 because it moves with the movements of the other modules
				easing.type: Easing.OutQuad
			}
        }
    }
}