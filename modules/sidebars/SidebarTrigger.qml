import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.services

// SidebarTrigger — 屏幕边缘的隐形热区：鼠标进入即展开对应侧边栏。
PanelWindow {
    id: root

    required property var modelData
    property string side: "left"

    screen: modelData

    readonly property var cfg: Settings.get("sidebar." + root.side, ({}))
    readonly property string triggerPosition: root.cfg.triggerPosition !== undefined
        ? root.cfg.triggerPosition : "top"
    readonly property int triggerWidth: Theme.px(root.cfg.triggerWidth !== undefined ? root.cfg.triggerWidth : 180)
    readonly property int triggerHeight: Theme.px(root.cfg.trigger !== undefined ? root.cfg.trigger : 12)

    anchors.top: root.triggerPosition === "top"
    anchors.bottom: root.triggerPosition === "bottom"
    anchors.left: root.side === "left"
    anchors.right: root.side === "right"
    implicitWidth: root.triggerWidth
    implicitHeight: root.triggerHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "gf-shell-sidebar-trigger-" + root.side

    HoverHandler {
        onHoveredChanged: {
            if (!hovered)
                return;
            var c = Settings.get("sidebar." + root.side, ({}));
            if (c.enabled === false)
                return;
            ShellState.closePopup();
            if (root.side === "left")
                ShellState.sidebarLeft = true;
            else
                ShellState.sidebarRight = true;
        }
    }

    // 可见的 1px 金线提示：位于屏幕顶端/底端的横向触发区
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        y: root.triggerPosition === "top" ? 0 : parent.height - 1
        height: 1
        color: Theme.alpha(Theme.accent, 0.35)
    }
    Rectangle {
        width: 1
        height: root.triggerHeight
        x: root.side === "left" ? 0 : parent.width - 1
        y: 0
        color: Theme.alpha(Theme.accent, 0.5)
    }
}
