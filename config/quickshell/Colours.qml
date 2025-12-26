pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#131012"
    readonly property color foreground: "#FDF6FB"
    readonly property color cursor: "#B59DD3"

    readonly property color c0: "#3B383A"
    readonly property color c1: "#5F4F67"
    readonly property color c2: "#6D45AB"
    readonly property color c3: "#8A7994"
    readonly property color c4: "#CF69EA"
    readonly property color c5: "#CCABE2"
    readonly property color c6: "#F8E4F3"
    readonly property color c7: "#F3E9F1"
    readonly property color c8: "#AAA3A8"
    readonly property color c9: "#5F4F67"
    readonly property color c10: "#6D45AB"
    readonly property color c11: "#8A7994"
    readonly property color c12: "#CF69EA"
    readonly property color c13: "#CCABE2"
    readonly property color c14: "#F8E4F3"
    readonly property color c15: "#F3E9F1"
    
    property var palette: QtObject {
        // Background
        readonly property color m3surface: background
        readonly property color m3surfaceContainer: "#3B383A" 
        readonly property color m3surfaceContainerHigh: "#AAA3A8"
        
        // Text
        readonly property color m3onSurface: foreground
        readonly property color m3onSurfaceVariant: "#F3E9F1"

	// Primary / Secondary
        readonly property color m3primary: "#CF69EA" // Azul usualmente
        readonly property color m3onPrimary: background
        readonly property color m3primaryContainer: "#CF69EA"
        readonly property color m3onPrimaryContainer: "#CF69EA"

        readonly property color m3secondary: "#CCABE2"
        readonly property color m3onSecondary: background
        readonly property color m3secondaryContainer: "#CCABE2"
        readonly property color m3onSecondaryContainer: "#CCABE2"

	// Error
        readonly property color m3error: "#5F4F67"
    }
}
