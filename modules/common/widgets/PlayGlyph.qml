import QtQuick
import QtQuick.Shapes
import qs.modules.common

// PlayGlyph — 自绘播放/暂停图标（图标字体没有这两个字形）。
Item {
    id: root

    property bool playing: false
    property color color: Theme.text
    property real glyphSize: Theme.px(14)

    implicitWidth: glyphSize
    implicitHeight: glyphSize

    // 暂停：两条竖条
    Row {
        anchors.centerIn: parent
        spacing: Math.max(2, root.glyphSize * 0.18)
        visible: root.playing

        Repeater {
            model: 2
            Rectangle {
                width: Math.max(2, root.glyphSize * 0.22)
                height: root.glyphSize * 0.72
                color: root.color
            }
        }
    }

    // 播放：实心三角
    Shape {
        anchors.centerIn: parent
        width: root.glyphSize * 0.86
        height: root.glyphSize * 0.86
        visible: !root.playing
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathPolyline {
                path: [
                    Qt.point(width * 0.18, height * 0.10),
                    Qt.point(width * 0.18, height * 0.90),
                    Qt.point(width * 0.92, height * 0.50)
                ]
            }
        }
    }
}
