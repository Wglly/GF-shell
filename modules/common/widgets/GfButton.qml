import QtQuick
import qs.modules.common

// GfButton — 少前式按钮：切角、金色描边，选中时整块金色反白（黑字）。
Item {
    id: root

    property string text: ""
    property string icon: ""
    property string meta: ""
    property bool checked: false
    property bool primary: false
    property bool danger: false
    property bool flat: false
    property bool compact: false
    property bool square: false
    property color accentColor: root.danger ? Theme.red : Theme.accent

    signal clicked()

    readonly property bool hovered: mouse.containsMouse
    readonly property bool down: mouse.pressed

    implicitHeight: root.compact ? Theme.px(24) : Theme.px(30)
    implicitWidth: root.square ? root.implicitHeight
        : Math.max(Theme.px(44), row.implicitWidth + Theme.px(22))

    GfFrame {
        anchors.fill: parent
        chamfer: Theme.px(6)
        cutTopLeft: false
        cutTopRight: true
        cutBottomLeft: true
        cutBottomRight: false
        innerLine: false
        padding: 0
        brackets: false
        fill: {
            if (root.checked)
                return root.accentColor;
            if (root.down)
                return Theme.alpha(root.accentColor, 0.3);
            if (root.hovered)
                return Theme.alpha(root.accentColor, 0.15);
            return root.flat ? Theme.alpha(Theme.bg0, 0.35) : Theme.alpha(Theme.panelAlt, 0.9);
        }
        borderColor: root.checked ? Theme.accentHi
            : (root.danger ? Theme.alpha(Theme.red, 0.6) : Theme.alpha(root.accentColor, 0.55))
    }

    // 左侧小刻度
    Rectangle {
        x: Theme.px(3)
        y: Theme.px(6)
        width: 2
        height: parent.height - Theme.px(12)
        color: root.checked ? Theme.ink : root.accentColor
        opacity: root.checked ? 0.7 : (root.hovered ? 1.0 : 0.55)
    }

    Row {
        id: row
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: Theme.px(2)
        spacing: Theme.px(7)

        GfIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            name: root.icon
            iconSize: root.compact ? Theme.px(13) : Theme.px(15)
            color: root.checked ? Theme.ink : (root.hovered ? Theme.accentHi : Theme.text)
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            text: root.text.toUpperCase()
            role: "label"
            tracking: 1.8
            bold: true
            size: root.compact ? Theme.sizeSmall : Theme.sizeNormal
            color: root.checked ? Theme.ink : (root.hovered ? Theme.text : Theme.textDim)
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.meta !== ""
            text: root.meta
            role: "mono"
            size: Theme.sizeTiny
            color: root.checked ? Theme.alpha(Theme.ink, 0.7) : Theme.textFaint
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: root.enabled
        onClicked: root.clicked()
    }
}
