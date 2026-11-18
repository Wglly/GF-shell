import QtQuick
import qs.modules.common

// WeatherIcon — 程序化天气图标（不依赖图标字体）。
Item {
    id: root

    property string kind: "cloud"      // sun | cloud | rain | snow | storm | fog
    property color color: Theme.accent
    property bool dim: false
    implicitWidth: Theme.px(34)
    implicitHeight: Theme.px(34)

    Canvas {
        id: canvas
        anchors.fill: parent
        opacity: root.dim ? 0.55 : 1
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var w = width, h = height;
            var c = root.color;
            ctx.strokeStyle = c;
            ctx.fillStyle = c;
            ctx.lineWidth = Math.max(1.2, w * 0.045);
            ctx.lineCap = "round";

            function sun(cx, cy, r) {
                ctx.beginPath();
                ctx.arc(cx, cy, r, 0, Math.PI * 2);
                ctx.stroke();
                for (var i = 0; i < 8; i++) {
                    var a = i * Math.PI / 4;
                    ctx.beginPath();
                    ctx.moveTo(cx + Math.cos(a) * (r + 2.5), cy + Math.sin(a) * (r + 2.5));
                    ctx.lineTo(cx + Math.cos(a) * (r + 6), cy + Math.sin(a) * (r + 6));
                    ctx.stroke();
                }
            }

            function cloud(cx, cy, s) {
                ctx.beginPath();
                ctx.arc(cx - s * 0.55, cy + s * 0.1, s * 0.45, Math.PI * 0.5, Math.PI * 1.5);
                ctx.arc(cx - s * 0.05, cy - s * 0.2, s * 0.62, Math.PI, Math.PI * 1.9);
                ctx.arc(cx + s * 0.55, cy + s * 0.05, s * 0.48, Math.PI * 1.4, Math.PI * 0.5);
                ctx.closePath();
                ctx.fill();
            }

            var cx = w / 2, cy = h / 2, s = w * 0.30;
            if (root.kind === "sun") {
                sun(cx, cy, s * 0.75);
            } else if (root.kind === "cloud") {
                cloud(cx, cy - 2, s);
            } else if (root.kind === "rain") {
                cloud(cx, cy - 5, s);
                for (var i = -1; i <= 1; i++) {
                    ctx.beginPath();
                    ctx.moveTo(cx + i * s * 0.7 - 2, cy + s * 0.75);
                    ctx.lineTo(cx + i * s * 0.7 - 5, cy + s * 1.15);
                    ctx.stroke();
                }
            } else if (root.kind === "snow") {
                cloud(cx, cy - 5, s);
                for (var j = -1; j <= 1; j++) {
                    var px = cx + j * s * 0.7, py = cy + s * 1.0;
                    ctx.beginPath();
                    ctx.moveTo(px - 3, py); ctx.lineTo(px + 3, py);
                    ctx.moveTo(px, py - 3); ctx.lineTo(px, py + 3);
                    ctx.stroke();
                }
            } else if (root.kind === "storm") {
                cloud(cx, cy - 6, s);
                ctx.beginPath();
                ctx.moveTo(cx + 2, cy + s * 0.55);
                ctx.lineTo(cx - 5, cy + s * 1.05);
                ctx.lineTo(cx + 1, cy + s * 1.02);
                ctx.lineTo(cx - 3, cy + s * 1.5);
                ctx.stroke();
            } else {
                for (var k = 0; k < 3; k++) {
                    ctx.beginPath();
                    ctx.moveTo(w * 0.2, h * (0.42 + k * 0.13));
                    ctx.lineTo(w * 0.8, h * (0.42 + k * 0.13));
                    ctx.stroke();
                }
            }
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    onKindChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
}
