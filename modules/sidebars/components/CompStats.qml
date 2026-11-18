import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: Theme.px(6)

    GfText {
        text: I18n.t("hud.vitals")
        role: "mono"; size: Theme.sizeTiny - 1
        color: Theme.accent; tracking: 1.4
    }

    Repeater {
        model: [
            { k: "CPU", v: Stats.cpu, c: Stats.cpu > 0.85 ? Theme.red : Theme.accent, t: Math.round(Stats.cpu * 100) + "%" },
            { k: "MEM", v: Stats.mem, c: Theme.accent, t: Util.gib(Stats.memUsed) + "/" + Util.gib(Stats.memTotal) + "G" },
            { k: "NET", v: Math.min(1, Stats.netRx / (12 * 1024 * 1024)), c: Theme.accent2, t: Util.bytesHuman(Stats.netRx) },
            { k: "DISK", v: Stats.diskRatio, c: Theme.accent, t: Math.round(Stats.diskRatio * 100) + "%" }
        ]
        delegate: Item {
            required property var modelData
            width: parent.width
            height: Theme.px(18)
            GfText {
                text: modelData.k
                role: "mono"; size: Theme.sizeTiny - 1
                color: Theme.alpha(Theme.accent, 0.8)
                width: Theme.px(34); anchors.verticalCenter: parent.verticalCenter
            }
            GfMeter {
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.px(38)
                width: parent.width - Theme.px(130)
                height: 4
                value: modelData.v
                segments: 12
                segmentGap: 1
                color: modelData.c
            }
            GfText {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.t
                role: "mono"; size: Theme.sizeTiny - 2
                tone: "faint"
            }
        }
    }

    GfDivider { width: parent.width; color: Theme.alpha(Theme.accent, 0.25) }
    GfText {
        width: parent.width
        text: "UP " + Util.uptimeText(Stats.uptime) + "  ·  LOAD " + Stats.load1.toFixed(2)
        role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
    }
}
