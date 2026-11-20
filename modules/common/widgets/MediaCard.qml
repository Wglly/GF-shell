import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// MediaCard — 通讯/播放卡：封面、进度、控制、可选歌词与频谱。
Column {
    id: root

    property bool compact: false
    property bool showLyrics: true
    property bool showVisualizer: true
    property int lyricLines: 5
    spacing: Theme.fpx(8)

    readonly property var lyricWindow: Lyrics.around(Math.floor(root.lyricLines / 2), Math.floor(root.lyricLines / 2))

    // 封面 + 曲目
    Row {
        width: parent.width
        spacing: Theme.fpx(11)

        Item {
            width: root.compact ? Theme.fpx(64) : Theme.fpx(84)
            height: width

            Rectangle {
                anchors.fill: parent
                color: Theme.alpha(Theme.panelAlt, 0.9)
                border.width: 1
                border.color: Theme.lineColor(Theme.alpha(Theme.accent, 0.5))
            }

            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: Media.active ? Media.artUrl : ""
                visible: Media.active && Media.artUrl !== ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Image {
                anchors.centerIn: parent
                visible: !Media.active || Media.artUrl === ""
                width: parent.width * 0.55
                height: parent.height * 0.55
                source: Qt.resolvedUrl("../../../assets/icons/emblem-accent.png")
                opacity: 0.55
            }

            GfText {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 4
                visible: Media.active
                text: Media.sourceLabel
                role: "mono"
                size: Theme.sizeTiny - 4
                color: Theme.accent
            }
        }

        Column {
            width: parent.width - (root.compact ? Theme.fpx(75) : Theme.fpx(95))
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            GfText {
                width: parent.width
                text: Media.active ? Media.title : I18n.t("media.noSignal")
                role: "ui"
                size: root.compact ? Theme.sizeSmall : Theme.sizeMedium
                bold: true
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }
            GfText {
                width: parent.width
                text: Media.active ? Media.artist : I18n.t("media.awaiting")
                role: "ui"
                size: Theme.sizeTiny
                tone: "faint"
                elide: Text.ElideRight
            }
            GfText {
                width: parent.width
                text: Media.active ? Media.album : I18n.t("media.commsArray")
                role: "mono"
                size: Theme.sizeTiny - 2
                color: Theme.alpha(Theme.accent, 0.55)
                elide: Text.ElideRight
            }

            GfSlider {
                width: parent.width
                height: Theme.fpx(20)
                value: Media.progress
                showValue: false
                segments: 12
                interactive: Media.active
                onMoved: value => Media.seek(value)
            }
        }
    }

    // 控制行
    Row {
        width: parent.width
        spacing: Theme.fpx(4)

        GfIconButton {
            icon: "skip_previous"; glyphSize: Theme.fpx(13); buttonSize: Theme.fpx(24)
            onClicked: Media.previous()
        }
        MediaPlayButton {
            buttonSize: Theme.fpx(28)
        }
        GfIconButton {
            icon: "skip_next"; glyphSize: Theme.fpx(13); buttonSize: Theme.fpx(24)
            onClicked: Media.next()
        }

        Item { width: parent.width - Theme.fpx(150); height: 1 }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.fpx(150)
            text: Util.clockText(new Date(Media.position * 1000), false, false)
                + " / " + Util.clockText(new Date(Media.length * 1000), false, false)
            role: "mono"
            size: Theme.sizeTiny - 2
            tone: "faint"
            horizontalAlignment: Text.AlignRight
        }
    }

    // 频谱
    Item {
        visible: root.showVisualizer
        width: parent.width
        height: Theme.fpx(30)

        VisualizerBars {
            anchors.fill: parent
            count: 40
            color: Theme.alpha(Theme.accent, 0.85)
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.alpha(Theme.accent, 0.25)
        }
    }

    // 歌词
    Column {
        visible: root.showLyrics
        width: parent.width
        spacing: Theme.fpx(4)

        Row {
            width: parent.width
            GfText {
                text: I18n.t("media.lyrics")
                role: "mono"
                size: Theme.sizeTiny - 1
                color: Theme.accent
                tracking: 1.4
            }
            GfText {
                text: Lyrics.hasSynced ? " / " + I18n.t("media.synced") : (Lyrics.hasAny ? " / " + I18n.t("media.plain") : "")
                role: "mono"
                size: Theme.sizeTiny - 2
                tone: "faint"
            }
            Item { width: parent.width - 230; height: 1 }
            GfText {
                text: Lyrics.loading ? I18n.t("media.linking") : (Lyrics.failed ? I18n.t("media.noLink") : (Lyrics.hasAny ? I18n.t("media.online") : ""))
                role: "mono"
                size: Theme.sizeTiny - 2
                color: Lyrics.failed ? Theme.alpha(Theme.red, 0.8) : Theme.alpha(Theme.accent2, 0.8)
            }
        }

        Column {
            width: parent.width
            spacing: Theme.fpx(2)
            visible: root.lyricWindow.length > 0

            Repeater {
                model: root.lyricWindow

                delegate: GfText {
                    required property var modelData
                    width: parent.width
                    text: modelData.text
                    role: "ui"
                    size: modelData.active ? Theme.sizeSmall : Theme.sizeTiny
                    color: modelData.active ? Theme.accentHi : Theme.alpha(Theme.textDim, 0.65)
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        GfText {
            width: parent.width
            visible: root.lyricWindow.length === 0
            text: Lyrics.loading ? I18n.t("media.syncing")
                : (Media.active ? I18n.t("media.noRecord") : I18n.t("media.awaiting"))
            role: "mono"
            size: Theme.sizeTiny - 1
            tone: "faint"
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
