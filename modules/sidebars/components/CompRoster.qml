import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: Theme.px(3)

    GfText {
        text: I18n.t("sidebar.roster")
        role: "mono"; size: Theme.sizeTiny - 1
        color: Theme.accent; tracking: 1.4
    }

    Repeater {
        model: [
            { id: "ECHO-01", role: "VANGUARD", state: "READY" },
            { id: "ECHO-02", role: "SUPPORT", state: "READY" },
            { id: "ECHO-03", role: "RECON", state: "STANDBY" }
        ]
        delegate: Item {
            required property var modelData
            width: parent.width
            height: Theme.px(22)
            Rectangle {
                anchors.fill: parent
                color: mouse.containsMouse ? Theme.alpha(Theme.accent, 0.12) : "transparent"
            }
            Rectangle {
                x: 0; y: Theme.px(5)
                width: 2; height: parent.height - Theme.px(10)
                color: modelData.state === "READY" ? Theme.accent : Theme.textFaint
            }
            Row {
                anchors.left: parent.left; anchors.leftMargin: Theme.px(8)
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.px(6)
                GfText { text: modelData.id; role: "mono"; size: Theme.sizeTiny - 1; color: Theme.text; width: Theme.px(62) }
                GfText { text: modelData.role; role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"; width: Theme.px(70) }
                GfText { text: modelData.state; role: "mono"; size: Theme.sizeTiny - 2; color: modelData.state === "READY" ? Theme.alpha(Theme.accent, 0.8) : Theme.textFaint }
            }
            MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
        }
    }
}
