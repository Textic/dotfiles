import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import QtQuick
import "Modules"

PanelWindow {
	id: root

	WlrLayershell.namespace: "topbar"
	WlrLayershell.layer: WlrLayer.Top

	anchors.top: true
    anchors.left: true
    anchors.right: true

	implicitHeight: 45
	color: "#1e1e2e"

	// Left
	Row {
		anchors.left: parent.left
		anchors.leftMargin: 15
		anchors.verticalCenter: parent.verticalCenter
		spacing: 15
		
		OsIcon {
			width: 15
			height: 15
		}

		BarBoxLeft {
			Workspaces {}
			Separator {
				visible: SystemTray.items.length > 0
			}
			Tray {
                id: sysTray
            }
		}
	}

	// Center
	Row {
		anchors.centerIn: parent
	}

	// Right
	Row {
		anchors.right: parent.right
		anchors.rightMargin: 15
		spacing: 15
		anchors.verticalCenter: parent.verticalCenter
		
		BarBoxRight {
			Network {}
			Volume {}
		}
		Clock {}
	}
}