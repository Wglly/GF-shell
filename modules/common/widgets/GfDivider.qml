import QtQuick
import qs.modules.common

// GfDivider — 金色细线，两端带刻度。
Item {
    id: root

    property color color: Theme.alpha(Theme.accent, 0.3)
    property bool vertical: false

    implicitHeight: root.vertical ? Theme.px(24) : 1
    implicitWidth: root.vertical ? 1 : Theme.px(100)

    Rectangle {
        visible: !root.vertical
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 1
        color: root.color
    }

    Rectangle {
        visible: root.vertical
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height
        width: 1
        color: root.color
    }

    Rectangle {
        visible: !root.vertical
        width: 1
        height: 5
        y: -2
        color: root.color
    }
    Rectangle {
        visible: !root.vertical
        x: parent.width - 1
        width: 1
        height: 5
        y: -2
        color: root.color
    }
}
