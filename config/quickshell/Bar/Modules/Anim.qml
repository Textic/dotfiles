import QtQuick

NumberAnimation {
    duration: 500 // Duración estándar de Caelestia (aprox)
    easing.type: Easing.BezierSpline
    // Esta es la curva "Standard" que usan por defecto
    easing.bezierCurve: [0.2, 0.0, 0, 1.0]
}