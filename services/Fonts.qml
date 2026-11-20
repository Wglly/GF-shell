pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Fonts — local font families discovered through fontconfig.
QtObject {
    id: root

    property var families: []
    property bool loading: false

    function parse(raw) {
        var seen = {};
        var out = [];
        var lines = ("" + raw).split("\n");
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line === "")
                continue;
            // fc-list may return "Family A,Family B"; use the first family.
            var first = line.split(",")[0].trim();
            if (first === "" || first.indexOf("/") >= 0 || first.indexOf(":") >= 0
                    || first.indexOf(".ttf") >= 0 || first.indexOf(".otf") >= 0
                    || first.indexOf("style=") >= 0 || seen[first])
                continue;
            seen[first] = true;
            out.push(first);
        }
        out.sort(function(a, b) { return a.localeCompare(b); });
        root.families = out;
    }

    function refresh() {
        if (scan.running)
            return;
        root.loading = true;
        scan.running = true;
    }

    property Process scan: Process {
        command: ["sh", "-c", "fc-list --format '%{family[0]}\\n'"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
        onExited: root.loading = false
    }

    Component.onCompleted: refresh()
}
