import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// MediaBlock — 正在播放的通讯。没有播放器时显示待机。
Item {
    id: root

    readonly property bool hasMedia: Media.active

    implicitWidth: Theme.px(176)
    implicitHeight: Theme.barHeight

    GfDivider {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        vertical: true
        height: Theme.px(16)
        color: Theme.alpha(Theme.lineBright, 0.3)
    }

    Row {
        id: row
        anchors.left: parent.left
        anchors.leftMargin: Theme.px(8)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.px(6)

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(18)
            height: Theme.px(18)
            color: Theme.alpha(Theme.panelHi, 0.8)

            Image {
                anchors.fill: parent
                visible: root.hasMedia && Media.artUrl !== ""
                source: root.hasMedia ? Media.artUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            GfIcon {
                anchors.centerIn: parent
                visible: !root.hasMedia || Media.artUrl === ""
                name: "graphic_eq"
                iconSize: Theme.px(12)
                color: root.hasMedia ? Theme.accent : Theme.textFaint
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: -Theme.px(1)
            width: Theme.px(118)

            GfText {
                width: parent.width
                text: root.hasMedia ? Media.title : I18n.t("media.commsStandby")
                role: "ui"
                size: Theme.sizeSmall
                color: root.hasMedia ? Theme.text : Theme.textFaint
                elide: Text.ElideRight
            }

            GfText {
                width: parent.width
                text: root.hasMedia
                    ? (Lyrics.current !== "" ? Lyrics.current
                        : (Media.artist !== "" ? Media.artist : Media.sourceLabel))
                    : I18n.t("media.noTransmission")
                role: "mono"
                size: Theme.sizeTiny - 1
                color: Lyrics.current !== "" ? Theme.alpha(Theme.accent, 0.85) : Theme.textFaint
                elide: Text.ElideRight
            }
        }

        GfIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.hasMedia
            name: Media.playing ? "pause" : "play_arrow"
            iconSize: Theme.px(15)
            color: hover.containsMouse ? Theme.accentHi : Theme.textDim

            MouseArea {
                id: hover
                anchors.fill: parent
                anchors.margins: -Theme.px(3)
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Media.toggle()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: mediaHover.containsMouse || ShellState.popupKind === "media"
            ? Theme.alpha(Theme.accent, 0.12) : "transparent"
    }

    MouseArea {
        id: mediaHover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (root.hasMedia && mouse.x > root.width - Theme.px(26)) {
                Media.toggle();
                return;
            }
            var p = root.mapToItem(null, root.width / 2, root.height);
            ShellState.togglePopup("media", p.x, p.y, "");
        }
    }
}
