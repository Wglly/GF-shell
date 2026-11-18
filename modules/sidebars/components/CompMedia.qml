import QtQuick
import qs.modules.common
import qs.services
import qs.modules.common.widgets

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: Theme.px(4)

    GfText {
        text: I18n.t("hud.transmission")
        role: "mono"; size: Theme.sizeTiny - 1
        color: Theme.accent; tracking: 1.4
    }
    MediaCard {
        width: parent.width
        showLyrics: true
        showVisualizer: true
        lyricLines: 5
    }
}
