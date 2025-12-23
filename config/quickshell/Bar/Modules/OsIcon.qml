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
            const lines = text.split("\n");
            const getValue = (key) => {
                const line = lines.find(l => l.startsWith(key + "="));
                return line ? line.split("=")[1].replace(/"/g, "") : "";
            }
            
            const osId = getValue("ID");
            const names = [osId + "-logo", "distributor-logo-" + osId, "archlinux-icon", "start-here-arch"];
            
            for (let name of names) {
                if (Quickshell.iconPath(name)) {
                    root.iconSource = Quickshell.iconPath(name);
                    return;
                }
            }
            console.log("No se encontró icono del sistema para: " + osId);
        }
    }

    Image {
        anchors.fill: parent
        anchors.margins: 4
        source: root.iconSource
        fillMode: Image.PreserveAspectFit
        visible: status === Image.Ready
    }
    Text {
        anchors.centerIn: parent
        text: ""
        font.pixelSize: 20
        color: "#1793d1"
        font.bold: true
        visible: root.iconSource === ""
    }

    MouseArea {
        anchors.fill: parent
        onClicked: console.log("Click en el logo")
    }
}