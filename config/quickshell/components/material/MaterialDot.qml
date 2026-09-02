import QtQuick

Item {
    id: root

    property color color: "white"
    property int shapeIndex: 0

    width: 11
    height: 11

    Canvas {
        id: canvas
        anchors.fill: parent

        // Traces a polygon with each corner rounded off by a quadratic
        // curve, so squares/diamonds/triangles/stars read as soft "material"
        // blobs instead of sharp cutouts.
        function roundedPolygon(ctx, points, cornerRadius) {
            var n = points.length;
            for (var i = 0; i < n; i++) {
                var prev = points[(i - 1 + n) % n];
                var cur = points[i];
                var next = points[(i + 1) % n];

                var v1x = prev.x - cur.x, v1y = prev.y - cur.y;
                var v2x = next.x - cur.x, v2y = next.y - cur.y;
                var len1 = Math.hypot(v1x, v1y) || 1;
                var len2 = Math.hypot(v2x, v2y) || 1;
                var r = Math.min(cornerRadius, len1 / 2, len2 / 2);

                var a = {
                    x: cur.x + (v1x / len1) * r,
                    y: cur.y + (v1y / len1) * r
                };
                var b = {
                    x: cur.x + (v2x / len2) * r,
                    y: cur.y + (v2y / len2) * r
                };

                if (i === 0)
                    ctx.moveTo(a.x, a.y);
                else
                    ctx.lineTo(a.x, a.y);
                ctx.quadraticCurveTo(cur.x, cur.y, b.x, b.y);
            }
            ctx.closePath();
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.fillStyle = root.color;
            ctx.beginPath();

            var w = width, h = height;
            var cx = w / 2, cy = h / 2;

            switch (root.shapeIndex % 5) {
            case 0: { // circle
                ctx.arc(cx, cy, w / 2, 0, Math.PI * 2);
                break;
            }
            case 1: { // rounded square
                canvas.roundedPolygon(ctx, [
                    { x: 0, y: 0 },
                    { x: w, y: 0 },
                    { x: w, y: h },
                    { x: 0, y: h }
                ], w * 0.28);
                break;
            }
            case 2: { // rounded diamond
                canvas.roundedPolygon(ctx, [
                    { x: cx, y: 0 },
                    { x: w, y: cy },
                    { x: cx, y: h },
                    { x: 0, y: cy }
                ], w * 0.24);
                break;
            }
            case 3: { // rounded triangle
                canvas.roundedPolygon(ctx, [
                    { x: cx, y: 0 },
                    { x: w, y: h },
                    { x: 0, y: h }
                ], w * 0.24);
                break;
            }
            case 4: { // rounded star
                var spikes = 5;
                var outerR = w / 2;
                var innerR = w / 4;
                var rot = -Math.PI / 2;
                var step = Math.PI / spikes;
                var pts = [];
                for (var i = 0; i < spikes; i++) {
                    pts.push({ x: cx + Math.cos(rot) * outerR, y: cy + Math.sin(rot) * outerR });
                    rot += step;
                    pts.push({ x: cx + Math.cos(rot) * innerR, y: cy + Math.sin(rot) * innerR });
                    rot += step;
                }
                canvas.roundedPolygon(ctx, pts, w * 0.09);
                break;
            }
            }

            ctx.closePath();
            ctx.fill();
        }
    }

    onColorChanged: canvas.requestPaint()
    onShapeIndexChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    Component.onCompleted: canvas.requestPaint()
}
