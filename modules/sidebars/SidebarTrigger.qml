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
    anchors.top: true
    anchors.bottom: true
    anchors.left: root.side === "left"
    anchors.right: root.side === "right"
    implicitWidth: {
        var c = Settings.get("sidebar." + root.side, ({}));
        return c.trigger !== undefined ? c.trigger : Theme.px(6);
    }
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

    // 可见的 1px 金线提示
    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: root.side === "left" ? 0 : parent.width - 1
        width: 1
        color: Theme.alpha(Theme.accent, 0.35)
    }
}
