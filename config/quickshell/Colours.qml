pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // --- START LOG ---
    Component.onCompleted: {
        console.log("🔥🔥🔥 [Colours] START: Colours Singleton created 🔥🔥🔥");
        console.log("🔥🔥🔥 [Colours] Search path:", root.jsonPath);
        
        // Check if FileView is already ready (sometimes happens quickly)
        if (colorFile.text && colorFile.text() !== "") {
            console.log("🔥🔥🔥 [Colours] FileView already had content at start. Loading...");
            root.loadScheme(colorFile.text());
        }
    }

    property real wallLuminance: 0.0

    property string jsonPath: Quickshell.env("HOME") + "/.cache/matugen_colors.json"
    property bool isDark: true 
    property real transparencyBase: 0.8
    
    // --- WATCHER WITH LOGS ---
    FileView {
        id: colorFile
        path: root.jsonPath
        watchChanges: true
        
        onFileChanged: {
            console.log("🔥🔥🔥 [Colours] EVENT: File on disk changed.");
            reload();
        }
        
        onLoaded: {
            console.log("🔥🔥🔥 [Colours] EVENT: FileView finished loading.");
            var content = text();
            console.log("🔥🔥🔥 [Colours] Read text length: " + (content ? content.length : "0"));
            console.log("🔥🔥🔥 [Colours] First 50 characters: " + (content ? content.substring(0, 50) : "EMPTY"));
            root.loadScheme(content);
        }
    }

    // --- LOADING LOGIC WITH LOGS ---
    function loadScheme(jsonString) {
        console.log("🔥🔥🔥 [Colours] Entering loadScheme...");

        if (typeof jsonString !== 'string' || !jsonString || jsonString.trim() === "") {
            console.warn("⚠️⚠️⚠️ [Colours] Empty or invalid JSON string. Aborting load.");
            return;
        }

        try {
            var scheme = JSON.parse(jsonString);
            console.log("🔥🔥🔥 [Colours] JSON.parse successful.");

            if (scheme.luminance !== undefined) {
                // Convertimos a float por si acaso viene como string
                root.wallLuminance = parseFloat(scheme.luminance);
                console.log("💡 [Colours] Luminance loaded from JSON: " + root.wallLuminance);
            }
            var selectedColors = root.isDark ? (scheme.dark || scheme) : (scheme.light || scheme);
            var finalColors = selectedColors.colours || selectedColors.colors || selectedColors;

            var updatedCount = 0;
            for (var key in finalColors) {
                if (finalColors.hasOwnProperty(key)) {
                    var propName = "m3" + key;
                    var colorValue = finalColors[key];

                    if (root[propName] !== undefined) {
                        if (colorValue.indexOf("#") !== 0) {
                            colorValue = "#" + colorValue;
                        }
                        root[propName] = colorValue;
                        updatedCount++;
                    }
                }
            }
            console.log("✅✅✅ [Colours] Load complete. Updated " + updatedCount + " colors.");

        } catch (e) {
            console.error("❌❌❌ [Colours] FATAL EXCEPTION in loadScheme: " + e);
        }
    }

    // --- PROPERTIES (Default values to avoid 'undefined') ---
    property color m3primary: "#ffb0ca"
    property color m3onPrimary: "#541d34"
    property color m3primaryContainer: "#6f334a"
    property color m3onPrimaryContainer: "#ffd9e3"
    property color m3secondary: "#e2bdc7"
    property color m3onSecondary: "#422932"
    property color m3secondaryContainer: "#5a3f48"
    property color m3onSecondaryContainer: "#ffd9e3"
    property color m3tertiary: "#f0bc95"
    property color m3onTertiary: "#48290c"
    property color m3tertiaryContainer: "#b58763"
    property color m3onTertiaryContainer: "#000000"
    property color m3error: "#ffb4ab"
    property color m3onError: "#690005"
    property color m3errorContainer: "#93000a"
    property color m3onErrorContainer: "#ffdad6"
    property color m3background: "#191114"
    property color m3onBackground: "#efdfe2"
    property color m3surface: "#191114"
    property color m3onSurface: "#efdfe2"
    property color m3surfaceVariant: "#514347"
    property color m3onSurfaceVariant: "#d5c2c6"
    property color m3outline: "#9e8c91"
    property color m3outlineVariant: "#514347"
    property color m3inverseOnSurface: "#372e30"
    property color m3inverseSurface: "#efdfe2"
    property color m3surfaceContainer: "#261d20"
    property color m3surfaceContainerHigh: "#31282a"
    property color m3surfaceContainerHighest: "#3c3235"
    property color m3shadow: "#000000"
    property color m3scrim: "#000000"
    property color m3surfaceDim: "#191114"
    property color m3surfaceBright: "#403739"
    property color m3surfaceContainerLowest: "#130c0e"
    property color m3surfaceContainerLow: "#22191c"
    property color m3inversePrimary: "#8b4a62"

    // --- HELPER FUNCTIONS ---
    function getLuminance(c) {
        if (!c) {
            console.warn("⚠️ [Colours] getLuminance received null color");
            return 0;
        }
        return Math.sqrt(0.299 * (c.r ** 2) + 0.587 * (c.g ** 2) + 0.114 * (c.b ** 2));
    }

    function alterColour(c, a, layer) {
        if (!c) return "#000000";
        const wallLuminance = root.wallLuminance;
        const luminance = getLuminance(c);
        const light = !root.isDark;
        const offset = (!light || layer === 1 ? 1 : -layer / 2) * (light ? 0.2 : 0.3) * (1 - root.transparencyBase) * (1 + wallLuminance * (light ? (layer === 1 ? 3 : 1) : 2.5));
        var safeLuminance = luminance || 0.01; 
        const scale = (luminance + offset) / safeLuminance;
        const r = Math.max(0, Math.min(1, c.r * scale));
        const g = Math.max(0, Math.min(1, c.g * scale));
        const b = Math.max(0, Math.min(1, c.b * scale));
        
        return Qt.rgba(r, g, b, a);
    }

    function layer(c, layerIndex) {
        if (!c) {
            console.warn("⚠️ [Colours] layer function received undefined color");
            return "#000000";
        }
        return layerIndex === 0 ? Qt.alpha(c, root.transparencyBase) : alterColour(c, root.transparencyBase, layerIndex ?? 1);
    }
}