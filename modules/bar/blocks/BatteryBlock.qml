import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// BatteryBlock — 电量，低电时转红。
Item {
    id: root

    implicitWidth: row.implicitWidth + Theme.px(10)
    implicitHeight: Theme.barHeight
    visible: Battery.present

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(4)

        GfIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: Battery.glyph
            iconSize: Theme.px(15)
            color: Battery.critical ? Theme.red : Theme.textDim
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: Battery.label
            role: "mono"
            size: Theme.sizeTiny
            color: Battery.critical ? Theme.red : Theme.textDim
            width: Theme.px(28)
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.toggle("control")
    }
}
