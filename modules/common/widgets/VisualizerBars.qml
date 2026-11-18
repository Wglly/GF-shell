import QtQuick
import qs.modules.common
import qs.services

// VisualizerBars — cava 频谱的密集金条。
Item {
    id: root

    property var bars: Visualizer.bars
    property int count: 32
    property color color: Theme.accent
    property real minHeight: 2

    Row {
        anchors.fill: parent
        spacing: Math.max(1, Theme.px(2))

        Repeater {
            model: root.count

            delegate: Item {
                required property int index
                width: Math.max(1, (root.width - (root.count - 1) * parent.spacing) / root.count)
                height: root.height

                readonly property real v: {
                    if (!root.bars || root.bars.length === 0)
                        return 0;
                    var i = Math.floor(index * root.bars.length / root.count);
                    return root.bars[Math.min(root.bars.length - 1, i)] || 0;
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(root.minHeight, parent.v * root.height)
                    color: parent.v > 0.75 ? Theme.accentHi : root.color
                    opacity: parent.v > 0.02 ? 0.95 : 0.22
                }
            }
        }
    }
}
