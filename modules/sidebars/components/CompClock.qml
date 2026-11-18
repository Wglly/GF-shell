import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: -2

    property date now: new Date()
    Timer { interval: 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.now = new Date() }

    GfText {
        text: Util.clockText(root.now, true, true)
        role: "display"; size: Theme.sizeDisplay; tracking: 1.5; bold: true
    }
    GfText {
        text: Util.dateText(root.now, false)
        role: "mono"; size: Theme.sizeTiny
        color: Theme.alpha(Theme.accent, 0.8); tracking: 1.4
    }
    GfText {
        text: I18n.t("hud.operations")
        role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
    }
}
