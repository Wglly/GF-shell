import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// WallpaperBlock — current wallpaper entry; expands to the wallpaper library.
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
            name: "wallpaper"
            iconSize: Theme.px(14)
            color: Theme.accent
        }
        GfText {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(108)
            text: Wallpapers.currentName
            role: "mono"
            size: Theme.sizeTiny
            color: Theme.textDim
            elide: Text.ElideRight
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.accent
        visible: ShellState.popupKind === "wallpaper"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Wallpapers.refresh();
            var p = root.mapToItem(null, root.width / 2, root.height);
            ShellState.togglePopup("wallpaper", p.x, p.y, "");
        }
    }
}
