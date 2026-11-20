import QtQuick
import qs.modules.common
import qs.modules.common.widgets

// SetSection — 设置页的分区标题。
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string code: ""

    implicitHeight: Theme.fpx(30)
    width: parent ? parent.width : Theme.fpx(400)

    Rectangle {
        width: Theme.fpx(2)
        height: Theme.fpx(12)
        y: Theme.fpx(4)
        color: Theme.accent
    }

    GfText {
        x: Theme.fpx(8)
        anchors.verticalCenter: parent.verticalCenter
        text: root.title.toUpperCase()
        role: "label"
        size: Theme.sizeSmall
        tracking: 2
        bold: true
        color: Theme.accentHi
    }

    GfText {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.subtitle
        role: "ui"
        size: Theme.sizeTiny
        tone: "faint"
    }
}
