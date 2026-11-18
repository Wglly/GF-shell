import QtQuick
import QtQuick.Shapes
import qs.modules.common

// GfTab — 斜切页签（少前工作区/分类标签）：选中时整块金色 + 黑字。
Item {
    id: root

    property string text: ""
    property string number: ""
    property bool checked: false
    property real skew: Theme.px(8)

    signal clicked()

    implicitWidth: Math.max(Theme.px(46), label.implicitWidth + Theme.px(22) + root.skew)
    implicitHeight: Theme.px(26)

    readonly property bool hovered: mouse.containsMouse

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 1
            strokeColor: root.checked ? Theme.accentHi : Theme.alpha(Theme.accent, root.hovered ? 0.85 : 0.45)
            fillColor: root.checked ? Theme.accent
                : (root.hovered ? Theme.alpha(Theme.accent, 0.18) : Theme.alpha(Theme.bg0, 0.8))
            PathPolyline {
                path: [
                    Qt.point(0, 0),
                    Qt.point(root.width - root.skew, 0),
                    Qt.point(root.width, root.height),
                    Qt.point(root.skew, root.height)
                ]
            }
        }
    }

    Rectangle {
        visible: root.checked
        x: root.skew + Theme.px(4)
        y: 0
        width: Math.max(0, root.width - root.skew * 2 - Theme.px(8))
        height: 1
        color: Theme.alpha(Theme.ink, 0.5)
    }

    Row {
        id: label
        anchors.centerIn: parent
        spacing: Theme.px(6)

        GfText {
            visible: root.number !== ""
            text: root.number
            role: "mono"
            size: Theme.sizeTiny - 1
            color: root.checked ? Theme.alpha(Theme.ink, 0.75) : Theme.textDim
        }

        GfText {
            text: root.text.toUpperCase()
            role: "display"
            size: Theme.sizeMedium
            tracking: 1.8
            bold: true
            color: root.checked ? Theme.ink : (root.hovered ? Theme.text : Theme.textDim)
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
