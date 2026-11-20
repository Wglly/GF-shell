import QtQuick
import qs.modules.common

// GfSlider — 金色刻度滑条：细金线轨道 + 菱形指针 + 等宽数值。
Item {
    id: root

    property real value: 0
    property color fillColor: Theme.accent
    property int segments: 14
    property bool showValue: true
    property string valueText: Math.round(root.value * 100) + "%"
    property bool interactive: true

    signal moved(real value)

    implicitHeight: Theme.px(24)
    implicitWidth: Theme.px(180)

    readonly property real gutter: root.showValue ? Theme.px(34) : 0
    readonly property real usable: Math.max(1, root.width - root.gutter)
    readonly property real trackY: root.height / 2

    Rectangle {
        x: 0
        y: root.trackY - 1
        width: root.usable
        height: 2
        color: Theme.alpha(Theme.text, 0.18)
    }

    Rectangle {
        x: 0
        y: root.trackY - 1
        width: Math.max(0, root.usable * Math.max(0, Math.min(1, root.value)))
        height: 2
        color: root.fillColor
        Behavior on width {
            enabled: Theme.animations
            NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
        }
    }

    Row {
        width: root.usable
        height: root.height
        Repeater {
            model: root.segments + 1
            delegate: Item {
                width: root.usable / root.segments
                height: root.height
                Rectangle {
                    x: 0
                    y: root.trackY + 4
                    width: 1
                    height: index % 2 === 0 ? 4 : 2
                    color: Theme.alpha(Theme.accent, index / root.segments <= root.value ? 0.85 : 0.28)
                }
            }
        }
    }

    // 菱形指针
    Rectangle {
        x: Math.min(root.usable - 7, Math.max(0, root.usable * Math.max(0, Math.min(1, root.value)) - 3.5))
        y: root.trackY - 3.5
        width: 7
        height: 7
        rotation: 45
        color: root.fillColor
        border.width: 1
        border.color: Theme.lineColor(Theme.alpha(Theme.bg0, 0.8))
    }

    GfText {
        visible: root.showValue
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.gutter
        text: root.valueText
        role: "mono"
        size: Theme.sizeTiny - 1
        color: Theme.textDim
        horizontalAlignment: Text.AlignRight
    }

    MouseArea {
        width: root.usable
        height: parent.height
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        preventStealing: true
        function setFromX(px) {
            var v = Math.max(0, Math.min(1, px / root.usable));
            if (Math.abs(v - root.value) > 0.001)
                root.moved(v);
        }
        onPressed: mouse => setFromX(mouse.x)
        onPositionChanged: mouse => {
            if (mouse.pressed)
                setFromX(mouse.x);
        }
        onWheel: wheel => {
            if (!root.interactive)
                return;
            var step = wheel.angleDelta.y > 0 ? 0.03 : -0.03;
            root.moved(Math.max(0, Math.min(1, root.value + step)));
        }
    }
}
