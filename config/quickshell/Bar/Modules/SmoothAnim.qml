import QtQuick

NumberAnimation {
    duration: 300 
    easing.type: Easing.BezierSpline
    easing.bezierCurve: [0.05, 0.7, 0.1, 1.0, 0.05, 0.7, 0.1, 1.0, 0.05, 0.7, 0.1, 1.0] 
}