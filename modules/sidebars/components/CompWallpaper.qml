import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// CompWallpaper — compact wallpaper library for the left/right sidebar.
Column {
    id: root
    width: parent ? parent.width : Theme.fpx(320)
    spacing: Theme.fpx(8)

    GfText {
        text: I18n.t("sb.wallpaper")
        role: "label"
        size: Theme.sizeTiny
        color: Theme.accent
        tracking: 1.6
    }

    Rectangle {
        width: parent.width
        height: Theme.fpx(86)
        color: Theme.alpha(Theme.bg0, 0.5)
        border.width: 1
        border.color: Theme.alpha(Theme.accent, 0.5)

        Image {
            anchors.fill: parent
            anchors.margins: 1
            source: Wallpapers.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
        GfText {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: Theme.fpx(6)
            text: Wallpapers.currentName
            role: "mono"; size: Theme.sizeTiny - 1
            color: Theme.text
        }
    }

    Repeater {
        model: Wallpapers.all

        delegate: Item {
            required property var modelData
            width: parent.width
            height: Theme.fpx(28)

            Rectangle {
                anchors.fill: parent
                color: wallMouse.containsMouse || Wallpapers.selected === modelData.path
                    ? Theme.alpha(Theme.accent, 0.14) : "transparent"
            }
            GfText {
                anchors.left: parent.left
                anchors.leftMargin: Theme.fpx(6)
                anchors.right: parent.right
                anchors.rightMargin: Theme.fpx(6)
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.name
                role: "mono"; size: Theme.sizeTiny - 1
                color: Wallpapers.selected === modelData.path ? Theme.accent : Theme.textDim
                elide: Text.ElideRight
            }
            MouseArea {
                id: wallMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Wallpapers.choosePath(modelData.path)
            }
        }
    }

    Row {
        spacing: Theme.fpx(6)
        GfButton {
            compact: true; height: Theme.fpx(26)
            text: I18n.t("sb.randomWallpaper")
            onClicked: Wallpapers.randomise()
        }
        GfButton {
            compact: true; height: Theme.fpx(26)
            text: "REFRESH"
            onClicked: Wallpapers.refresh()
        }
    }
}
