pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services

// CompositorSettings — live Hyprland keywords and managed niri config values.
QtObject {
    id: root

    readonly property bool hypr: Compositor.isHyprland
    readonly property bool niri: Compositor.isNiri
    property string lastStatus: ""

    readonly property string niriScript: {
        var u = Qt.resolvedUrl("../scripts/niri-gf-settings.py").toString();
        if (u.indexOf("file://") === 0)
            u = u.substring(7);
        return decodeURIComponent(u);
    }

    function setHypr(key, value) {
        Settings.set("compositor.hypr." + key, value);
        if (!root.hypr)
            return;
        var map = {
            gapsIn: "general:gaps_in",
            gapsOut: "general:gaps_out",
            borderWidth: "general:border_size",
            rounding: "decoration:rounding",
            activeColor: "general:col.active_border",
            inactiveColor: "general:col.inactive_border",
            blur: "decoration:blur:enabled",
            animations: "animations:enabled"
        };
        var prop = map[key];
        if (!prop)
            return;
        var arg = "" + value;
        if (key === "activeColor" || key === "inactiveColor")
            arg = "rgba(" + arg.replace("#", "") + "ff)";
        else if (key === "blur" || key === "animations")
            arg = value ? "true" : "false";
        if (Compositor.hyprLua) {
            var table = "";
            if (key === "gapsIn") table = "general = { gaps_in = " + arg + " }";
            else if (key === "gapsOut") table = "general = { gaps_out = " + arg + " }";
            else if (key === "borderWidth") table = "general = { border_size = " + arg + " }";
            else if (key === "rounding") table = "decoration = { rounding = " + arg + " }";
            else if (key === "activeColor") table = "general = { col = { active_border = \"" + arg + "\" } }";
            else if (key === "inactiveColor") table = "general = { col = { inactive_border = \"" + arg + "\" } }";
            else if (key === "blur") table = "decoration = { blur = { enabled = " + arg + " } }";
            else if (key === "animations") table = "animations = { enabled = " + arg + " }";
            if (table !== "")
                Hyprland.dispatch("function() hl.config({ " + table + " }) end");
            return;
        }
        Quickshell.execDetached(["hyprctl", "keyword", prop, arg]);
    }

    function setNiri(key, value) {
        Settings.set("compositor.niri." + key, value);
        if (!root.niri)
            return;
        niriDebounce.restart();
    }

    function applyNiri() {
        if (!root.niri)
            return;
        niriProcess.command = [
            "python3", root.niriScript,
            "--gaps", "" + Settings.get("compositor.niri.gaps", 16),
            "--border-width", "" + Settings.get("compositor.niri.borderWidth", 2),
            "--focus-width", "" + Settings.get("compositor.niri.focusWidth", 4),
            "--radius", "" + Settings.get("compositor.niri.radius", 12),
            "--active-color", "" + Settings.get("compositor.niri.activeColor", "#e8bd4f"),
            "--inactive-color", "" + Settings.get("compositor.niri.inactiveColor", "#403a2e"),
            "--border-enabled", Settings.get("compositor.niri.border", true) ? "1" : "0",
            "--focus-enabled", Settings.get("compositor.niri.focus", false) ? "1" : "0"
        ];
        if (!niriProcess.running)
            niriProcess.running = true;
    }

    property Timer niriDebounce: Timer {
        interval: 260
        onTriggered: root.applyNiri()
    }

    property Process niriProcess: Process {
        command: ["true"]
        onExited: code => root.lastStatus = code === 0 ? "NIRI CONFIG APPLIED" : "NIRI CONFIG ERROR"
    }
}
