import QtQuick
import QtQuick.Shapes
import qs.modules.common

// GfRibbon — 少前标签缎带：黑色斜切底 + 彩色图标块 + 白字，可带向下指示三角。
Item {
    id: root

    property string text: ""
    property string icon: ""
    property color blockColor: Theme.accent
    property bool pointer: false

    implicitWidth: Math.max(Theme.px(120), row.implicitWidth + Theme.px(28))
    implicitHeight: Theme.px(24)

    readonly property real cut: Theme.px(9)

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 1
            strokeColor: Theme.alpha(Theme.accent, 0.45)
            fillColor: Theme.alpha(Theme.bg0, 0.82)
            PathPolyline {
                path: [
                    Qt.point(0, 0),
                    Qt.point(root.width - root.cut, 0),
                    Qt.point(root.width, root.height),
                    Qt.point(root.cut, root.height)
                ]
            }
        }
    }

    // 左侧色块
    Rectangle {
        width: Theme.px(22)
        height: parent.height
        color: root.blockColor

        GfIcon {
            anchors.centerIn: parent
            visible: root.icon !== ""
            name: root.icon
            iconSize: Theme.px(13)
            color: Theme.ink
        }
    }

    Row {
        id: row
        anchors.left: parent.left
        anchors.leftMargin: Theme.px(30)
        anchors.right: parent.right
        anchors.rightMargin: root.cut + Theme.px(8)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.px(6)

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            role: "display"
            size: Theme.sizeSmall + 1
            tracking: 1.4
            bold: true
            color: Theme.text
            elide: Text.ElideRight
        }
    }

    // 向下指示三角
    Shape {
        visible: root.pointer
        x: Theme.px(6)
        y: root.height
        width: Theme.px(12)
        height: Theme.px(8)
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 0
            fillColor: Theme.text
            PathPolyline {
                path: [Qt.point(0, 0), Qt.point(12, 0), Qt.point(6, 8)]
            }
        }
    }
}
