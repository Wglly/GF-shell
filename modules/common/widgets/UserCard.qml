import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// UserCard — theme-aware personnel card shared by bar popup, sidebar and desktop.
// GFL / neutral themes keep the operator dossier; HoI4, Battlefield and Arknights
// swap in their own layouts. All instances update with the selected theme.
Column {
    id: root

    property bool compact: false
    property bool showActions: true
    spacing: Theme.fpx(8)

    UserCardGeneric {
        visible: !(Theme.hoi4 || Theme.battle || Theme.arknights)
        width: parent.width
        compact: root.compact
    }
    UserCardLeader {
        visible: Theme.hoi4
        width: parent.width
        compact: root.compact
    }
    UserCardSoldier {
        visible: Theme.battle
        width: parent.width
        compact: root.compact
    }
    UserCardRhodes {
        visible: Theme.arknights
        width: parent.width
        compact: root.compact
    }

    Row {
        visible: root.showActions
        width: parent.width
        spacing: Theme.fpx(6)

        GfButton {
            width: (parent.width - Theme.fpx(18)) / 4
            height: Theme.fpx(30)
            text: I18n.t("user.deploy")
            checked: true
            onClicked: {
                ShellState.closePopup();
                ShellState.closeSidebars();
                ShellState.open("launcher");
            }
        }
        GfButton {
            width: (parent.width - Theme.fpx(18)) / 4
            height: Theme.fpx(30)
            text: I18n.t("user.tact")
            onClicked: {
                ShellState.closePopup();
                ShellState.closeSidebars();
                ShellState.openPopup("control", 0, 0, "");
            }
        }
        GfButton {
            width: (parent.width - Theme.fpx(18)) / 4
            height: Theme.fpx(30)
            text: I18n.t("user.config")
            onClicked: {
                ShellState.closePopup();
                ShellState.closeSidebars();
                ShellState.open("settings");
            }
        }
        GfButton {
            width: (parent.width - Theme.fpx(18)) / 4
            height: Theme.fpx(30)
            text: I18n.t("user.halt")
            danger: true
            onClicked: {
                ShellState.closePopup();
                ShellState.closeSidebars();
                ShellState.open("power");
            }
        }
    }
}
