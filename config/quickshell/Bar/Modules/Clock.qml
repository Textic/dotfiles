import Quickshell
import QtQuick

Column {
    id: root
    spacing: 2
    anchors.verticalCenter: parent.verticalCenter
    
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // MaterialIcon {
    //     // Name of the icon
    //     text: "calendar_month" 

    //     anchors.horizontalCenter: parent.horizontalCenter
    //     font.pixelSize: 22
    //     color: "white" 
    //     weight: 300
    //     fill: 1
    // }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: Qt.formatDateTime(clock.date, "hh\nmm")
        font.family: "Hack Nerd Font"
        font.bold: true
        font.pixelSize: 15
        color: "white"
        lineHeight: 0.8
    }
}
