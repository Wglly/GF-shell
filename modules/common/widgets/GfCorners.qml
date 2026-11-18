import QtQuick
import QtQuick.Shapes
import qs.modules.common

// GfCorners — 四角括标（"⌐ ¬ ∟ ⌐"），少前界面的标志性装饰。
Item {
    id: root

    property color color: Theme.alpha(Theme.accent, 0.55)
    property real size: Theme.px(10)
    property real thickness: 1
    property real inset: 1
    property bool topLeft: true
    property bool topRight: true
    property bool bottomLeft: true
    property bool bottomRight: true

    function mark(anchorH, anchorV, dx, dy) {
        return [Qt.point(anchorH ? root.inset : root.width - root.inset - root.size, anchorV ? root.inset : root.height - root.inset),
                Qt.point(anchorH ? root.inset : root.width - root.inset, anchorV ? root.inset : root.height - root.inset - root.size)];
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: root.thickness
            strokeColor: root.color
            fillColor: "transparent"
            PathPolyline {
                path: root.topLeft ? [
                    Qt.point(root.inset, root.inset + root.size),
                    Qt.point(root.inset, root.inset),
                    Qt.point(root.inset + root.size, root.inset)
                ] : []
            }
        }
        ShapePath {
            strokeWidth: root.thickness
            strokeColor: root.color
            fillColor: "transparent"
            PathPolyline {
                path: root.topRight ? [
                    Qt.point(root.width - root.inset - root.size, root.inset),
                    Qt.point(root.width - root.inset, root.inset),
                    Qt.point(root.width - root.inset, root.inset + root.size)
                ] : []
            }
        }
        ShapePath {
            strokeWidth: root.thickness
            strokeColor: root.color
            fillColor: "transparent"
            PathPolyline {
                path: root.bottomLeft ? [
                    Qt.point(root.inset, root.height - root.inset - root.size),
                    Qt.point(root.inset, root.height - root.inset),
                    Qt.point(root.inset + root.size, root.height - root.inset)
                ] : []
            }
        }
        ShapePath {
            strokeWidth: root.thickness
            strokeColor: root.color
            fillColor: "transparent"
            PathPolyline {
                path: root.bottomRight ? [
                    Qt.point(root.width - root.inset - root.size, root.height - root.inset),
                    Qt.point(root.width - root.inset, root.height - root.inset),
                    Qt.point(root.width - root.inset, root.height - root.inset - root.size)
                ] : []
            }
        }
    }
}
