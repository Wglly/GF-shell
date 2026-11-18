import QtQuick
import qs.modules.common
import qs.modules.common.widgets

// SetRow — 设置项的一行：左侧标题/说明，右侧控件。
Item {
    id: root

    property string label: ""
    property string description: ""
    property string code: ""

    default property alias content: slot.data

    implicitHeight: Math.max(Theme.px(38), labelColumn.implicitHeight + Theme.px(10))
    width: parent ? parent.width : Theme.px(400)

    Column {
        id: labelColumn
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.width - Theme.px(230)
        spacing: 0

        Row {
            spacing: Theme.px(6)
            GfText {
                text: root.label
                role: "ui"
                size: Theme.sizeNormal
                color: Theme.text
            }
            GfText {
                visible: root.code !== ""
                text: root.code
                role: "mono"
                size: Theme.sizeTiny - 1
                tone: "faint"
            }
        }

        GfText {
            visible: root.description !== ""
            width: parent.width
            text: root.description
            role: "ui"
            size: Theme.sizeTiny - 1
            tone: "faint"
            elide: Text.ElideRight
        }
    }

    Item {
        id: slot
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(Theme.px(252), childrenRect.width)
        height: childrenRect.height
    }

    GfDivider {
        anchors.bottom: parent.bottom
        width: parent.width
        color: Theme.alpha(Theme.lineBright, 0.18)
    }
}
