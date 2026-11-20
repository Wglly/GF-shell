import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.modules.common
import qs.modules.common.widgets

// TrayBlock — compact tray entry; expands into icons + messages.
Item {
    id: root

    readonly property var items: SystemTray.items.values
    visible: root.items.length > 0
    implicitWidth: row.implicitWidth + Theme.px(10)
    implicitHeight: Theme.barHeight

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(4)

        GfIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: "expand_more"
            iconSize: Theme.px(13)
            color: hover.containsMouse ? Theme.accentHi : Theme.textDim
        }
        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: "TRAY " + root.items.length
            role: "mono"; size: Theme.sizeTiny
            color: hover.containsMouse ? Theme.accent : Theme.textDim
            tracking: 0.6
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.accent
        visible: ShellState.popupKind === "tray"
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var p = root.mapToItem(null, root.width / 2, root.height);
            ShellState.togglePopup("tray", p.x, p.y, "");
        }
    }
}
