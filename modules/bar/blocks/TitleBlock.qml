import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// TitleBlock — 当前窗口（"单位"）标题。
Item {
    id: root

    readonly property string title: Compositor.windowTitle
    readonly property string appId: Compositor.windowAppId

    implicitWidth: Math.min(Theme.px(300), content.implicitWidth + Theme.px(10))
    implicitHeight: Theme.barHeight
    visible: root.title !== "" && Settings.get("bar.titleMode", "window") !== "hidden"

    GfDivider {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        vertical: true
        height: Theme.px(16)
        color: Theme.alpha(Theme.lineBright, 0.3)
    }

    Row {
        id: content
        anchors.left: parent.left
        anchors.leftMargin: Theme.px(8)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.px(6)

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.appId !== "" ? root.appId.toUpperCase() : "UNIT"
            role: "mono"
            size: Theme.sizeTiny - 1
            tone: "faint"
            tracking: 0.8
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(Theme.px(220), implicitWidth)
            text: root.title
            role: "ui"
            size: Theme.sizeSmall
            tone: "dim"
            elide: Text.ElideRight
        }
    }
}
