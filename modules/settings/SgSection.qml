import QtQuick
import qs.modules.common

// SgSection — 黑底白字分区带。
Rectangle {
    id: root

    property string number: ""
    property string title: ""
    property string note: ""

    implicitHeight: Theme.fpx(28)
    color: Theme.sgBand
    radius: Theme.bf1 ? Theme.px(4) : 0

    Rectangle {
        x: 0
        y: 0
        width: Theme.fpx(4)
        height: parent.height
        color: Theme.sgAccent
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.fpx(12)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.fpx(8)

        Text {
            text: root.number
            font.family: Theme.fontMono
            font.pixelSize: Theme.fs(10)
            color: Theme.sgAccent
        }
        Text {
            text: root.title
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(11)
            font.letterSpacing: Theme.fpx(2)
            font.bold: true
            color: Theme.sgBandText
        }
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: Theme.fpx(10)
        anchors.verticalCenter: parent.verticalCenter
        text: root.note
        font.family: Theme.fontMono
        font.pixelSize: Theme.fs(9)
        color: Theme.alpha(Theme.sgBandText, 0.62)
    }
}
