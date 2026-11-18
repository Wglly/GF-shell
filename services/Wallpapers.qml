pragma Singleton
import QtQuick
import Quickshell

// Wallpapers.qml — 内建壁纸（由 scripts/gen_assets.py 生成）+ 用户自选。
QtObject {
    id: root

    readonly property string folder: Qt.resolvedUrl("../assets/wallpapers/")

    readonly property var builtin: [
        { id: "gfl-ops", name: "OPERATION GRID", file: "gfl-ops.png" },
        { id: "gfl-sangvis", name: "SANGVIS FERRI", file: "gfl-sangvis.png" },
        { id: "gfl-neural", name: "NEURAL CLOUD", file: "gfl-neural.png" },
        { id: "gfl-dusk", name: "DUSK SECTOR", file: "gfl-dusk.png" }
    ]

    readonly property string selected: Settings.get("wallpaper.path", "")

    readonly property string source: {
        if (root.selected !== "" && root.selected !== undefined)
            return root.selected.indexOf("file://") === 0 ? root.selected : "file://" + root.selected;
        return root.folder + root.builtin[0].file;
    }

    readonly property string currentName: {
        var s = root.selected;
        if (s === "")
            return root.builtin[0].name;
        for (var i = 0; i < root.builtin.length; i++)
            if (root.folder + root.builtin[i].file === s || root.builtin[i].file === s)
                return root.builtin[i].name;
        var base = "" + s;
        var slash = base.lastIndexOf("/");
        return slash >= 0 ? base.substring(slash + 1) : base;
    }

    function choose(index) {
        if (index < 0 || index >= root.builtin.length)
            return;
        Settings.set("wallpaper.path", root.folder + root.builtin[index].file);
    }

    function chooseFile(path) {
        Settings.set("wallpaper.path", path);
    }

    function randomise() {
        var i = Math.floor(Math.random() * root.builtin.length);
        root.choose(i);
    }

    function reset() {
        Settings.set("wallpaper.path", "");
    }
}
