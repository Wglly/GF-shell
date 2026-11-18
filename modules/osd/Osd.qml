import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// Osd — 音量/亮度的 HUD 反馈，出现在屏幕底部中央。
PanelWindow {
    id: root

    readonly property bool open: ShellState.osdKind !== "" && Settings.get("osd.enabled", true)
    visible: root.open
    color: "transparent"
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    implicitHeight: Theme.px(220)
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "gf-shell-osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    function focusedScreen() {
        var name = Compositor.outputName;
        var list = Quickshell.screens;
        for (var i = 0; i < list.length; i++) {
            if (list[i].name === name)
                return list[i];
        }
        return list.length > 0 ? list[0] : null;
    }
    screen: focusedScreen()

    readonly property bool volume: ShellState.osdKind === "volume"
    readonly property real value: ShellState.osdValue
    readonly property string glyph: root.volume
        ? (root.value < 0.01 ? "volume_off" : (root.value < 0.5 ? "volume_down" : "volume_up"))
        : "brightness_6"

    GfFrame {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Settings.get("dock.enabled", true) ? Theme.px(96) : Theme.px(36)
        width: Theme.px(320)
        height: Theme.px(66)
        fill: Theme.alpha(Theme.panel, 0.94)
        borderColor: Theme.alpha(Theme.lineBright, 0.8)
        chamfer: Theme.px(10)
        padding: 0
        opacity: root.open ? 1 : 0
        transform: Translate {
            y: root.open ? 0 : Theme.px(10)
            Behavior on y {
                enabled: Theme.animations
                NumberAnimation { duration: Theme.durNormal; easing.type: Easing.OutCubic }
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: Theme.px(14)
            anchors.rightMargin: Theme.px(14)
            spacing: Theme.px(12)

            GfIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: root.glyph
                iconSize: Theme.px(22)
                color: Theme.accent
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.px(110)
                spacing: Theme.px(4)

                Row {
                    width: parent.width
                    spacing: Theme.px(8)

                    GfText {
                        text: root.volume ? "VOLUME" : "BRIGHTNESS"
                        role: "mono"
                        size: Theme.sizeTiny
                        tracking: 2
                        tone: "dim"
                    }

                    GfText {
                        text: root.volume ? "主音量" : "螢幕亮度"
                        role: "ui"
                        size: Theme.sizeTiny - 1
                        tone: "faint"
                    }
                }

                GfMeter {
                    width: parent.width
                    height: Theme.px(6)
                    value: root.value
                    segments: 20
                    segmentGap: 2
                    color: root.volume ? Theme.accent : Theme.accent2
                }
            }

            GfText {
                anchors.verticalCenter: parent.verticalCenter
                text: Util.pad2(Math.round(root.value * 100))
                role: "display"
                size: Theme.sizeTitle
                bold: true
                tracking: 1
                color: Theme.text
                width: Theme.px(56)
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
