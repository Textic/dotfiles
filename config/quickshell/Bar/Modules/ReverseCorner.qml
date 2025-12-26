import QtQuick

Canvas {
    id: root
    width: 20
    height: 20
    
    // El color debe coincidir con el fondo de tu menú popup
    property color color: "#1e1e2e" 
    
    // Define si es la esquina izquierda o derecha
    enum CornerType {
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }
    property int type: ReverseCorner.CornerType.TopLeft

    onColorChanged: requestPaint()
    onTypeChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = root.color;
        ctx.beginPath();

        // Dibujamos la curva invertida según el tipo
        if (root.type === ReverseCorner.CornerType.TopRight) {
            // Para conectar el lado derecho de la barra con el menú abajo
            ctx.moveTo(width, 0); // Arriba derecha
            ctx.lineTo(0, height); // Abajo izquierda
            ctx.lineTo(width, height); // Abajo derecha
            ctx.lineTo(width, 0); // Cerrar
            // El truco es 'borrar' la curva o dibujarla, aquí dibujamos el relleno
            // Mejor dibujamos un cuadrado y borramos el círculo
            ctx.reset();
            ctx.fillStyle = root.color;
            ctx.fillRect(0, 0, width, height);
            ctx.globalCompositeOperation = "destination-out";
            ctx.beginPath();
            ctx.arc(0, 0, width, 0, Math.PI * 2, false);
            ctx.fill();
        } 
        else if (root.type === ReverseCorner.CornerType.TopLeft) {
            // Para conectar el lado izquierdo
            ctx.reset();
            ctx.fillStyle = root.color;
            ctx.fillRect(0, 0, width, height);
            ctx.globalCompositeOperation = "destination-out";
            ctx.beginPath();
            ctx.arc(width, 0, width, 0, Math.PI * 2, false);
            ctx.fill();
        }
        // (Puedes agregar BottomLeft/BottomRight si alguna vez pones la barra abajo)
    }
}