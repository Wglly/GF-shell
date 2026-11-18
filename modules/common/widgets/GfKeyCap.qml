import QtQuick
import qs.modules.common

// GfKeyCap — 键帽：黑底金框的等宽标签。
Item {
    id: root

    property string label: ""

    implicitWidth: cap.implicitWidth + Theme.px(12)
    implicitHeight: Theme.px(17)

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.bg0, 0.75)
        border.width: 1
        border.color: Theme.alpha(Theme.accent, 0.45)
    }

    GfText {
        id: cap
        anchors.centerIn: parent
        text: root.label
        role: "mono"
        size: Theme.sizeTiny - 1
        color: Theme.textDim
        tracking: 0.6
    }
}
