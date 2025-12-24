import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell
import QtQuick.Effects

Rectangle {
	id: root
	required property LockContext context
	readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive

	readonly property color c_background: "#1e1e2e"
    readonly property color c_text_main:  "#cdd6f4"
    readonly property color c_text_sec:   "#a6adc8"
    readonly property color c_input_text: "#cdd6f4"

	property var date: new Date();

	color: "black"
	property bool isImageLoaded: backgroundImage.status === Image.Ready

	opacity: isImageLoaded ? 1 : 0

	Component.onCompleted: opacity = 1

	Behavior on opacity {
		NumberAnimation {
			duration: 500
			easing.type: Easing.OutCubic
		}
	}

	Rectangle {
        anchors.fill: parent
        color: "black"
    }

	Image {
		id: backgroundImage
		anchors.fill: parent
		source: "file://" + Quickshell.env("HOME") + "/.current_wallpaper"
		fillMode: Image.PreserveAspectCrop
		asynchronous: true
		visible: false
	}

	MultiEffect {
		source: backgroundImage
		anchors.fill: backgroundImage

		blurEnabled: true
		blurMax: 64
		blur: 1
		// contrast: 1.3
		// brightness: 0.8
		// saturation: 0.2
	}

	Timer {
		interval: 1000;
		running: true;
		repeat: true;

		onTriggered: root.date = new Date();
	}

	Text {
		id: labelHour
		anchors.centerIn: parent
		anchors.verticalCenterOffset: -220

		text: Qt.formatTime(root.date, "HH")
		color: c_text_main

		font.family: "Lexend"
		font.pointSize: 90
		font.weight: Font.ExtraBold

		style: Text.Outline;
		styleColor: "#000000"
	}

	Text {
		id: labelMin
		anchors.centerIn: parent
		anchors.verticalCenterOffset: -110

		text: Qt.formatTime(root.date, "mm")
		color: c_text_main

		font.family: "Lexend"
		font.pointSize: 90
		font.weight: Font.ExtraBold

		style: Text.Outline;
		styleColor: "#000000"
	}

	Text {
        id: labelDay
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -20
        
        text: Qt.formatDate(root.date, "dddd")
        color: c_text_sec
        
        font.family: "Hack Nerd Font"
        font.pixelSize: 17
        font.bold: true
    }

	Text {
        id: labelDate
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 4
        
        text: Qt.formatDate(root.date, "d MMM")
        color: c_text_sec
        
        font.family: "Hack Nerd Font"
        font.pixelSize: 13
        font.bold: true
    }

	TextField {
		id: passwordBox

		anchors.bottom: parent.bottom
		anchors.bottomMargin: 120
		anchors.horizontalCenter: parent.horizontalCenter
		
		width: 250
		height: 50

		visible: Window.active
		color: "transparent"
		selectedTextColor: "transparent"
		selectionColor: "transparent"
		cursorDelegate: Item {}
		font.family: "Lexend"
		font.pixelSize: 16
		horizontalAlignment: TextInput.AlignHCenter
		verticalAlignment: TextInput.AlignVCenter

		focus: true
		echoMode: TextInput.Password
		// placeholderText: "Password..."
		inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
		placeholderTextColor: Qt.lighter(c_input_text, 0.5)

		enabled: !root.context.unlockInProgress

		ListModel {
			id: dotsModel
		}

		function updateDots() {
			while (dotsModel.count < passwordBox.text.length) {
				dotsModel.append({}); 
			}
			while (dotsModel.count > passwordBox.text.length) {
				dotsModel.remove(dotsModel.count - 1);
			}
		}

		background: Rectangle {
            color: c_background
            radius: 22
            border.width: 3
            border.color: c_background
            opacity: passwordBox.text !== "" ? 0.8 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            Item {
                anchors.fill: parent
                anchors.margins: 10
                clip: true 

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Repeater {
                        model: dotsModel

                        Rectangle {
                            width: 11
                            height: 11
                            radius: 5
                            color: c_input_text

                            scale: 0
                            Component.onCompleted: scale = 1
                            
                            Behavior on scale {
                                NumberAnimation { 
                                    duration: 200 
                                    easing.type: Easing.OutBack
                                }
                            }
                        }
                    }
                }
            }
        }

		onTextChanged: {
			root.context.currentText = this.text;
			updateDots();
		}
		onAccepted: root.context.tryUnlock();

		Connections {
			target: root.context

			function onCurrentTextChanged() {
				// Keep the text in the box in sync with the other monitors.
				if (passwordBox.text !== root.context.currentText) {
					passwordBox.text = root.context.currentText;
				}
			}

			function onShowFailureChanged() {
				if (root.context.showFailure) {
					passwordBox.text = "";
					passwordBox.placeholderText = "Incorrect password";
				}
			}
		}

	}
}
