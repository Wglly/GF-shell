import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// StatsCard — expanded CPU / memory / load / disk / network details.
Item {
    id: root

    implicitHeight: column.implicitHeight

    function uptimeText(sec) {
        var s = Math.max(0, Math.floor(sec));
        var d = Math.floor(s / 86400);
        var h = Math.floor((s % 86400) / 3600);
        var m = Math.floor((s % 3600) / 60);
        return (d > 0 ? d + "d " : "") + h + "h " + m + "m";
    }

    component InfoRow: Item {
        property string label: ""
        property string value: ""
        width: parent.width
        height: Theme.fpx(17)

        GfText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.fpx(92)
            text: label
            role: "mono"; size: Theme.sizeTiny - 2
            color: Theme.alpha(Theme.accent, 0.8); tracking: 1
        }
        GfText {
            anchors.left: parent.left
            anchors.leftMargin: Theme.fpx(96)
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: value
            role: "mono"; size: Theme.sizeTiny - 1
            color: Theme.text
            elide: Text.ElideRight
        }
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.fpx(6)

        Row {
            width: parent.width
            spacing: Theme.fpx(8)
            GfText { width: Theme.fpx(70); text: "CPU"; role: "mono"; size: Theme.sizeTiny - 2; color: Theme.accent }
            GfMeter {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.fpx(130); height: Theme.fpx(6)
                value: Stats.cpu; segments: 16
                color: Stats.cpu > 0.85 ? Theme.red : Theme.accent
            }
            GfText { text: Math.round(Stats.cpu * 100) + "%"; role: "mono"; size: Theme.sizeTiny - 1; color: Theme.text }
        }
        Row {
            width: parent.width
            spacing: Theme.fpx(8)
            GfText { width: Theme.fpx(70); text: "MEMORY"; role: "mono"; size: Theme.sizeTiny - 2; color: Theme.accent }
            GfMeter {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.fpx(130); height: Theme.fpx(6)
                value: Stats.mem; segments: 16
                color: Stats.mem > 0.9 ? Theme.red : Theme.accent2
            }
            GfText { text: Math.round(Stats.mem * 100) + "%"; role: "mono"; size: Theme.sizeTiny - 1; color: Theme.text }
        }
        Row {
            width: parent.width
            spacing: Theme.fpx(8)
            GfText { width: Theme.fpx(70); text: "SWAP"; role: "mono"; size: Theme.sizeTiny - 2; color: Theme.accent }
            GfMeter {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.fpx(130); height: Theme.fpx(4)
                value: Stats.swapTotal > 0 ? Stats.swapUsed / Stats.swapTotal : 0
                segments: 16
                color: Theme.textFaint
            }
            GfText {
                text: Stats.swapTotal > 0 ? Stats.swapUsed.toFixed(1) + "/" + Stats.swapTotal.toFixed(1) + "G" : "—"
                role: "mono"; size: Theme.sizeTiny - 1; color: Theme.text
            }
        }

        InfoRow { label: "LOAD 1/5/15"; value: Stats.load1.toFixed(2) + " / " + Stats.load5.toFixed(2) + " / " + Stats.load15.toFixed(2) }
        InfoRow { label: "UPTIME"; value: root.uptimeText(Stats.uptime) }
        InfoRow { label: "PROCESSES"; value: "" + Stats.processes }
        InfoRow { label: "MEMORY"; value: Stats.memUsed.toFixed(1) + " / " + Stats.memTotal.toFixed(1) + " GiB" }
        InfoRow { label: "DISK"; value: Stats.diskText(Stats.diskUsed, Stats.diskTotal) }
        InfoRow { label: "NET RX/TX"; value: Stats.rateText(Stats.netRx) + " / " + Stats.rateText(Stats.netTx) }

        GfDivider { width: parent.width; color: Theme.alpha(Theme.accent, 0.3) }

        GfText {
            text: "TOP PROCESSES"
            role: "mono"; size: Theme.sizeTiny - 2
            color: Theme.accent; tracking: 1.4
        }

        Repeater {
            model: Stats.top

            delegate: Row {
                required property var modelData
                width: parent.width
                height: Theme.fpx(16)
                spacing: Theme.fpx(6)

                GfText {
                    width: Theme.fpx(160)
                    text: modelData.name
                    role: "mono"; size: Theme.sizeTiny - 2
                    color: Theme.textDim
                    elide: Text.ElideRight
                }
                GfText {
                    width: Theme.fpx(60)
                    text: "C " + modelData.cpu.toFixed(1) + "%"
                    role: "mono"; size: Theme.sizeTiny - 2
                    color: Theme.text
                }
                GfText {
                    text: "M " + modelData.mem.toFixed(1) + "%"
                    role: "mono"; size: Theme.sizeTiny - 2
                    color: Theme.textFaint
                }
            }
        }
    }
}
