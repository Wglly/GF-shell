import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// CommandRose — 桌面右键命令轮盘，灵感来自《战地》的 Q 命令菜单。
// 每个主题换一套中心标识、环线、背景与标签；非当前主题不会显示。
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property bool open: ShellState.commandRose
        && (ShellState.roseScreen === "" || ShellState.roseScreen === modelData.name)
    visible: root.open
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "gf-shell-command-rose"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property bool arknights: Theme.arknights
    readonly property bool bf4: Theme.bf4
    readonly property bool bf1: Theme.bf1
    readonly property real cx: Math.max(Theme.px(300), Math.min(width - Theme.px(300), ShellState.roseX))
    readonly property real cy: Math.max(Theme.px(230), Math.min(height - Theme.px(230), ShellState.roseY))
    readonly property real radius: Math.min(Theme.px(235), Math.min(width, height) * 0.24)

    readonly property var actions: [
        { key: "settings", icon: "settings", label: I18n.t("rose.settings") },
        { key: "wallpaper", icon: "wallpaper", label: I18n.t("rose.wallpaper") },
        { key: "widgets", icon: "tune", label: I18n.t("rose.widgets") },
        { key: "launcher", icon: "rocket_launch", label: I18n.t("rose.launcher") },
        { key: "network", icon: "wifi", label: I18n.t("rose.network") },
        { key: "terminal", icon: "terminal", label: I18n.t("rose.terminal") },
        { key: "dashboard", icon: "radar", label: I18n.t("rose.dashboard") }
    ]

    function run(key) {
        ShellState.closeCommandRose();
        if (key === "settings") {
            ShellState.open("settings");
        } else if (key === "wallpaper") {
            ShellState.settingsTab = 5;
            ShellState.open("settings");
        } else if (key === "widgets") {
            ShellState.widgetsEditing = true;
        } else if (key === "launcher") {
            ShellState.open("launcher");
        } else if (key === "network") {
            ShellState.openPopup("network", width / 2, Theme.px(100), modelData.name);
        } else if (key === "terminal") {
            Terminal.launch();
        } else if (key === "dashboard") {
            ShellState.open("dashboard");
        }
    }

    onOpenChanged: if (root.open) keys.forceActiveFocus()

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                ShellState.closeCommandRose();
                event.accepted = true;
            } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_7) {
                root.run(root.actions[event.key - Qt.Key_1].key);
                event.accepted = true;
            }
        }
    }

    // 左键/右键空白处关闭
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: ShellState.closeCommandRose()
    }

    // 背景：每个主题不一样
    Item {
        anchors.fill: parent
        visible: root.arknights
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.alpha("#000000", 0.55) }
                GradientStop { position: 1.0; color: Theme.alpha(Theme.bg0, 0.82) }
            }
        }
        Repeater {
            model: 18
            Rectangle {
                required property int index
                x: root.width * index / 18
                y: 0; width: 1; height: root.height
                color: Theme.alpha(Theme.text, 0.045)
            }
        }
        Repeater {
            model: 10
            Rectangle {
                required property int index
                x: 0; y: root.height * index / 10
                width: root.width; height: 1
                color: Theme.alpha(Theme.text, 0.035)
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: root.bf4
        Rectangle {
            anchors.fill: parent
            color: Theme.alpha("#02080d", 0.72)
        }
        Repeater {
            model: 14
            Rectangle {
                required property int index
                x: 0; y: root.height * index / 14
                width: root.width; height: 1
                color: Theme.alpha(Theme.accent, index % 3 === 0 ? 0.13 : 0.035)
            }
        }
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.alpha(Theme.accent, 0.06) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: root.bf1
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.alpha("#2a2115", 0.55) }
                GradientStop { position: 0.6; color: Theme.alpha("#120d08", 0.75) }
                GradientStop { position: 1.0; color: Theme.alpha("#1b130b", 0.9) }
            }
        }
        Repeater {
            model: 7
            Rectangle {
                required property int index
                x: root.width * (0.1 + index * 0.13)
                y: root.height * (0.22 + (index % 3) * 0.2)
                width: root.width * (0.1 + (index % 2) * 0.06)
                height: width
                radius: width / 2
                color: Theme.alpha("#d8c39a", 0.022)
            }
        }
    }

    // 通用暗底（GFL）
    Rectangle {
        anchors.fill: parent
        visible: !root.arknights && !root.bf4 && !root.bf1
        color: Theme.alpha(Theme.bg0, 0.76)
    }

    // 环 / 辐条 / 中心
    Item {
        x: root.cx; y: root.cy
        width: 1; height: 1

        Rectangle {
            visible: !root.arknights
            anchors.centerIn: parent
            width: root.radius * 2
            height: root.radius * 2
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: Theme.alpha(Theme.accent, root.bf1 ? 0.32 : 0.24)
        }
        Rectangle {
            visible: !root.arknights
            anchors.centerIn: parent
            width: root.radius * 1.42
            height: root.radius * 1.42
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: Theme.alpha(Theme.accent, 0.12)
        }

        // Arknights：菱形指挥框
        Item {
            visible: root.arknights
            anchors.centerIn: parent
            width: root.radius * 1.55
            height: width
            Rectangle {
                anchors.centerIn: parent
                width: parent.width; height: parent.height
                rotation: 45
                color: "transparent"
                border.width: 1
                border.color: Theme.alpha(Theme.accent, 0.45)
            }
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.72; height: parent.height * 0.72
                rotation: 45
                color: "transparent"
                border.width: 1
                border.color: Theme.alpha(Theme.text, 0.18)
            }
        }

        // BF1：罗盘刻度
        Repeater {
            model: root.bf1 ? 24 : 0
            Item {
                required property int index
                rotation: index * 15
                Rectangle {
                    x: root.radius * 0.98
                    y: -0.5
                    width: index % 3 === 0 ? Theme.px(9) : Theme.px(4)
                    height: 1
                    color: Theme.alpha(Theme.accent, index % 3 === 0 ? 0.65 : 0.3)
                }
            }
        }

        // BF4：橙色目标弧
        Item {
            visible: root.bf4
            anchors.centerIn: parent
            width: root.radius * 2.18; height: width
            Rectangle {
                anchors.centerIn: parent
                width: parent.width; height: parent.height
                radius: width / 2
                color: "transparent"
                border.width: 2
                border.color: Theme.alpha(Theme.accent2, 0.35)
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                width: parent.width * 0.42; height: 2
                color: Theme.accent2
                opacity: 0.55
            }
        }

        Repeater {
            model: root.actions.length
            Item {
                required property int index
                rotation: -90 + index * (360 / root.actions.length)
                Rectangle {
                    x: root.radius * 0.27
                    y: -0.5
                    width: root.radius * 0.73
                    height: 1
                    color: Theme.alpha(Theme.accent, 0.22)
                }
            }
        }

        // 中心徽章
        GfFrame {
            anchors.centerIn: parent
            width: Theme.px(194)
            height: Theme.px(82)
            fill: Theme.alpha(Theme.bg0, 0.92)
            borderColor: Theme.alpha(Theme.accent, 0.8)
            chamfer: root.arknights || root.bf4 ? Theme.px(2) : Theme.px(6)
            innerLine: true
            padding: 0

            Column {
                anchors.centerIn: parent
                spacing: 0
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.arknights ? "RHODES COMMAND"
                        : (root.bf4 ? "COMMANDER"
                        : (root.bf1 ? "FIELD ORDERS" : "G&K COMMAND"))
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fs(14)
                    font.letterSpacing: 1.8
                    color: Theme.arknights ? Theme.text : Theme.accentHi
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.arknights ? "COMMAND UPLINK"
                        : (root.bf4 ? "SQUAD // ROSE"
                        : (root.bf1 ? "1918 // SIGNAL"
                        : "RIGHT CLICK // DESKTOP"))
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fs(7)
                    font.letterSpacing: 1.2
                    color: Theme.textDim
                }
            }
        }
    }

    // 七个选项
    Repeater {
        model: root.actions

        delegate: Item {
            required property var modelData
            required property int index
            readonly property real angle: (-90 + index * (360 / root.actions.length)) * Math.PI / 180

            x: root.cx + Math.cos(angle) * root.radius - width / 2
            y: root.cy + Math.sin(angle) * root.radius - height / 2
            width: Theme.px(162)
            height: Theme.px(48)

            GfFrame {
                anchors.fill: parent
                fill: optionMouse.containsMouse ? Theme.alpha(Theme.accent, 0.2) : Theme.alpha(Theme.bg1, 0.92)
                borderColor: optionMouse.containsMouse ? Theme.accentHi : Theme.alpha(Theme.accent, 0.45)
                chamfer: root.arknights || root.bf4 ? Theme.px(1) : Theme.px(4)
                innerLine: false
                padding: 0
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.px(10)
                anchors.rightMargin: Theme.px(8)
                spacing: Theme.px(8)

                GfIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: modelData.icon
                    iconSize: Theme.px(16)
                    color: optionMouse.containsMouse ? Theme.accentHi : Theme.accent
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - Theme.px(38)
                    Text {
                        width: parent.width
                        text: modelData.label
                        font.family: Theme.fontUI
                        font.pixelSize: Theme.fs(10)
                        font.bold: optionMouse.containsMouse
                        color: optionMouse.containsMouse ? Theme.accentHi : Theme.text
                        elide: Text.ElideRight
                    }
                    Text {
                        text: I18n.t("rose.hint") + " " + (index + 1)
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fs(7)
                        color: Theme.textFaint
                    }
                }
            }

            MouseArea {
                id: optionMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.run(modelData.key)
            }
        }
    }

    // 顶部提示
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.px(34)
        text: root.arknights ? "RHODES COMMAND  //  SELECT AN OPERATION"
            : (root.bf4 ? "COMMANDER ROSE  //  SELECT AN ORDER"
            : (root.bf1 ? "FIELD ORDERS  //  SELECT"
            : "TACTICAL COMMAND  //  SELECT"))
        font.family: Theme.fontDisplay
        font.pixelSize: Theme.fs(18)
        font.letterSpacing: 2.4
        color: Theme.alpha(Theme.accentHi, 0.85)
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.px(28)
        text: "ESC  /  LEFT CLICK DESKTOP  —  CLOSE"
        font.family: Theme.fontMono
        font.pixelSize: Theme.fs(8)
        font.letterSpacing: 1.4
        color: Theme.textFaint
    }
}
