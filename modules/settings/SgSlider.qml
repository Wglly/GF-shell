import QtQuick
import "SgStyle.js" as Sg
import qs.modules.common

// SgSlider — 白色底上的黑线轨道 + 黄色进度 + 黑色菱形指针。
Item {
    id: root

    property real value: 0
    property real from: 0
    property real to: 1
    property real step: 0
    property string suffix: ""
    property int decimals: 0
    property bool showValue: true
    signal moved(real value)

    readonly property real ratio: root.to > root.from ? Math.max(0, Math.min(1, (root.value - root.from) / (root.to - root.from))) : 0
    readonly property bool hovered: mouse.containsMouse || mouse.pressed
    implicitWidth: Theme.fpx(230)
    implicitHeight: Theme.fpx(26)

    function valueAt(x) {
        var r = Math.max(0, Math.min(1, x / Math.max(1, track.width)));
        var v = root.from + r * (root.to - root.from);
        if (root.step > 0)
            v = Math.round(v / root.step) * root.step;
        return Math.max(root.from, Math.min(root.to, v));
    }

    Item {
        id: track
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - (root.showValue ? Theme.fpx(54) : 0)
        height: parent.height

        Rectangle {
            x: 0
            y: parent.height / 2 - 1
            width: parent.width
            height: 2
            color: Sg.ink
            opacity: 0.55
        }

        Rectangle {
            x: 0
            y: parent.height / 2 - 2
            width: track.width * root.ratio
            height: 4
            color: Sg.yellow
            border.width: 0
        }

        Row {
            width: parent.width
            height: parent.height
            Repeater {
                model: 11
                Rectangle {
                    width: parent.width / 11
                    height: 1
                    y: track.height - 6
                    color: Sg.ink
                    opacity: index / 11 <= root.ratio ? 0.7 : 0.2
                }
            }
        }

        Rectangle {
            x: Math.max(0, Math.min(track.width - width, track.width * root.ratio - width / 2))
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.fpx(10)
            height: Theme.fpx(10)
            rotation: 45
            color: root.hovered ? Sg.yellow : Sg.ink
            border.width: 1
            border.color: Sg.ink
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => root.moved(root.valueAt(mouse.x))
            onPositionChanged: mouse => { if (pressed) root.moved(root.valueAt(mouse.x)); }
            onClicked: mouse => root.moved(root.valueAt(mouse.x))
        }
    }

    Text {
        visible: root.showValue
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: (root.decimals > 0 ? root.value.toFixed(root.decimals) : Math.round(root.value)) + root.suffix
        font.family: Theme.fontMono
        font.pixelSize: Theme.fs(11)
        color: Sg.ink
        width: Theme.fpx(50)
        horizontalAlignment: Text.AlignRight
    }
}
