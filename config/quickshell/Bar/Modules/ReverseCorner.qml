import QtQuick

Canvas {
    id: root
    
    // Adjust default size if needed, 
    // but usually controlled from outside with width/height
    implicitWidth: 20
    implicitHeight: 20

    // Color must match your menu background
    property color color: "#313244" 

    // Corner types depending on where the "solid" part is
    enum CornerType {
        TopLeft,     // Solid top-left (Use on the RIGHT of the menu)
        TopRight,    // Solid top-right (Use on the LEFT of the menu)
        BottomLeft,  // Solid bottom-left
        BottomRight  // Solid bottom-right
    }
    
    property int type: ReverseCorner.CornerType.TopLeft

    // Repaint if properties change
    onColorChanged: requestPaint()
    onTypeChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        
        // 1. Draw the complete base square
        ctx.fillStyle = root.color;
        ctx.fillRect(0, 0, width, height);

        // 2. Prepare to "erase" (cut out)
        ctx.globalCompositeOperation = "destination-out";
        ctx.beginPath();

        // 3. Draw the circle to be erased according to the type
        // The logic is: To leave corner X solid, we erase the opposite corner Y.
        
        if (root.type === ReverseCorner.CornerType.TopLeft) {
            // We want Solid Top-Left -> Erase Bottom-Right circle
            ctx.arc(width, height, width, 0, 2 * Math.PI);
            
        } else if (root.type === ReverseCorner.CornerType.TopRight) {
            // We want Solid Top-Right -> Erase Bottom-Left circle
            ctx.arc(0, height, width, 0, 2 * Math.PI);
            
        } else if (root.type === ReverseCorner.CornerType.BottomLeft) {
            // We want Solid Bottom-Left -> Erase Top-Right circle
            ctx.arc(width, 0, width, 0, 2 * Math.PI);
            
        } else if (root.type === ReverseCorner.CornerType.BottomRight) {
            // We want Solid Bottom-Right -> Erase Top-Left circle
            ctx.arc(0, 0, width, 0, 2 * Math.PI);
        }

        // Execute the erasure
        ctx.fill();
    }
}