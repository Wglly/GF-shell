import QtQuick
import qs.modules.common

// GfLabel — 小号大写标签：左侧强调刻度 + 追踪字距，少前 HUD 的基础元素。
Item {
    id: root

    property string text: ""
    property string meta: ""
    property color color: Theme.textDim
    property color accentColor: Theme.accent
    property bool tick: true
    property real size: Theme.sizeSmall
    property real tracking: Theme.trackWide

    implicitWidth: row.implicitWidth
    implicitHeight: Math.max(Theme.px(12), label.implicitHeight)

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.px(6)

        Rectangle {
            visible: root.tick
            width: Theme.px(2)
            height: Theme.px(9)
            color: root.accentColor
            anchors.verticalCenter: parent.verticalCenter
        }

        GfText {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: root.text.toUpperCase()
            role: "label"
            tone: "dim"
            color: root.color
            size: root.size
            tracking: root.tracking
            bold: true
        }

        GfText {
            visible: root.meta !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.meta
            role: "mono"
            tone: "faint"
            size: root.size - 1
            tracking: 0.6
        }
    }
}
