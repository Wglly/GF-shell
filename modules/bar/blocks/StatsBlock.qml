import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// StatsBlock — CPU / MEM 资源式读数（少前右上角资源栏的排布）。
Item {
    id: root

    implicitWidth: Theme.px(112)
    implicitHeight: Theme.barHeight

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: Theme.px(18)
        color: Theme.alpha(Theme.accent, 0.3)
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: Theme.px(9)
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Row {
            spacing: Theme.px(6)

            GfText {
                anchors.verticalCenter: parent.verticalCenter
                text: "CPU"
                role: "label"
                size: Theme.sizeTiny - 2
                tracking: 1.2
                color: Theme.alpha(Theme.accent, 0.85)
                width: Theme.px(22)
            }

            GfMeter {
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.px(40)
                height: Theme.px(4)
                value: Stats.cpu
                segments: 8
                segmentGap: 1
                color: Stats.cpu > 0.85 ? Theme.red : Theme.accent
            }

            GfText {
                anchors.verticalCenter: parent.verticalCenter
                text: Util.pad2(Math.round(Stats.cpu * 100))
                role: "mono"
                size: Theme.sizeTiny - 2
                color: Theme.textDim
            }
        }

        Row {
            spacing: Theme.px(6)

            GfText {
                anchors.verticalCenter: parent.verticalCenter
                text: "MEM"
                role: "label"
                size: Theme.sizeTiny - 2
                tracking: 1.2
                color: Theme.alpha(Theme.accent, 0.85)
                width: Theme.px(22)
            }

            GfMeter {
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.px(40)
                height: Theme.px(4)
                value: Stats.mem
                segments: 8
                segmentGap: 1
                color: Stats.mem > 0.9 ? Theme.red : Theme.accent2
            }

            GfText {
                anchors.verticalCenter: parent.verticalCenter
                text: Util.pad2(Math.round(Stats.mem * 100))
                role: "mono"
                size: Theme.sizeTiny - 2
                color: Theme.textDim
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.accent
        visible: ShellState.popupKind === "stats"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var p = root.mapToItem(null, root.width / 2, root.height);
            ShellState.togglePopup("stats", p.x, p.y, "");
        }
    }
}
