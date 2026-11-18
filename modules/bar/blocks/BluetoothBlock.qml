import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// BluetoothBlock — independent Bluetooth link indicator.
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
            name: "bluetooth"
            iconSize: Theme.px(14)
            color: Blue.enabled ? Theme.accent2 : Theme.textFaint
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: Blue.label
            role: "mono"
            size: Theme.sizeTiny
            tone: Blue.enabled ? "dim" : "faint"
            tracking: 0.8
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.accent
        visible: ShellState.popupKind === "bluetooth"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var p = root.mapToItem(null, root.width / 2, root.height);
            ShellState.togglePopup("bluetooth", p.x, p.y, "");
        }
    }
}
