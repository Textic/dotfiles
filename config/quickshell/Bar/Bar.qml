import Quickshell
import Quickshell.Wayland
import QtQuick
import "Modules"

PanelWindow {
	id: root

	WlrLayershell.namespace: "topbar"
	WlrLayershell.layer: WlrLayer.Top

	anchors.top: true
    anchors.left: true
    anchors.right: true

	implicitHeight: 40
	color: "#1e1e2e"

	// Left
	Row {
		anchors.left: parent.left
		anchors.leftMargin: 10
		anchors.verticalCenter: parent.verticalCenter
		spacing: 15
		
		OsIcon {
			width: 15
			height: 15
		}

		BarBox {
			Workspaces {}
			Separator {
                visible: SystemTray.items.length > 0
            }
			SystemTray {}
		}
	}

	// Center
	Row {
		anchors.centerIn: parent
	}

	// Right
	Row {
		anchors.right: parent.right
		anchors.rightMargin: 10
		anchors.verticalCenter: parent.verticalCenter
		
		Clock {}
	}
}