pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Visualizer — cava 原始输出的音频频谱。cava 不可用时保持静默（不伪造动画）。
QtObject {
    id: root

    property var bars: []
    property bool available: false
    property bool running: false
    property int barCount: 32
    readonly property bool active: root.available && root.bars.length > 0

    readonly property string confPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/gf-shell-cava.conf"

    readonly property string confText: [
        "[general]",
        "framerate = 60",
        "bars = 48",
        "[input]",
        "method = pipewire",
        "source = auto",
        "[output]",
        "method = raw",
        "raw_target = /dev/stdout",
        "data_format = ascii",
        "ascii_max_range = 100",
        "bar_delimiter = 59",
        "frame_delimiter = 10",
        ""
    ].join("\n")

    function parseFrame(line) {
        if (!line || line.length === 0)
            return;
        var parts = line.split(";");
        var vals = [];
        for (var i = 0; i < parts.length; i++) {
            var v = parseInt(parts[i], 10);
            if (!isNaN(v))
                vals.push(Math.max(0, Math.min(1, v / 100)));
        }
        if (vals.length > 0)
            root.bars = vals;
    }

    property FileView conf: FileView {
        path: root.confPath
        onSaved: root.startCava()
        Component.onCompleted: setText(root.confText)
    }

    function startCava() {
        if (cava.running)
            return;
        cava.running = true;
    }

    property Process cava: Process {
        command: ["cava", "-p", root.confPath]
        stdout: SplitParser {
            onRead: line => root.parseFrame(line)
        }
        onStarted: {
            root.available = true;
            root.running = true;
        }
        onExited: {
            root.running = false;
            restartTimer.restart();
        }
    }

    property Timer restartTimer: Timer {
        interval: 4000
        onTriggered: root.startCava()
    }
}
