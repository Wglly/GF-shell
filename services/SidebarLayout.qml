pragma Singleton
import QtQuick
import qs.services

// SidebarLayout — draggable component order for both sidebars.
// `sidebar.leftOrder` / `sidebar.rightOrder` are the source of truth after the
// first edit; `sidebar.assign.<id>` stays in sync for compatibility.
QtObject {
    id: root

    readonly property var all: ["user", "clock", "calendar", "weather", "roster", "actions",
        "stats", "mission", "media", "visualizer", "comms", "wallpaper"]

    function stored(side) {
        return Settings.get("sidebar." + side + "Order", null);
    }

    function items(side) {
        var saved = root.stored(side);
        if (saved !== null && saved !== undefined)
            return Array.isArray(saved) ? saved.slice() : [];
        var out = [];
        for (var i = 0; i < root.all.length; i++) {
            if (Settings.get("sidebar.assign." + root.all[i], "off") === side)
                out.push(root.all[i]);
        }
        return out;
    }

    function assign(id) {
        if (root.items("left").indexOf(id) >= 0)
            return "left";
        if (root.items("right").indexOf(id) >= 0)
            return "right";
        return "off";
    }

    function move(id, side, index) {
        var left = root.items("left");
        var right = root.items("right");
        for (var s = 0; s < 2; s++) {
            var arr = s === 0 ? left : right;
            var pos = arr.indexOf(id);
            if (pos >= 0)
                arr.splice(pos, 1);
        }
        if (side === "left" || side === "right") {
            var target = side === "left" ? left : right;
            var at = Math.max(0, Math.min(target.length, index === undefined ? target.length : index));
            target.splice(at, 0, id);
        }
        Settings.set("sidebar.leftOrder", left);
        Settings.set("sidebar.rightOrder", right);
        for (var i = 0; i < root.all.length; i++) {
            var k = root.all[i];
            Settings.set("sidebar.assign." + k,
                left.indexOf(k) >= 0 ? "left" : (right.indexOf(k) >= 0 ? "right" : "off"));
        }
    }

}
