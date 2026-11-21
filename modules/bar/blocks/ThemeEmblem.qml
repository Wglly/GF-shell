import QtQuick
import qs.modules.common

// ThemeEmblem — hand-drawn tactical sigils for the deployment terminal.
// Each preset gets a distinct silhouette instead of printing its name.
Item {
    id: root
    width: Theme.px(28)
    height: Theme.px(28)

    property color accent: Theme.accent
    property color accent2: Theme.accent2
    property color ink: Theme.ink
    property bool active: false

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            var w = width, h = height, cx = w / 2, cy = h / 2;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            var A = root.accent, B = root.accent2, K = root.ink;

            if (Theme.hoi4) {
                // Field shield with an iron cross and laurel arcs.
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.06);
                ctx.lineTo(w * 0.90, h * 0.22);
                ctx.lineTo(w * 0.83, h * 0.76);
                ctx.lineTo(cx, h * 0.95);
                ctx.lineTo(w * 0.17, h * 0.76);
                ctx.lineTo(w * 0.10, h * 0.22);
                ctx.closePath();
                ctx.fillStyle = Theme.alpha(A, 0.16);
                ctx.fill();
                ctx.strokeStyle = A;
                ctx.lineWidth = 1.5;
                ctx.stroke();
                ctx.strokeStyle = Theme.alpha(A, 0.45);
                ctx.lineWidth = 1;
                ctx.beginPath();
                ctx.arc(cx, cy, w * 0.32, Math.PI * 0.62, Math.PI * 0.38, true);
                ctx.stroke();
                // Cross.
                ctx.strokeStyle = A;
                ctx.lineWidth = Math.max(2, w * 0.09);
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.25); ctx.lineTo(cx, h * 0.76);
                ctx.moveTo(w * 0.29, cy); ctx.lineTo(w * 0.71, cy);
                ctx.stroke();
                // Laurel ticks.
                ctx.strokeStyle = Theme.alpha(A, 0.7);
                ctx.lineWidth = 1;
                for (var i = 0; i < 4; i++) {
                    var yy = h * (0.42 + i * 0.10);
                    ctx.beginPath(); ctx.moveTo(w * 0.13, yy); ctx.lineTo(w * 0.22, yy - 2); ctx.stroke();
                    ctx.beginPath(); ctx.moveTo(w * 0.87, yy); ctx.lineTo(w * 0.78, yy - 2); ctx.stroke();
                }
            } else if (Theme.bf4) {
                // Hexagonal command node with crosshair and an orange vector slash.
                ctx.beginPath();
                for (var j = 0; j < 6; j++) {
                    var a = -Math.PI / 2 + j * Math.PI / 3;
                    var px = cx + Math.cos(a) * w * 0.40;
                    var py = cy + Math.sin(a) * h * 0.40;
                    if (j === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py);
                }
                ctx.closePath();
                ctx.fillStyle = Theme.alpha(B, 0.14);
                ctx.fill();
                ctx.strokeStyle = B;
                ctx.lineWidth = 1.4;
                ctx.stroke();
                ctx.strokeStyle = A;
                ctx.lineWidth = 1;
                ctx.beginPath(); ctx.arc(cx, cy, w * 0.22, 0, Math.PI * 2); ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.18); ctx.lineTo(cx, h * 0.32);
                ctx.moveTo(cx, h * 0.68); ctx.lineTo(cx, h * 0.82);
                ctx.moveTo(w * 0.18, cy); ctx.lineTo(w * 0.32, cy);
                ctx.moveTo(w * 0.68, cy); ctx.lineTo(w * 0.82, cy);
                ctx.stroke();
                ctx.strokeStyle = B;
                ctx.lineWidth = Math.max(2, w * 0.08);
                ctx.beginPath(); ctx.moveTo(w * 0.26, h * 0.74); ctx.lineTo(w * 0.74, h * 0.26); ctx.stroke();
            } else if (Theme.bf1) {
                // Laurel medal with a five-point field star.
                ctx.strokeStyle = Theme.alpha(A, 0.55);
                ctx.lineWidth = 1.2;
                ctx.beginPath(); ctx.arc(cx, cy, w * 0.39, 0, Math.PI * 2); ctx.stroke();
                ctx.beginPath(); ctx.arc(cx, cy, w * 0.31, 0, Math.PI * 2); ctx.stroke();
                // Laurels.
                ctx.strokeStyle = A;
                ctx.lineWidth = 1;
                for (var s = -1; s <= 1; s += 2) {
                    ctx.beginPath();
                    ctx.arc(cx + s * w * 0.06, cy, w * 0.30, s > 0 ? Math.PI * 0.70 : Math.PI * 0.30,
                        s > 0 ? Math.PI * 1.30 : Math.PI * 0.70, s < 0);
                    ctx.stroke();
                }
                // Star.
                ctx.beginPath();
                for (var p = 0; p < 10; p++) {
                    var ang = -Math.PI / 2 + p * Math.PI / 5;
                    var rad = p % 2 === 0 ? w * 0.20 : w * 0.085;
                    var x = cx + Math.cos(ang) * rad;
                    var y = cy + Math.sin(ang) * rad;
                    if (p === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                }
                ctx.closePath();
                ctx.fillStyle = A;
                ctx.fill();
            } else if (Theme.arknights) {
                // Rhodes Island diamond with three class chevrons.
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.08);
                ctx.lineTo(w * 0.88, cy);
                ctx.lineTo(cx, h * 0.92);
                ctx.lineTo(w * 0.12, cy);
                ctx.closePath();
                ctx.fillStyle = Theme.alpha(A, 0.12);
                ctx.fill();
                ctx.strokeStyle = A;
                ctx.lineWidth = 1.6;
                ctx.stroke();
                ctx.strokeStyle = Theme.alpha(A, 0.75);
                ctx.lineWidth = 1.3;
                for (var q = 0; q < 3; q++) {
                    var yy2 = h * (0.38 + q * 0.11);
                    ctx.beginPath();
                    ctx.moveTo(w * 0.30, yy2);
                    ctx.lineTo(cx, yy2 + h * 0.09);
                    ctx.lineTo(w * 0.70, yy2);
                    ctx.stroke();
                }
                ctx.fillStyle = A;
                ctx.fillRect(cx - 1, h * 0.22, 2, 4);
            } else if (Theme.preset === "sangvis") {
                // Sangvis hostile eye inside an inverted warning triangle.
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.90);
                ctx.lineTo(w * 0.10, h * 0.16);
                ctx.lineTo(w * 0.90, h * 0.16);
                ctx.closePath();
                ctx.fillStyle = Theme.alpha(A, 0.12);
                ctx.fill();
                ctx.strokeStyle = A;
                ctx.lineWidth = 1.5;
                ctx.stroke();
                ctx.beginPath(); ctx.ellipse(cx, cy * 0.95, w * 0.24, h * 0.10, 0, 0, Math.PI * 2); ctx.stroke();
                ctx.beginPath(); ctx.arc(cx, cy * 0.95, 2.4, 0, Math.PI * 2); ctx.fillStyle = A; ctx.fill();
            } else if (Theme.preset === "neural") {
                // Neural network lattice.
                var nodes = [[0.5, 0.16], [0.22, 0.38], [0.78, 0.38], [0.36, 0.70], [0.64, 0.70], [0.5, 0.90]];
                ctx.strokeStyle = Theme.alpha(B, 0.55);
                ctx.lineWidth = 1;
                for (var n = 0; n < nodes.length; n++) {
                    for (var m = n + 1; m < nodes.length; m++) {
                        if ((n + m) % 3 !== 0) continue;
                        ctx.beginPath();
                        ctx.moveTo(nodes[n][0] * w, nodes[n][1] * h);
                        ctx.lineTo(nodes[m][0] * w, nodes[m][1] * h);
                        ctx.stroke();
                    }
                }
                for (var z = 0; z < nodes.length; z++) {
                    ctx.beginPath(); ctx.arc(nodes[z][0] * w, nodes[z][1] * h, 2.2, 0, Math.PI * 2);
                    ctx.fillStyle = A; ctx.fill();
                }
            } else if (Theme.preset === "arctic") {
                // Compass rose.
                ctx.strokeStyle = Theme.alpha(A, 0.7);
                ctx.lineWidth = 1;
                ctx.beginPath(); ctx.arc(cx, cy, w * 0.34, 0, Math.PI * 2); ctx.stroke();
                ctx.strokeStyle = A;
                ctx.lineWidth = 1.3;
                for (var d = 0; d < 8; d++) {
                    var aa = d * Math.PI / 4;
                    var len = d % 2 === 0 ? w * 0.40 : w * 0.26;
                    ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(cx + Math.cos(aa) * len, cy + Math.sin(aa) * len); ctx.stroke();
                }
                ctx.fillStyle = A;
                ctx.beginPath(); ctx.arc(cx, cy, 2.5, 0, Math.PI * 2); ctx.fill();
            } else {
                // GFL fallback shield (the actual G&K icon is used by EmblemBlock).
                ctx.beginPath();
                ctx.moveTo(cx, h * 0.08);
                ctx.lineTo(w * 0.86, h * 0.24);
                ctx.lineTo(w * 0.78, h * 0.72);
                ctx.lineTo(cx, h * 0.92);
                ctx.lineTo(w * 0.22, h * 0.72);
                ctx.lineTo(w * 0.14, h * 0.24);
                ctx.closePath();
                ctx.strokeStyle = A; ctx.lineWidth = 1.5; ctx.stroke();
                ctx.beginPath(); ctx.moveTo(cx, h * 0.26); ctx.lineTo(cx, h * 0.70); ctx.stroke();
            }
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: Theme
            function onPresetChanged() { canvas.requestPaint(); }
            function onAccentChanged() { canvas.requestPaint(); }
            function onAccent2Changed() { canvas.requestPaint(); }
        }
        Connections {
            target: root
            function onAccentChanged() { canvas.requestPaint(); }
            function onAccent2Changed() { canvas.requestPaint(); }
            function onActiveChanged() { canvas.requestPaint(); }
        }
    }
}
