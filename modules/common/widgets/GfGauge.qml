import QtQuick
import qs.modules.common

// GfGauge — 分段环形仪表（HUD 风格）。比连续圆弧更像少前的雷达刻度。
Item {
    id: root

    property real value: 0
    property color color: Theme.accent
    property color trackColor: Theme.alpha(Theme.lineBright, 0.25)
    property int segments: 26
    property real startAngle: 135
    property real sweep: 270
    property real thickness: Theme.px(2)
    property real segmentLength: Theme.px(6)
    property real innerRadius: Math.min(width, height) / 2 - Theme.px(3)

    implicitWidth: Theme.px(44)
    implicitHeight: Theme.px(44)

    readonly property int filled: Math.round(Math.max(0, Math.min(1, root.value)) * root.segments)

    Repeater {
        model: root.segments

        delegate: Item {
            width: root.width
            height: root.height
            anchors.centerIn: parent
            rotation: root.startAngle + (index + 0.5) * (root.sweep / root.segments) + 90

            Rectangle {
                x: root.width / 2 - width / 2
                y: root.height / 2 - root.innerRadius - root.thickness
                width: root.thickness
                height: root.segmentLength
                color: index < root.filled ? root.color : root.trackColor
            }
        }
    }
}
