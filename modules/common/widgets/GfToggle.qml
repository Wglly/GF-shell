import QtQuick
import qs.modules.common

// GfToggle — 少前式方角开关：金色细框 + 金色滑块，导通时整块泛金。
Item {
    id: root

    property bool checked: false
    property bool enabledState: true
    property color accentColor: Theme.accent

    signal toggled(bool checked)

    implicitWidth: Theme.px(36)
    implicitHeight: Theme.px(16)

    Rectangle {
        anchors.fill: parent
        color: root.checked ? Theme.alpha(root.accentColor, 0.85) : Theme.alpha(Theme.bg0, 0.6)
        border.width: 1
        border.color: root.checked ? Theme.accentHi : Theme.alpha(root.accentColor, 0.55)
        opacity: root.enabledState ? 1 : 0.45
        Behavior on color {
            enabled: Theme.animations
            ColorAnimation { duration: Theme.durFast }
        }
    }

    Rectangle {
        width: Theme.px(10)
        height: parent.height - Theme.px(6)
        y: Theme.px(3)
        x: root.checked ? parent.width - width - Theme.px(3) : Theme.px(3)
        color: root.checked ? Theme.ink : Theme.textFaint
        Behavior on x {
            enabled: Theme.animations
            NumberAnimation { duration: Theme.durNormal; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: root.enabledState
        onClicked: root.toggled(!root.checked)
    }
}
