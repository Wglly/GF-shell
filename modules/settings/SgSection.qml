import QtQuick
import "SgStyle.js" as Sg
import qs.modules.common

// SgSection — 黑底白字分区带。
Rectangle {
    id: root

    property string number: ""
    property string title: ""
    property string note: ""

    implicitHeight: Theme.fpx(28)
    color: Sg.ink

    Rectangle {
        x: 0
        y: 0
        width: Theme.fpx(4)
        height: parent.height
        color: Sg.yellow
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
            color: Sg.yellow
        }
        Text {
            text: root.title
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(11)
            font.letterSpacing: Theme.fpx(2)
            font.bold: true
            color: Sg.paper
        }
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: Theme.fpx(10)
        anchors.verticalCenter: parent.verticalCenter
        text: root.note
        font.family: Theme.fontMono
        font.pixelSize: Theme.fs(9)
        color: "#b9b2a4"
    }
}
