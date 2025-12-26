pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "{{background}}"
    readonly property color foreground: "{{foreground}}"
    readonly property color cursor: "{{cursor}}"

    readonly property color c0: "{{color0}}"
    readonly property color c1: "{{color1}}"
    readonly property color c2: "{{color2}}"
    readonly property color c3: "{{color3}}"
    readonly property color c4: "{{color4}}"
    readonly property color c5: "{{color5}}"
    readonly property color c6: "{{color6}}"
    readonly property color c7: "{{color7}}"
    readonly property color c8: "{{color8}}"
    readonly property color c9: "{{color9}}"
    readonly property color c10: "{{color10}}"
    readonly property color c11: "{{color11}}"
    readonly property color c12: "{{color12}}"
    readonly property color c13: "{{color13}}"
    readonly property color c14: "{{color14}}"
    readonly property color c15: "{{color15}}"
    
    property var palette: QtObject {
        // Background
        readonly property color m3surface: background
        readonly property color m3surfaceContainer: "{{color0}}" 
        readonly property color m3surfaceContainerHigh: "{{color8}}"
        
        // Text
        readonly property color m3onSurface: foreground
        readonly property color m3onSurfaceVariant: "{{color7}}"

	// Primary / Secondary
        readonly property color m3primary: "{{color4}}" // Azul usualmente
        readonly property color m3onPrimary: background
        readonly property color m3primaryContainer: "{{color12}}"
        readonly property color m3onPrimaryContainer: "{{color4}}"

        readonly property color m3secondary: "{{color5}}"
        readonly property color m3onSecondary: background
        readonly property color m3secondaryContainer: "{{color13}}"
        readonly property color m3onSecondaryContainer: "{{color5}}"

	// Error
        readonly property color m3error: "{{color1}}"
    }
}
