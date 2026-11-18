import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// NetBlock — 链路状态：图标 + 信号段 + SSID（空间够时）。
Item {
    id: root

    implicitWidth: row.implicitWidth + Theme.px(12)
    implicitHeight: Theme.barHeight

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(5)

        GfIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: Net.glyph
            iconSize: Theme.px(14)
            color: Net.online ? Theme.accent : Theme.textFaint
        }

        // 四段信号柱
        Row {
            visible: Net.kind === "wifi"
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Repeater {
                model: 4
                Rectangle {
                    width: 2
                    height: 3 + index * 2.5
                    anchors.bottom: parent.bottom
                    color: index < Net.bars ? Theme.accent : Theme.alpha(Theme.text, 0.18)
                }
            }
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: Net.kind === "wifi" && Net.ssid !== "" ? Util.truncate(Net.ssid, 14) : Net.label
            role: "mono"
            size: Theme.sizeTiny
            tone: Net.online ? "dim" : "faint"
            tracking: 0.8
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.toggle("control")
    }
}
