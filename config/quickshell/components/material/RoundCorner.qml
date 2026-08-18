import QtQuick

// A concave corner wedge: the arc bulges *into* the item instead of away from
// it, so filling it with a panel's own color makes the panel read as carved
// out of the screen edge rather than floating on top of it. Rectangle's radius
// only ever rounds outward, hence the Canvas.
//
// `corner` names the square's corner that stays solid — "topRight" keeps the
// top-right filled and sweeps the arc away toward the bottom-left.
Item {
    id: root

    property string corner: "topLeft"
    property int size: 12
    property color color: "black"

    implicitWidth: size
    implicitHeight: size

    onCornerChanged: canvas.requestPaint()
    onSizeChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        // Canvas keeps no backing store across a hide, so a corner that scrolls
        // or animates out of view comes back blank without this.
        onVisibleChanged: if (visible)
            requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            var r = root.size;
            ctx.clearRect(0, 0, width, height);
            ctx.beginPath();

            // Each arc runs between the two edges that meet at `corner`, then a
            // single line back across the diagonal closes the wedge.
            switch (root.corner) {
            case "topLeft":
                ctx.arc(r, r, r, Math.PI, 3 * Math.PI / 2);
                ctx.lineTo(0, 0);
                break;
            case "topRight":
                ctx.arc(0, r, r, 3 * Math.PI / 2, 2 * Math.PI);
                ctx.lineTo(r, 0);
                break;
            case "bottomLeft":
                ctx.arc(r, 0, r, Math.PI / 2, Math.PI);
                ctx.lineTo(0, r);
                break;
            case "bottomRight":
                ctx.arc(0, 0, r, 0, Math.PI / 2);
                ctx.lineTo(r, r);
                break;
            }

            ctx.closePath();
            // Canvas's fillStyle only accepts CSS-style strings — handing it a
            // QML `color` value directly is silently mis-rendered rather than
            // erroring.
            var c = root.color;
            ctx.fillStyle = "rgba(" + Math.round(c.r * 255) + "," + Math.round(c.g * 255) + "," + Math.round(c.b * 255) + "," + c.a + ")";
            ctx.fill();
        }
    }
}
