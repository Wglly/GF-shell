import QtQuick
import "SgStyle.js" as Sg
import qs.modules.common

// SgToggle — 黑灰轨道；开启为黄色。
Item {
    id: root

    property bool checked: false
    signal toggled()

    readonly property bool hovered: mouse.containsMouse
    implicitWidth: Theme.fpx(46)
    implicitHeight: Theme.fpx(24)

    Rectangle {
        anchors.fill: parent
        color: root.checked ? Sg.yellow : (root.hovered ? Sg.grayHi : Sg.gray)
        border.width: 1
        border.color: Theme.lineColor(root.checked ? Sg.ink : Sg.ink)
        radius: Theme.bf1 ? height / 2 : 0
    }

    Rectangle {
        x: root.checked ? parent.width - width - Theme.fpx(4) : Theme.fpx(4)
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.fpx(14)
        height: width
        color: root.checked ? Sg.ink : "#e9e5da"
        radius: Theme.bf1 ? width / 2 : 0
        Behavior on x { NumberAnimation { duration: Theme.dur(120); easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
