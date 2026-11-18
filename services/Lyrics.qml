pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Lyrics — 从 lrclib.net 取当前曲目的同步歌词，带内存缓存。
QtObject {
    id: root

    readonly property var player: Media.player
    readonly property string title: root.player ? (root.player.trackTitle || "") : ""
    readonly property string artist: root.player ? (root.player.trackArtist || "") : ""

    property var lines: []          // [{ t: seconds, text: "..." }]
    property var plain: []
    property bool loading: false
    property bool failed: false
    property int activeIndex: -1
    property string fetchedKey: ""

    readonly property bool hasSynced: root.lines.length > 0
    readonly property bool hasAny: root.hasSynced || root.plain.length > 0
    readonly property string current: {
        if (root.hasSynced && root.activeIndex >= 0 && root.activeIndex < root.lines.length)
            return root.lines[root.activeIndex].text;
        if (!root.hasSynced && root.plain.length > 0)
            return root.plain[Math.min(root.plain.length - 1, Math.max(0, root.activeIndex))];
        return "";
    }
    readonly property string next: {
        if (root.hasSynced && root.activeIndex >= 0 && root.activeIndex + 1 < root.lines.length)
            return root.lines[root.activeIndex + 1].text;
        if (!root.hasSynced && root.plain.length > 0 && root.activeIndex + 1 < root.plain.length)
            return root.plain[root.activeIndex + 1];
        return "";
    }
    readonly property string prev: {
        if (root.hasSynced && root.activeIndex > 0)
            return root.lines[root.activeIndex - 1].text;
        if (!root.hasSynced && root.plain.length > 0 && root.activeIndex > 0)
            return root.plain[root.activeIndex - 1];
        return "";
    }

    // 供 UI 使用的窗口片段
    function around(before, after) {
        var out = [];
        if (!root.hasAny)
            return out;
        var src = root.hasSynced ? root.lines : root.plain;
        var start = Math.max(0, root.activeIndex - before);
        var end = Math.min(src.length - 1, root.activeIndex + after);
        for (var i = start; i <= end; i++)
            out.push({ text: src[i].text, active: i === root.activeIndex, offset: i - root.activeIndex });
        return out;
    }

    function reset() {
        root.lines = [];
        root.plain = [];
        root.activeIndex = -1;
        root.failed = false;
        root.loading = false;
    }

    function parse(raw) {
        var data = null;
        try { data = JSON.parse(raw); } catch (e) { data = null; }
        if (!data) {
            root.failed = true;
            root.loading = false;
            return;
        }
        var out = [];
        var lrc = data.syncedLyrics || "";
        if (lrc !== "") {
            var rows = lrc.split("\n");
            for (var i = 0; i < rows.length; i++) {
                var m = rows[i].match(/^\[(\d+):(\d+(?:\.\d+)?)\]\s*(.*)$/);
                if (!m)
                    continue;
                var t = parseInt(m[1]) * 60 + parseFloat(m[2]);
                if (m[3] !== "")
                    out.push({ t: t, text: m[3] });
            }
        }
        root.lines = out;
        if (out.length === 0 && data.plainLyrics) {
            var p = [];
            var pr = ("" + data.plainLyrics).split("\n");
            for (var j = 0; j < pr.length; j++)
                if (pr[j].trim() !== "")
                    p.push(pr[j].trim());
            root.plain = p;
        }
        root.activeIndex = 0;
        root.loading = false;
        root.failed = false;
    }

    function fetch() {
        if (root.title === "") {
            root.reset();
            return;
        }
        var key = root.artist + "|" + root.title;
        if (key === root.fetchedKey && root.hasAny)
            return;
        root.fetchedKey = key;
        root.reset();
        root.loading = true;
        var url = "https://lrclib.net/api/get?artist_name=" + encodeURIComponent(root.artist)
                + "&track_name=" + encodeURIComponent(root.title);
        req.command = ["curl", "-fsSL", "--max-time", "12", url];
        req.running = true;
    }

    property Process req: Process {
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                root.loading = false;
                if (!root.hasAny)
                    root.failed = true;
            }
        }
    }

    property Timer debounce: Timer {
        interval: 400
        repeat: false
        onTriggered: root.fetch()
    }

    readonly property string key: root.artist + "|" + root.title
    onKeyChanged: {
        if (root.title === "") {
            root.reset();
            return;
        }
        root.debounce.restart();
    }

    property Timer ticker: Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            var p = root.player;
            if (!p)
                return;
            var pos = (typeof p.position === "number" && !isNaN(p.position)) ? p.position : -1;
            if (pos < 0)
                return;
            var src = root.hasSynced ? root.lines : root.plain;
            if (src.length === 0)
                return;
            var idx = 0;
            if (root.hasSynced) {
                for (var i = 0; i < src.length; i++)
                    if (src[i].t <= pos)
                        idx = i;
            } else {
                idx = Math.min(src.length - 1, Math.max(0, Math.floor(pos / 4.0)));
            }
            if (root.activeIndex !== idx)
                root.activeIndex = idx;
        }
    }

    Component.onCompleted: root.fetch()
}
