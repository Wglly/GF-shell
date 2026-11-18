import QtQuick
import "SgStyle.js" as Sg
import qs.modules.common
import qs.modules.common.widgets

// SgButton — 黑灰按钮：悬停/选中变黄、黑字。
Item {
    id: root

    property string text: ""
    property string icon: ""
    property bool active: false
    property bool danger: false
    property bool compact: false
    signal clicked()

    readonly property bool hovered: mouse.containsMouse
    implicitHeight: Theme.px(root.compact ? 26 : 30)
    implicitWidth: Math.max(Theme.px(56), label.implicitWidth + Theme.px(22))

    Rectangle {
        anchors.fill: parent
        color: root.active || root.hovered ? Sg.yellow
            : (root.danger ? Sg.red : Sg.gray)
        border.width: 1
        border.color: root.active ? Sg.yellowHi : (root.danger ? "#5d1c14" : Sg.ink)
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(6)

        GfIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            name: root.icon
            iconSize: Theme.px(13)
            color: root.active || root.hovered ? Sg.ink : "#f4f1e8"
        }
        Text {
            id: label
            text: root.text
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(root.compact ? 10 : 11)
            font.letterSpacing: Theme.px(1.2)
            font.bold: true
            color: root.active || root.hovered ? Sg.ink : "#f4f1e8"
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Behavior on implicitWidth { NumberAnimation { duration: 100 } }
}
