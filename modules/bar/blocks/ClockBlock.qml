import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// ClockBlock — 中央时计：白字窄体 + 金色刻度 + 日期。
Item {
    id: root

    readonly property bool secondsOn: Settings.get("bar.showSeconds", false)
    readonly property bool h24: Settings.get("bar.clock24h", true)

    property date now: new Date()

    implicitWidth: row.implicitWidth + Theme.px(20)
    implicitHeight: Theme.barHeight

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(8)

        // 左刻度
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Repeater {
                model: 3
                Rectangle {
                    width: index === 1 ? Theme.px(9) : Theme.px(5)
                    height: 1
                    color: Theme.alpha(Theme.accent, index === 1 ? 0.95 : 0.4)
                }
            }
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: Util.clockText(root.now, false, true).replace(/ (AM|PM)/, "")
            role: "display"
            size: Theme.sizeLarge
            tracking: 2.8
            bold: true
            color: Theme.text
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            width: Theme.px(24)

            GfText {
                text: root.h24 ? "H24" : (root.now.getHours() >= 12 ? "PM" : "AM")
                role: "mono"
                size: Theme.sizeTiny - 2
                color: Theme.accent
                tracking: 1
            }
            GfText {
                visible: root.secondsOn
                text: Util.pad2(root.now.getSeconds())
                role: "mono"
                size: Theme.sizeTiny
                tone: "faint"
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: Theme.px(14)
            color: Theme.alpha(Theme.accent, 0.3)
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: Util.dateText(root.now, false).replace(/^\w+\s+/, "")
            role: "label"
            size: Theme.sizeTiny
            tracking: 1.8
            tone: "dim"
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: Util.weekday(root.now, false)
            role: "label"
            size: Theme.sizeTiny - 1
            tracking: 1.2
            color: Theme.accent
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Repeater {
                model: 3
                Rectangle {
                    width: index === 1 ? Theme.px(9) : Theme.px(5)
                    height: 1
                    color: Theme.alpha(Theme.accent, index === 1 ? 0.95 : 0.4)
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var p = root.mapToItem(null, root.width / 2, root.height);
            ShellState.togglePopup("calendar", p.x, p.y, "");
        }
    }
}
