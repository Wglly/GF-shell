import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// VolumeBlock — 主输出音量，滚轮直接调。
Item {
    id: root

    implicitWidth: row.implicitWidth + Theme.px(10)
    implicitHeight: Theme.barHeight

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(5)

        GfIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: Audio.muted || Audio.volume <= 0.001 ? "volume_off"
                : (Audio.volume < 0.5 ? "volume_down" : "volume_up")
            iconSize: Theme.px(14)
            color: Audio.muted ? Theme.red : Theme.textDim
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: Audio.label
            role: "mono"
            size: Theme.sizeTiny
            tone: Audio.muted ? "danger" : "dim"
            width: Theme.px(28)
            horizontalAlignment: Text.AlignRight
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                ShellState.toggle("control");
            else
                Audio.toggleMute();
        }
        onWheel: wheel => Audio.step(wheel.angleDelta.y > 0 ? 1 : -1)
    }
}
