import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// MediaPlayButton — 媒体卡的播放/暂停按钮（自绘图标，避免字体缺字）。
Item {
    id: root

    property bool playing: Media.playing
    property real buttonSize: Theme.px(30)

    width: buttonSize
    height: buttonSize

    Rectangle {
        anchors.fill: parent
        color: playing || hover.containsMouse ? Theme.accent : "transparent"
        border.width: 1
        border.color: Theme.lineColor(Theme.alpha(Theme.accent, hover.containsMouse ? 0.9 : 0.55))
    }

    PlayGlyph {
        anchors.centerIn: parent
        playing: root.playing
        glyphSize: Theme.px(13)
        color: root.playing || hover.containsMouse ? Theme.ink : Theme.accent
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Media.toggle()
    }
}
