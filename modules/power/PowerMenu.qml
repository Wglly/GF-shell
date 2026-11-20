import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// PowerMenu — 系统停机菜单。危险操作需要二次确认（再按一次 Enter）。
PanelWindow {
    id: root

    readonly property bool open: ShellState.overlay === "power"
    visible: root.open
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "gf-shell-power"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property int index: ShellState.powerIndex
    property bool armed: false
    property real armedAt: 0

    readonly property var actions: [
        { key: "lock", label: "LOCK", zh: "鎖定", glyph: "lock", danger: false, hint: "L" },
        { key: "suspend", label: "SUSPEND", zh: "休眠", glyph: "bedtime", danger: true, hint: "S" },
        { key: "reboot", label: "RESTART", zh: "重新啟動", glyph: "restart_alt", danger: true, hint: "R" },
        { key: "shutdown", label: "SHUT DOWN", zh: "關機", glyph: "power_settings_new", danger: true, hint: "P" },
        { key: "logout", label: "LOG OUT", zh: "登出", glyph: "logout", danger: true, hint: "Q" }
    ]

    function run(index) {
        var a = root.actions[index];
        if (!a)
            return;
        switch (a.key) {
        case "lock":
            System.lockSession();
            ShellState.close();
            break;
        case "suspend":
            System.suspend();
            break;
        case "reboot":
            System.reboot();
            break;
        case "shutdown":
            System.powerOff();
            break;
        case "logout":
            System.quitCompositor();
            break;
        }
    }

    function activate(index) {
        var a = root.actions[index];
        if (!a)
            return;
        if (a.danger && !root.armed) {
            root.armed = true;
            root.armedAt = Date.now();
            armTimer.restart();
            return;
        }
        root.run(index);
    }

    function step(delta) {
        root.index = (root.index + delta + root.actions.length) % root.actions.length;
        root.armed = false;
        ShellState.powerIndex = root.index;
    }

    Timer {
        id: armTimer
        interval: 4000
        onTriggered: root.armed = false
    }

    // ---------------------------------------------------------------- 背景
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.bg0, 0.72)
        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.close()
        }
    }

    // 斜纹警告条（背景装饰）
    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../../assets/textures/hatch.png")
        fillMode: Image.Tile
        opacity: 0.18
    }

    Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                if (root.armed)
                    root.armed = false;
                else
                    ShellState.close();
                event.accepted = true;
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                root.step(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
                root.step(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.activate(root.index);
                event.accepted = true;
            }
        }
    }

    // ---------------------------------------------------------------- 面板
    GfFrame {
        id: panel
        anchors.centerIn: parent
        width: Theme.px(470)
        height: content.implicitHeight + Theme.px(30)
        fill: Theme.alpha(Theme.panel, 0.98)
        borderColor: root.armed ? Theme.red : Theme.alpha(Theme.lineBright, 0.7)
        chamfer: Theme.px(12)
        padding: 0

        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: content
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.px(18)
            height: implicitHeight
            spacing: Theme.px(8)

            Item {
                width: parent.width
                height: Theme.px(44)

                GfSectionHeader {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    title: I18n.t("power.title")
                    subtitle: I18n.t("power.subtitle")
                    accentColor: Theme.red
                    rule: false
                }

                GfIconButton {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "close"
                    glyphSize: Theme.px(14)
                    buttonSize: Theme.px(22)
                    onClicked: ShellState.close()
                }
            }

            GfDivider {
                width: parent.width
                color: Theme.alpha(Theme.red, 0.5)
            }

            GfText {
                width: parent.width
                text: "SELECT AN OPERATION. DANGEROUS COMMANDS REQUIRE A SECOND CONFIRMATION."
                role: "mono"
                size: Theme.sizeTiny - 1
                tone: "faint"
                wrapMode: Text.WordWrap
            }

            // 动作列表
            Column {
                width: parent.width
                spacing: Theme.px(3)

                Repeater {
                    model: root.actions

                    delegate: Item {
                        id: row
                        required property var modelData
                        required property int index

                        readonly property bool selected: root.index === index
                        readonly property bool isArmed: row.selected && root.armed && modelData.danger

                        width: parent.width
                        height: Theme.px(40)

                        Rectangle {
                            anchors.fill: parent
                            color: row.isArmed ? Theme.alpha(Theme.red, 0.92)
                                : (row.selected ? Theme.accent
                                    : (rowMouse.containsMouse ? Theme.alpha(Theme.accent, 0.12) : Theme.alpha(Theme.bg0, 0.55)))
                            border.width: 1
                            border.color: Theme.lineColor(row.isArmed ? Theme.red
                                : (row.selected ? Theme.accentHi : Theme.alpha(Theme.accent, 0.35)))
                            Behavior on color {
                                enabled: Theme.animations
                                ColorAnimation { duration: Theme.durFast }
                            }
                        }

                        Rectangle {
                            visible: row.selected
                            width: 2
                            height: parent.height - Theme.px(8)
                            anchors.verticalCenter: parent.verticalCenter
                            color: row.selected ? Theme.ink : (modelData.danger ? Theme.red : Theme.accent)
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.px(12)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.px(10)

                            GfIcon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: modelData.glyph
                                iconSize: Theme.px(17)
                                color: row.isArmed ? Theme.text
                                    : (row.selected ? Theme.ink
                                        : (modelData.danger ? Theme.alpha(Theme.red, 0.85) : Theme.textDim))
                            }

                            GfText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                role: "display"
                                size: Theme.sizeMedium
                                tracking: 2
                                bold: row.selected
                                color: row.isArmed ? Theme.text : (row.selected ? Theme.ink : Theme.textDim)
                                width: Theme.px(140)
                            }

                            GfText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: I18n.t("power." + modelData.key)
                                role: "ui"
                                size: Theme.sizeTiny
                                color: row.selected ? Theme.alpha(Theme.ink, 0.65)
                                    : (row.isArmed ? Theme.alpha(Theme.text, 0.75) : Theme.textFaint)
                            }
                        }

                        GfText {
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.px(12)
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.isArmed ? "CONFIRM  →  ENTER" : modelData.hint
                            role: "mono"
                            size: Theme.sizeTiny - 1
                            color: row.isArmed ? Theme.text : (row.selected ? Theme.ink : Theme.textFaint)
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.index = row.index;
                                root.activate(row.index);
                            }
                        }
                    }
                }
            }

            // 底部信息
            Item {
                width: parent.width
                height: Theme.px(30)

                GfText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "SESSION  " + Compositor.backend.toUpperCase() + "   ·   UPTIME  " + Util.uptimeText(Stats.uptime)
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    tone: "faint"
                }

                GfText {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.armed ? "AWAITING CONFIRMATION" : "STANDBY"
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    color: root.armed ? Theme.red : Theme.alpha(Theme.accent2, 0.8)
                }
            }
        }
    }

    onOpenChanged: {
        if (root.open) {
            root.armed = false;
            root.index = Math.max(0, Math.min(root.actions.length - 1, ShellState.powerIndex));
            keyCatcher.forceActiveFocus();
        }
    }
}
