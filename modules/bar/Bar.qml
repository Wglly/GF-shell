import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.bar
import qs.services

// Bar — 每屏一条。少前式顶部黑带：金色细线、斜切页签、资源式读数。
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property string pos: Settings.get("bar.position", "top")
    readonly property bool atTop: root.pos !== "bottom"
    readonly property int thickness: Theme.px(Settings.get("bar.thickness", 38))
    readonly property bool autoHide: Settings.get("bar.autoHide", false)

    property bool hovered: false
    readonly property bool collapsed: root.autoHide && !root.hovered && ShellState.overlay === "none"
    readonly property int sliver: Theme.px(3)
    readonly property int currentThickness: root.collapsed ? root.sliver : root.thickness

    anchors.left: true
    anchors.right: true
    anchors.top: root.atTop
    anchors.bottom: !root.atTop
    implicitHeight: root.currentThickness
    color: "transparent"
    exclusiveZone: Settings.get("bar.visible", true) ? root.currentThickness : 0
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "gf-shell-bar"

    visible: Settings.get("bar.visible", true)

    HoverHandler {
        id: barHover
        onHoveredChanged: {
            if (hovered) {
                hideTimer.stop();
                root.hovered = true;
            } else if (root.autoHide) {
                hideTimer.restart();
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 450
        onTriggered: root.hovered = false
    }

    IdleInhibitor {
        window: root
        enabled: Settings.get("shell.keepAwake", false)
    }

    readonly property var leftItems: Settings.get("bar.left", ["launcher", "workspaces", "title"])
    readonly property var centerItems: Settings.get("bar.center", ["clock"])
    readonly property var rightItems: Settings.get("bar.right", ["stats", "net", "bluetooth", "control", "power"])

    // 窄屏幕按优先级隐藏
    function itemVisible(kind) {
        var w = root.width;
        switch (kind) {
        case "title": return w >= Theme.px(1250);
        case "media": return w >= Theme.px(1150);
        case "stats": return w >= Theme.px(1050);
        case "tray": return w >= Theme.px(950);
        case "net": return w >= Theme.px(840);
        case "bluetooth": return w >= Theme.px(900);
        case "wallpaper": return w >= Theme.px(1150);
        default: return true;
        }
    }

    // ---------------------------------------------------------------- 底板
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.bg0, Settings.get("bar.opacity", 0.94))
    }

    // 模糊/灰度质感层（壁纸采样 + 自绘 blur/desaturate shader）
    GlassBackdrop {
        anchors.fill: parent
        source: Wallpapers.source
        blur: Settings.get("bar.blur", 0)
        gray: Settings.get("bar.gray", 0)
        strength: 0.5
        opacity: 0.9
    }

    // 顶部暖色高光（很淡）
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.alpha(Theme.text, 0.05)
    }

    // 金线：下缘 / 上缘
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        y: root.atTop ? parent.height - Theme.px(Settings.get("bar.edgeWidth", 1)) : 0
        height: Theme.px(Settings.get("bar.edgeWidth", 1))
        color: Theme.lineColor(Theme.alpha(Theme.accent, Settings.get("bar.edgeOpacity", 0.55)))
    }

    // 左端金色起始块
    Rectangle {
        x: 0
        y: 0
        width: Theme.px(3)
        height: parent.height
        color: Theme.accent
    }

    // 右侧密排刻度（装饰）
    Row {
        visible: root.width > Theme.px(600)
        anchors.right: parent.right
        anchors.rightMargin: Theme.px(10)
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Repeater {
            model: 4
            Rectangle {
                width: 1
                height: Theme.px(7)
                color: Theme.alpha(Theme.accent, 0.28)
            }
        }
    }

    // ---------------------------------------------------------------- 左段
    Row {
        id: leftRow
        anchors.left: parent.left
        anchors.leftMargin: Theme.px(12)
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: Theme.px(4)

        Repeater {
            model: root.leftItems
            delegate: BarItem {
                anchors.verticalCenter: parent.verticalCenter
                kind: modelData
                bar: root
                visible: root.itemVisible(modelData)
            }
        }
    }

    // ---------------------------------------------------------------- 中段
    Row {
        id: centerRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: Theme.px(8)

        Repeater {
            model: root.centerItems
            delegate: BarItem {
                anchors.verticalCenter: parent.verticalCenter
                kind: modelData
                bar: root
                visible: root.itemVisible(modelData)
            }
        }
    }

    // ---------------------------------------------------------------- 右段
    Row {
        id: rightRow
        anchors.right: parent.right
        anchors.rightMargin: Theme.px(16)
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: Theme.px(2)

        Repeater {
            model: root.rightItems
            delegate: BarItem {
                anchors.verticalCenter: parent.verticalCenter
                kind: modelData
                bar: root
                visible: root.itemVisible(modelData)
            }
        }
    }

    Rectangle {
        visible: Theme.bf1
        anchors.fill: parent
        radius: Theme.px(Theme.bf1Radius)
        color: "transparent"
        border.width: Theme.px(Settings.get("bar.edgeWidth", 1))
        border.color: Theme.lineColor(Theme.alpha(Theme.accent, Settings.get("bar.edgeOpacity", 0.35)))
        z: 19
    }

    BarThemeAccent {
        anchors.fill: parent
        z: 20
    }
}
