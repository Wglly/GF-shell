import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.bar.popups
import qs.services

// BarPopup — 状态列组件的展开详细栏，锚定被点击组件的位置。
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property bool open: ShellState.popupKind !== ""
        && ShellState.popupKind !== "control"
        && (ShellState.popupScreen === "" || ShellState.popupScreen === modelData.name)
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
    WlrLayershell.namespace: "gf-shell-bar-popup"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    property double openedAt: 0
    onOpenChanged: if (root.open) root.openedAt = Date.now()

    readonly property string kind: ShellState.popupKind
    readonly property bool atTop: Settings.get("bar.position", "top") !== "bottom"
    readonly property int barThickness: Theme.px(Settings.get("bar.thickness", 38))

    readonly property int panelWidth: {
        switch (root.kind) {
        case "user": return Theme.fpx(320);
        case "calendar": return Theme.fpx(334);
        case "media": return Theme.fpx(404);
        case "network": return Theme.fpx(376);
        case "bluetooth": return Theme.fpx(360);
        case "stats": return Theme.fpx(384);
        case "tray": return Theme.fpx(380);
        case "wallpaper": return Theme.fpx(430);
        default: return Theme.fpx(320);
        }
    }

    function clampedX(w) {
        var x = ShellState.popupAnchorX - w / 2;
        return Math.max(Theme.fpx(12), Math.min(root.width - w - Theme.fpx(12), x));
    }

    // 点击外部关闭
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // 打开它的那一次点击不要立刻把它关掉
                if (Date.now() - root.openedAt > 280)
                    ShellState.closePopup();
            }
        }
    }

    GfFrame {
        id: panel
        x: root.clampedX(root.panelWidth)
        y: root.atTop ? root.barThickness + Theme.fpx(8)
            : root.height - root.barThickness - Theme.fpx(8) - height
        width: root.panelWidth
        height: content.implicitHeight + Theme.fpx(26)
        fill: Theme.alpha(Theme.bg1, Settings.get("bar.opacity", 0.94))
        applyPanelOpacity: false
        borderColor: Theme.alpha(Theme.accent, 0.75)
        chamfer: Theme.fpx(6)
        padding: 0

        // 顶部金线 + 指示三角
        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: 2
            color: Theme.accent
        }

        Item {
            width: parent.width
            height: Theme.fpx(6)

            Rectangle {
                x: Math.max(10, Math.min(parent.width - 22, ShellState.popupAnchorX - panel.x - 5))
                y: 0
                width: 10
                height: 5
                rotation: 45
                transformOrigin: Item.Center
                color: Theme.accent
            }
        }

        Item {
            id: contentHost
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Theme.fpx(10)
            anchors.margins: Theme.fpx(14)
            anchors.leftMargin: Theme.fpx(14)
            anchors.rightMargin: Theme.fpx(14)
            height: content.implicitHeight

            Column {
                id: content
                width: parent.width
                spacing: Theme.fpx(10)

                // 标题行
                Row {
                    width: parent.width

                    GfText {
                        text: root.kind === "user"
                            ? (Theme.hoi4 ? "HEAD OF STATE FILE"
                                : (Theme.battle ? "SOLDIER DOSSIER" : (Theme.arknights ? "OPERATOR FILE" : I18n.t("popup.operatorFile"))))
                            : root.kind === "calendar" ? I18n.t("calendar.schedule")
                            : root.kind === "network" ? I18n.t("popup.network")
                            : root.kind === "bluetooth" ? I18n.t("popup.bluetooth")
                            : root.kind === "stats" ? I18n.t("popup.stats")
                            : root.kind === "tray" ? I18n.t("popup.tray")
                            : root.kind === "wallpaper" ? I18n.t("popup.wallpaper")
                            : I18n.t("popup.transmissionLog")
                        role: "mono"
                        size: Theme.sizeTiny
                        color: Theme.accent
                        tracking: 1.8
                    }

                    Item { width: parent.width - 120; height: 1 }

                    GfText {
                        text: "S09 // " + (root.kind === "media" ? Media.sourceLabel : "HQ")
                        role: "mono"
                        size: Theme.sizeTiny - 2
                        tone: "faint"
                    }
                }

                GfDivider {
                    width: parent.width
                    color: Theme.alpha(Theme.accent, 0.35)
                }

                UserCard {
                    visible: root.kind === "user"
                    width: parent.width
                }

                CalendarCard {
                    visible: root.kind === "calendar"
                    width: parent.width
                    showHeader: false
                }

                MediaCard {
                    visible: root.kind === "media"
                    width: parent.width
                    showLyrics: true
                    showVisualizer: true
                    lyricLines: 5
                }

                NetworkCard {
                    visible: root.kind === "network"
                    width: parent.width
                }

                BluetoothCard {
                    visible: root.kind === "bluetooth"
                    width: parent.width
                }

                StatsCard {
                    visible: root.kind === "stats"
                    width: parent.width
                }

                TrayCard {
                    visible: root.kind === "tray"
                    width: parent.width
                }

                WallpaperCard {
                    visible: root.kind === "wallpaper"
                    width: parent.width
                }

                GfText {
                    width: parent.width
                    text: I18n.t("popup.hint")
                    role: "mono"
                    size: Theme.sizeTiny - 3
                    tone: "faint"
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    // Esc 关闭
    Item {
        anchors.fill: parent
        focus: root.open
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                ShellState.closePopup();
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                ShellState.popupKind = "";
            }
        }
    }
}
