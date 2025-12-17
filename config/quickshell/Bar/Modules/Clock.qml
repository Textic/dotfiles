import Quickshell
import QtQuick

Row {
    spacing: 5
    
    property string timeText: ""
    property string dateText: ""

    function updateTime() {
        let now = new Date()
        timeText = now.toLocaleTimeString(Qt.locale(), "hh:mm")
        dateText = now.toLocaleDateString(Qt.locale(), "dd/MM")
    }

    Timer {
        id: timer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: parent.updateTime()
    }

    Text {
        text: parent.timeText
        color: "white"
        font.bold: true
    }
    
    Text {
        text: "•"
        color: "white"
        font.bold: true
    }

    Text {
        text: parent.dateText
        color: "white"
        font.bold: true
    }
}
