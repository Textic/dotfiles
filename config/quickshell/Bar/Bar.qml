import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import QtQuick
import "Modules"
import ".."

PanelWindow {
	id: root

	screen: Quickshell.screens.find(s => s.name === "DP-1") || Quickshell.screens[0]

	WlrLayershell.namespace: "topbar"
	WlrLayershell.layer: WlrLayer.Top

	anchors.top: true
    anchors.left: true
    anchors.right: true

	implicitHeight: 45
	color: Colours.m3primary

	UnifiedMenu {
		id: sharedMenu
	}

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

		BarBox {
			idRight: false
			spacing: 5
			
			Workspaces {}
			Separator {
				visible: SystemTray.items.length > 0
			}
			Tray {
                id: sysTray
				menuRef: sharedMenu
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
		
		BarBox {
			idRight: true
			
			Network {}
			Volume {
				menuRef: sharedMenu
			}
		}
		Clock {}
	}
}