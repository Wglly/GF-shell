pragma Singleton
import QtQuick
import Quickshell
import qs.services

// Terminal — 命令轮盘/快捷键使用的终端启动器。
QtObject {
    id: root

    readonly property string configured: ("" + Settings.get("terminal.command", "")).trim()

    function launch() {
        var cmd = root.configured;
        if (cmd === "")
            cmd = "if command -v gf-term >/dev/null 2>&1; then exec gf-term; fi; "
                + "for t in kitty foot alacritty wezterm konsole gnome-terminal; do "
                + "command -v \"$t\" >/dev/null 2>&1 && exec \"$t\"; done";
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    function launchCommand(cmd) {
        Quickshell.execDetached(["sh", "-c", "" + cmd]);
    }
}
