pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

// User — 当前操作员/会话信息（侧边栏、用户卡、状态列共用）。
QtObject {
    id: root

    readonly property string name: {
        var u = Quickshell.env("USER") || "";
        return u !== "" ? u : "operator";
    }
    readonly property string displayName: root.name.toUpperCase()
    property string host: ""

    readonly property string backend: Compositor.backend
    readonly property string session: root.backend === "hyprland" ? "HYPRLAND"
        : (root.backend === "niri" ? "NIRI" : "WAYLAND")
    readonly property string uptime: Util.uptimeText(Stats.uptime)
    readonly property string opNumber: Util.opNumber("operator")
    readonly property string avatar: Qt.resolvedUrl("../assets/icons/emblem-accent.png")
    readonly property string role: "S09 COMMAND"
    readonly property string clearance: "CLEARANCE 3"

    property Process hostProc: Process {
        command: ["hostname"]
        stdout: StdioCollector {
            onStreamFinished: root.host = text.trim()
        }
        running: true
    }
}
