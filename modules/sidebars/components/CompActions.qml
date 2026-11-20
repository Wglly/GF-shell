import QtQuick
import qs.modules.common
import qs.services
import qs.modules.common.widgets

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: Theme.px(4)

    GfText {
        text: I18n.t("sb.actions")
        role: "mono"; size: Theme.sizeTiny - 1
        color: Theme.accent; tracking: 1.4
    }

    Grid {
        width: parent.width
        columns: 2
        rowSpacing: Theme.px(4)
        columnSpacing: Theme.px(4)

        GfButton {
            width: (parent.width - Theme.px(4)) / 2
            height: Theme.px(30)
            text: I18n.t("user.deploy"); checked: true
            onClicked: { ShellState.closeSidebars(); ShellState.open("launcher") }
        }
        GfButton {
            width: (parent.width - Theme.px(4)) / 2
            height: Theme.px(30)
            text: I18n.t("user.tact")
            onClicked: { ShellState.closeSidebars(); ShellState.openPopup("control", 0, 0, "") }
        }
        GfButton {
            width: (parent.width - Theme.px(4)) / 2
            height: Theme.px(30)
            text: I18n.t("user.config")
            onClicked: { ShellState.closeSidebars(); ShellState.open("settings") }
        }
        GfButton {
            width: (parent.width - Theme.px(4)) / 2
            height: Theme.px(30)
            text: I18n.t("user.halt"); danger: true
            onClicked: { ShellState.closeSidebars(); ShellState.open("power") }
        }
    }
}
