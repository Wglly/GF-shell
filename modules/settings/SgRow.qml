import QtQuick
import "SgStyle.js" as Sg
import qs.modules.common

// SgRow — 设置行：左侧标签/说明，右侧控件。
Item {
    id: root

    property string label: ""
    property string desc: ""
    property bool last: false
    property int controlWidth: Theme.px(250)
    default property alias content: slot.data

    implicitHeight: Theme.px(52)

    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: slot.left
        anchors.rightMargin: Theme.px(12)
        spacing: 1

        Text {
            text: root.label
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(13)
            font.bold: true
            color: Sg.ink
        }
        Text {
            width: parent.width
            text: root.desc
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(9)
            color: Sg.mute
            elide: Text.ElideRight
        }
    }

    Item {
        id: slot
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.controlWidth
        height: childrenRect.height
    }

    Rectangle {
        visible: !root.last
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Sg.ink
        opacity: 0.18
    }
}
