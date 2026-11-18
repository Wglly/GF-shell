import QtQuick
import "SgStyle.js" as Sg
import qs.modules.common

// SgToggle — 黑灰轨道；开启为黄色。
Item {
    id: root

    property bool checked: false
    signal toggled()

    readonly property bool hovered: mouse.containsMouse
    implicitWidth: Theme.px(46)
    implicitHeight: Theme.px(24)

    Rectangle {
        anchors.fill: parent
        color: root.checked ? Sg.yellow : (root.hovered ? Sg.grayHi : Sg.gray)
        border.width: 1
        border.color: root.checked ? Sg.ink : Sg.ink
    }

    Rectangle {
        x: root.checked ? parent.width - width - Theme.px(4) : Theme.px(4)
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.px(14)
        height: width
        color: root.checked ? Sg.ink : "#e9e5da"
        Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
