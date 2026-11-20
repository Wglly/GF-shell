pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// Cursors — local Xcursor themes discovered from the icon directories.
QtObject {
    id: root

    property var themes: []
    property bool loading: false
    readonly property string configured: Settings.get("cursor.theme", "")
    readonly property string current: root.configured !== ""
        ? root.configured
        : ((Quickshell.env("XCURSOR_THEME") || "") !== "" ? Quickshell.env("XCURSOR_THEME") : "default")
    readonly property int size: Settings.get("cursor.size", 24)

    readonly property string niriScript: {
        var u = Qt.resolvedUrl("../scripts/niri-gf-cursor.py").toString();
        if (u.indexOf("file://") === 0)
            u = u.substring(7);
        return decodeURIComponent(u);
    }

    function parse(raw) {
        var seen = {};
        var out = [];
        var lines = ("" + raw).split("\n");
        for (var i = 0; i < lines.length; i++) {
            var path = lines[i].trim();
            if (path === "")
                continue;
            var parts = path.split("/");
            var name = parts[parts.length - 1];
            if (name === "" || seen[name])
                continue;
            seen[name] = true;
            out.push(name);
        }
        out.sort(function(a, b) { return a.localeCompare(b); });
        root.themes = out;
    }

    function refresh() {
        if (scan.running)
            return;
        root.loading = true;
        scan.running = true;
    }

    function apply(theme) {
        var name = ("" + theme).trim();
        if (name === "")
            return;
        Settings.set("cursor.theme", name);
        root.applyAll(name, root.size);
    }

    function applySize(size) {
        var value = Math.max(12, Math.min(64, Math.round(size)));
        Settings.set("cursor.size", value);
        root.applyAll(root.current, value);
    }

    function applyAll(theme, size) {
        if (Compositor.isHyprland) {
            Quickshell.execDetached(["hyprctl", "setcursor", theme, "" + size]);
            Quickshell.execDetached(["gsettings", "set", "org.gnome.desktop.interface", "cursor-theme", theme]);
            Quickshell.execDetached(["gsettings", "set", "org.gnome.desktop.interface", "cursor-size", "" + size]);
        }
        if (Compositor.isNiri) {
            niriProcess.command = ["python3", root.niriScript,
                "--theme", theme, "--size", "" + size];
            if (!niriProcess.running)
                niriProcess.running = true;
        }
    }

    property Process scan: Process {
        command: ["sh", "-c",
            "find /usr/share/icons /usr/local/share/icons ~/.local/share/icons ~/.icons -mindepth 2 -maxdepth 2 -type d -name cursors -printf '%h\\n' 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
        onExited: root.loading = false
    }

    property Process niriProcess: Process {
        command: ["true"]
        onExited: code => root.refresh()
    }

    Component.onCompleted: refresh()
}
