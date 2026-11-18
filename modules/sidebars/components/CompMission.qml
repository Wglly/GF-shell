import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: Theme.px(3)

    GfText {
        text: I18n.t("hud.currentMission")
        role: "mono"; size: Theme.sizeTiny - 1
        color: Theme.accent; tracking: 1.4
    }
    GfText {
        text: "OPERATION NIGHTFALL"
        role: "display"; size: Theme.sizeMedium
        tracking: 1.6; bold: true
    }
    GfText {
        width: parent.width
        text: I18n.t("hud.missionDesc")
        role: "ui"; size: Theme.sizeTiny; tone: "dim"
        wrapMode: Text.Wrap
    }
    Rectangle {
        width: parent.width; height: 4
        color: Theme.alpha(Theme.text, 0.12)
        Rectangle {
            width: parent.width * 0.42
            height: 4
            color: Theme.accent
        }
    }
    GfText {
        text: "OP-825   ·   " + I18n.t("hud.priorityHigh")
        role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
    }
}
