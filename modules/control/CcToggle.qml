import QtQuick
import qs.modules.common
import qs.modules.common.widgets

// CcToggle — 控制中心的模块开关：黑色金框，开启时整块金色反白。
Item {
    id: root

    property string label: ""
    property string glyph: ""
    property bool active: false

    signal clicked()

    implicitHeight: Theme.px(36)
    implicitWidth: Theme.px(160)

    readonly property bool hovered: mouse.containsMouse

    Rectangle {
        anchors.fill: parent
        color: root.active ? Theme.accent
            : (root.hovered ? Theme.alpha(Theme.accent, 0.16) : Theme.alpha(Theme.bg0, 0.65))
        border.width: 1
        border.color: root.active ? Theme.accentHi : Theme.alpha(Theme.accent, 0.4)
        Behavior on color {
            enabled: Theme.animations
            ColorAnimation { duration: Theme.durFast }
        }
    }

    Rectangle {
        visible: root.active
        x: 0
        y: 0
        width: Theme.px(3)
        height: parent.height
        color: Theme.ink
        opacity: 0.5
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.px(9)
        anchors.rightMargin: Theme.px(9)
        spacing: Theme.px(7)

        GfIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.glyph
            iconSize: Theme.px(14)
            color: root.active ? Theme.ink : Theme.alpha(Theme.accent, 0.85)
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            role: "label"
            size: Theme.sizeTiny + 1
            tracking: 1.2
            bold: root.active
            color: root.active ? Theme.ink : Theme.textDim
            width: parent.width - Theme.px(40)
            elide: Text.ElideRight
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(5)
            height: Theme.px(5)
            rotation: 45
            color: root.active ? Theme.ink : Theme.alpha(Theme.accent, 0.5)
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
