import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// BarPopup — 状态列组件的展开详细栏，锚定被点击组件的位置。
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property bool open: ShellState.popupKind !== ""
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
        case "user": return Theme.px(320);
        case "calendar": return Theme.px(334);
        case "media": return Theme.px(404);
        default: return Theme.px(320);
        }
    }

    function clampedX(w) {
        var x = ShellState.popupAnchorX - w / 2;
        return Math.max(Theme.px(12), Math.min(root.width - w - Theme.px(12), x));
    }

    // 点击外部关闭
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.bg0, 0.45)

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
        y: root.atTop ? root.barThickness + Theme.px(8)
            : root.height - root.barThickness - Theme.px(8) - height
        width: root.panelWidth
        height: content.implicitHeight + Theme.px(26)
        fill: Theme.alpha(Theme.bg1, 0.985)
        borderColor: Theme.alpha(Theme.accent, 0.75)
        chamfer: Theme.px(6)
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
            height: Theme.px(6)

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
            anchors.topMargin: Theme.px(10)
            anchors.margins: Theme.px(14)
            anchors.leftMargin: Theme.px(14)
            anchors.rightMargin: Theme.px(14)
            height: content.implicitHeight

            Column {
                id: content
                width: parent.width
                spacing: Theme.px(10)

                // 标题行
                Row {
                    width: parent.width

                    GfText {
                        text: root.kind === "user" ? I18n.t("popup.operatorFile")
                            : (root.kind === "calendar" ? I18n.t("calendar.schedule") : I18n.t("popup.transmissionLog"))
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
