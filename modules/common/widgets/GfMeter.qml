import QtQuick
import qs.modules.common

// GfMeter — 分段读数条（少前资源/状态条风格）。
Item {
    id: root

    property real value: 0
    property int segments: 10
    property color color: Theme.accent
    property bool vertical: false
    property real segmentGap: 2
    property real segmentThickness: root.vertical ? Theme.px(3) : Theme.px(4)

    implicitWidth: root.vertical ? Theme.px(10) : Theme.px(80)
    implicitHeight: root.vertical ? Theme.px(28) : Theme.px(10)

    readonly property int filled: Math.round(Math.max(0, Math.min(1, root.value)) * root.segments)

    Row {
        visible: !root.vertical
        anchors.fill: parent
        spacing: root.segmentGap
        Repeater {
            model: root.segments
            delegate: Rectangle {
                width: Math.max(1, (root.width - (root.segments - 1) * root.segmentGap) / root.segments)
                height: root.height
                color: index < root.filled ? root.color : Theme.alpha(Theme.text, 0.12)
                opacity: index < root.filled ? 1 : 0.9
            }
        }
    }

    Column {
        visible: root.vertical
        anchors.fill: parent
        spacing: root.segmentGap
        Repeater {
            model: root.segments
            delegate: Rectangle {
                width: root.width
                height: Math.max(1, (root.height - (root.segments - 1) * root.segmentGap) / root.segments)
                color: index >= root.segments - root.filled ? root.color : Theme.alpha(Theme.text, 0.12)
            }
        }
    }
}
