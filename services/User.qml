pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

// User — operator/session information shared by the sidebar, user card, bar
// popup and settings home page. Avatar is copied into the config directory so
// it survives the original file being moved.
QtObject {
    id: root

    readonly property string name: {
        var u = Quickshell.env("USER") || "";
        return u !== "" ? u : "operator";
    }
    readonly property string displayName: root.name.toUpperCase()
    property string host: ""
    property string kernel: ""
    property string osName: ""
    property string cpuModel: ""

    readonly property string backend: Compositor.backend
    readonly property string session: root.backend === "hyprland" ? "HYPRLAND"
        : (root.backend === "niri" ? "NIRI" : "WAYLAND")
    readonly property string uptime: Util.uptimeText(Stats.uptime)
    readonly property string opNumber: Util.opNumber("operator")

    readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") || "") + "/.config") + "/gf-shell"
    readonly property string avatarDest: root.configDir + "/avatar"
    readonly property string avatar: {
        var p = Settings.get("user.avatar", "");
        return p !== "" ? p : Qt.resolvedUrl("../assets/icons/emblem-accent.png");
    }

    readonly property string role: "S09 COMMAND"
    readonly property string clearance: "CLEARANCE 3"

    function setAvatar(path) {
        var p = ("" + path).trim();
        if (p.indexOf("file://") === 0)
            p = p.substring(7);
        if (p === "")
            return;
        avatarCopier.command = ["sh", "-c",
            "mkdir -p \"$1\" && cp -- \"$2\" \"$1/avatar\"", "sh", root.configDir, p];
        if (!avatarCopier.running)
            avatarCopier.running = true;
    }

    function pickAvatar() {
        if (!avatarPicker.running)
            avatarPicker.running = true;
    }

    property Process avatarCopier: Process {
        command: ["true"]
        onExited: code => {
            if (code === 0) {
                Settings.set("user.avatar", root.avatarDest);
                avatarVersion += 1;
            }
        }
    }
    property int avatarVersion: 0

    property Process avatarPicker: Process {
        command: ["sh", "-c",
            "zenity --file-selection --title='Operator avatar' --file-filter='Images | *.png *.jpg *.jpeg *.webp' 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var p = ("" + text).trim();
                if (p !== "")
                    root.setAvatar(p);
            }
        }
    }

    property Process hostProc: Process {
        command: ["hostname"]
        stdout: StdioCollector {
            onStreamFinished: root.host = text.trim()
        }
        running: true
    }

    property Process kernelProc: Process {
        command: ["uname", "-r"]
        stdout: StdioCollector {
            onStreamFinished: root.kernel = text.trim()
        }
        running: true
    }

    property Process osProc: Process {
        command: ["sh", "-c", ". /etc/os-release 2>/dev/null; printf '%s' \"${PRETTY_NAME:-Linux}\""]
        stdout: StdioCollector {
            onStreamFinished: root.osName = text.trim()
        }
        running: true
    }

    property Process cpuProc: Process {
        command: ["sh", "-c", "awk -F': ' '/model name/{print $2; exit}' /proc/cpuinfo"]
        stdout: StdioCollector {
            onStreamFinished: root.cpuModel = text.trim()
        }
        running: true
    }
}
