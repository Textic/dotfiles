import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    width: 30
    height: 30

    property string iconSource: ""

    FileView {
        id: osRelease
        path: "/etc/os-release"
        onLoaded: {
            const lines = text().split("\n");
            
            const getValue = (key) => {
                const line = lines.find(l => l.startsWith(key + "="));
                return line ? line.split("=")[1].replace(/"/g, "") : "";
            }
            
            const osId = getValue("ID");
            console.log("Detected System: " + osId);

            root.iconSource = ""; 
        }
    }

    Image {
        anchors.fill: parent
        anchors.margins: 4
        source: root.iconSource
        fillMode: Image.PreserveAspectFit
        visible: false 
    }

    Text {
        anchors.centerIn: parent
        text: ""  
        font.pixelSize: 20
        color: "#1793d1"
        font.bold: true
        visible: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: console.log("Click on the logo")
    }
}