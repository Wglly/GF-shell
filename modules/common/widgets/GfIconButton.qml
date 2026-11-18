import QtQuick
import qs.modules.common

// GfIconButton — 方形图标按钮：选中时金色实心 + 黑图标。
Item {
    id: root

    property string icon: ""
    property string tooltip: ""
    property string badge: ""
    property bool checked: false
    property bool danger: false
    property color accentColor: root.danger ? Theme.red : Theme.accent
    property real buttonSize: Theme.px(26)
    property real glyphSize: Theme.px(16)

    signal clicked()

    readonly property bool hovered: mouse.containsMouse

    implicitWidth: root.buttonSize
    implicitHeight: root.buttonSize

    Rectangle {
        anchors.fill: parent
        color: root.checked ? root.accentColor
            : (root.hovered ? Theme.alpha(root.accentColor, 0.16) : "transparent")
        border.width: (root.hovered || root.checked) ? 1 : 0
        border.color: root.checked ? Theme.accentHi : Theme.alpha(root.accentColor, 0.6)
        Behavior on color {
            enabled: Theme.animations
            ColorAnimation { duration: Theme.durFast }
        }
    }

    // 底部小刻度
    Rectangle {
        visible: root.checked || root.hovered
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.px(2)
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.px(8)
        height: 1
        color: root.checked ? Theme.ink : root.accentColor
    }

    GfIcon {
        anchors.centerIn: parent
        name: root.icon
        iconSize: root.glyphSize
        color: root.checked ? Theme.ink : (root.hovered ? Theme.accentHi : Theme.textDim)
    }

    Rectangle {
        visible: root.badge !== ""
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.px(2)
        width: Math.max(5, badgeText.implicitWidth + 4)
        height: 10
        color: Theme.red
        border.width: 1
        border.color: Theme.alpha(Theme.red, 0.6)

        GfText {
            id: badgeText
            anchors.centerIn: parent
            text: root.badge
            role: "mono"
            size: 7
            color: Theme.text
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
