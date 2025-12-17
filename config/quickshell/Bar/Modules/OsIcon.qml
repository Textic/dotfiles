import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    width: 30
    height: 30

    // Propiedad para guardar la ruta encontrada
    property string iconSource: ""

    // --- Lógica de detección ---
    FileView {
        id: osRelease
        path: "/etc/os-release"
        onLoaded: {
            const lines = text.split("\n");
            const getValue = (key) => {
                const line = lines.find(l => l.startsWith(key + "="));
                return line ? line.split("=")[1].replace(/"/g, "") : "";
            }
            
            // Buscamos iconos comunes de Arch
            const osId = getValue("ID"); // ej: "arch"
            const names = [osId + "-logo", "distributor-logo-" + osId, "archlinux-icon", "start-here-arch"];
            
            for (let name of names) {
                if (Quickshell.iconPath(name)) {
                    root.iconSource = Quickshell.iconPath(name);
                    return;
                }
            }
            // Si llega aquí, es que no encontró nada en el sistema
            console.log("No se encontró icono del sistema para: " + osId);
        }
    }

    // --- Visualización ---

    // 1. Intentamos mostrar la Imagen
    Image {
        anchors.fill: parent
        anchors.margins: 4 // Un poco de margen para que no toque los bordes
        source: root.iconSource
        fillMode: Image.PreserveAspectFit
        visible: status === Image.Ready // Solo visible si cargó bien
    }

    // 2. RESPALDO: Si la imagen falla, mostramos texto
    Text {
        anchors.centerIn: parent
        text: "" // Icono de Arch (requiere Nerd Font) o usa "ARCH"
        font.pixelSize: 20
        color: "#1793d1" // Azul Arch
        font.bold: true
        
        // Visible solo si NO hay imagen cargada
        visible: root.iconSource === ""
    }

    MouseArea {
        anchors.fill: parent
        onClicked: console.log("Click en el logo")
    }
}