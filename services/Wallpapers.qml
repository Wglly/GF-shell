pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Wallpapers.qml — built-in wallpapers + a user directory of images.
QtObject {
    id: root

    readonly property string folder: Qt.resolvedUrl("../assets/wallpapers/")

    readonly property var builtin: [
        { id: "gfl-ops", name: "OPERATION GRID", file: "gfl-ops.png", path: root.folder + "gfl-ops.png" },
        { id: "gfl-sangvis", name: "SANGVIS FERRI", file: "gfl-sangvis.png", path: root.folder + "gfl-sangvis.png" },
        { id: "gfl-neural", name: "NEURAL CLOUD", file: "gfl-neural.png", path: root.folder + "gfl-neural.png" },
        { id: "gfl-dusk", name: "DUSK SECTOR", file: "gfl-dusk.png", path: root.folder + "gfl-dusk.png" }
    ]

    readonly property string directory: Settings.get("wallpaper.dir", "")
    onDirectoryChanged: root.refresh()
    property var user: []
    readonly property var all: root.builtin.concat(root.user)

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
        for (var i = 0; i < root.all.length; i++) {
            var p = root.all[i].path;
            if (s === p || s === root.all[i].file || s.indexOf(root.all[i].file) >= 0)
                return root.all[i].name;
        }
        var base = "" + s;
        var slash = base.lastIndexOf("/");
        return slash >= 0 ? base.substring(slash + 1) : base;
    }

    function refresh() {
        if (root.directory === "") {
            root.user = [];
            return;
        }
        if (!scanner.running)
            scanner.running = true;
    }

    function setDirectory(path) {
        var p = ("" + path).trim();
        if (p.indexOf("file://") === 0)
            p = p.substring(7);
        Settings.set("wallpaper.dir", p);
        root.user = [];
        Qt.callLater(root.refresh);
    }

    function applyScan(text) {
        var out = [];
        var lines = ("" + text).split("\n");
        var dir = root.directory.replace(/\/$/, "");
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line === "")
                continue;
            var slash = line.lastIndexOf("/");
            var name = slash >= 0 ? line.substring(slash + 1) : line;
            out.push({
                id: "user:" + name,
                name: name,
                file: name,
                path: line,
                full: line
            });
        }
        root.user = out;
    }

    function choose(index) {
        if (index < 0 || index >= root.all.length)
            return;
        root.choosePath(root.all[index].path);
    }

    function choosePath(path) {
        Settings.set("wallpaper.path", path);
    }

    function randomise() {
        if (root.all.length === 0)
            return;
        var i = Math.floor(Math.random() * root.all.length);
        root.choose(i);
    }

    function reset() {
        Settings.set("wallpaper.path", "");
    }

    property Process scanner: Process {
        command: ["find", root.directory, "-maxdepth", "1", "-type", "f",
            "-iregex", ".*\\.\\(png\\|jpg\\|jpeg\\|webp\\|avif\\|bmp\\)$"]
        stdout: StdioCollector {
            onStreamFinished: root.applyScan(text)
        }
    }

    property Timer initialScan: Timer {
        interval: 900
        repeat: false
        running: Settings.loaded && root.directory !== ""
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
