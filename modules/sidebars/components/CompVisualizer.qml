import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: Theme.px(4)

    Row {
        width: parent.width
        GfText {
            text: I18n.t("hud.audioSpectrum")
            role: "mono"; size: Theme.sizeTiny - 1
            color: Theme.accent; tracking: 1.4
        }
        Item { width: parent.width - 150; height: 1 }
        GfText {
            text: Visualizer.active ? "LIVE" : "IDLE"
            role: "mono"; size: Theme.sizeTiny - 2
            color: Theme.alpha(Theme.accent2, 0.8)
        }
    }
    VisualizerBars {
        width: parent.width
        height: Theme.px(40)
        count: 40
        color: Theme.accent
    }
    GfText {
        visible: !Visualizer.active
        text: I18n.t("hud.noAudio")
        role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
    }
}
