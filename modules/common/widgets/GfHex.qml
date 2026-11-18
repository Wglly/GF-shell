import QtQuick
import QtQuick.Shapes
import qs.modules.common

// GfHex — 六边形轮廓（emblem、状态灯、装饰用）。
Item {
    id: root

    property color color: Theme.accent
    property real strokeWidth: 1
    property bool filled: false
    property color fillColor: "transparent"
    property real rotation: 30

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: root.strokeWidth
            strokeColor: root.color
            fillColor: root.filled ? root.fillColor : "transparent"
            PathPolyline {
                path: {
                    var pts = [];
                    var cx = root.width / 2;
                    var cy = root.height / 2;
                    var r = Math.min(root.width, root.height) / 2 - root.strokeWidth;
                    for (var i = 0; i < 6; i++) {
                        var a = (60 * i + root.rotation) * Math.PI / 180;
                        pts.push(Qt.point(cx + r * Math.cos(a), cy + r * Math.sin(a)));
                    }
                    pts.push(pts[0]);
                    return pts;
                }
            }
        }
    }
}
