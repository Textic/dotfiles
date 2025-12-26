import QtQuick

Text {
    id: root

    property real fill: 0
    property int grade: 0
    property int weight: 400
    property int opticalSize: 24

    font.family: "Material Symbols Rounded"
    font.variableAxes: {
        "FILL": root.fill,
        "GRAD": root.grade,
        "wght": root.weight,
        "opsz": root.opticalSize
    }

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}