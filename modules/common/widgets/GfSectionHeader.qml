import QtQuick
import qs.modules.common

// GfSectionHeader — 少前式标题：金色方块 + 窄体白字 + 金色分隔线。
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string meta: ""
    property string code: ""
    property color accentColor: Theme.accent
    property bool rule: true
    property bool band: false

    implicitHeight: Theme.px(40)
    implicitWidth: Theme.px(240)

    // 可选黑色标题带
    Rectangle {
        visible: root.band
        anchors.fill: parent
        color: Theme.alpha(Theme.bg0, 0.55)
    }

    Rectangle {
        id: block
        x: 0
        y: Theme.px(5)
        width: Theme.px(4)
        height: Theme.px(20)
        color: root.accentColor
    }

    Column {
        anchors.left: block.right
        anchors.leftMargin: Theme.px(10)
        anchors.verticalCenter: parent.verticalCenter
        spacing: -Theme.px(2)

        GfText {
            text: root.title.toUpperCase()
            role: "display"
            size: Theme.sizeLarge
            tracking: Theme.trackWide + 0.6
            bold: true
            color: Theme.text
        }

        GfText {
            visible: root.subtitle !== ""
            text: root.subtitle
            role: "ui"
            size: Theme.sizeTiny
            tone: "faint"
            tracking: 1.6
        }
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.px(8)

        GfText {
            visible: root.meta !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.meta
            role: "mono"
            size: Theme.sizeTiny
            tone: "faint"
        }

        Rectangle {
            visible: root.code !== ""
            width: Math.max(Theme.px(40), codeText.implicitWidth + Theme.px(10))
            height: Theme.px(18)
            color: "transparent"
            border.width: 1
            border.color: Theme.lineColor(Theme.alpha(root.accentColor, 0.7))

            GfText {
                id: codeText
                anchors.centerIn: parent
                text: root.code
                role: "mono"
                size: Theme.sizeTiny - 1
                color: root.accentColor
            }
        }
    }

    // 金色分隔线（主）+ 一条更细的白线
    Rectangle {
        visible: root.rule
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.alpha(Theme.accent, 0.45)
    }
    Rectangle {
        visible: root.rule
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -3
        width: parent.width
        height: 1
        color: Theme.alpha(Theme.text, 0.06)
    }
}
