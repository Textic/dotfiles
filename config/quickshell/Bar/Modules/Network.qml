import Quickshell
import Quickshell.Io
import QtQuick

Row {
    id: root
    spacing: 5

    property string connectionType: "disconnected"
    property int wifiSignal: 0

    Timer {
        interval: 2000 
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    Process {
        id: netProc
        // Bash script that manages priority logic:
        // 1. Check if Ethernet is connected. If so -> print "ethernet".
        // 2. Otherwise, check if Wifi is connected. If so -> print "wifi:STRENGTH".
        // 3. Otherwise, print "disconnected".
        command: ["bash", "-c", "
            if nmcli -t -f TYPE,STATE device | grep -q 'ethernet:connected'; then
                echo 'ethernet'
            elif nmcli -t -f active,signal dev wifi | grep -q '^yes'; then
                echo \"wifi:$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d: -f2)\"
            else
                echo 'disconnected'
            fi
        "]

        stdout: SplitParser {
            onRead: (data) => {
                let output = data.trim();
                
                if (output === "ethernet") {
                    root.connectionType = "ethernet";
                } else if (output.startsWith("wifi:")) {
                    root.connectionType = "wifi";
					// Extract the signal strength after the colon (e.g., "wifi:85")
                    root.wifiSignal = parseInt(output.split(":")[1]) || 0;
                } else {
                    root.connectionType = "disconnected";
                }
            }
        }
    }

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        
        function getIcon() {
            if (root.connectionType === "ethernet") {
                return "lan";
            }
            
            if (root.connectionType === "wifi") {
                let s = root.wifiSignal;
                if (s >= 80) return "signal_wifi_4_bar";
                if (s >= 60) return "network_wifi_3_bar";
                if (s >= 40) return "network_wifi_2_bar";
                if (s >= 20) return "network_wifi_1_bar";
                return "signal_wifi_0_bar";
            }
            
            return "signal_wifi_off";
        }

        text: getIcon()
        font.pixelSize: 22
        color: "white"
    }
}