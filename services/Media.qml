pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Media.qml — MPRIS 播放器的统一入口（侧边栏、bar、桌面组件共用）。
QtObject {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var player: {
        var list = root.players;
        for (var i = 0; i < list.length; i++)
            if (list[i] && list[i].isPlaying)
                return list[i];
        return list.length > 0 ? list[0] : null;
    }

    readonly property bool active: player !== null
    readonly property bool playing: player ? player.isPlaying : false
    readonly property string title: player ? (player.trackTitle || "") : ""
    readonly property string artist: player ? (player.trackArtist || "") : ""
    readonly property string album: player ? (player.trackAlbum || "") : ""
    readonly property string artUrl: player ? (player.trackArtUrl || "") : ""
    readonly property string identity: player ? (player.identity || "") : ""
    readonly property real length: player && player.length > 0 ? player.length : 0
    readonly property real position: player ? player.position : 0
    readonly property real progress: root.length > 0 ? Math.min(1, root.position / root.length) : 0

    readonly property string sourceLabel: {
        if (!root.player)
            return "NO SIGNAL";
        var id = root.identity.toLowerCase();
        if (id.indexOf("spotify") >= 0)
            return "SPOTIFY";
        if (id.indexOf("firefox") >= 0 || id.indexOf("chrom") >= 0)
            return "BROWSER";
        if (id.indexOf("mpv") >= 0 || id.indexOf("vlc") >= 0)
            return "MEDIA";
        return root.identity.toUpperCase() || "PLAYER";
    }

    function toggle() {
        if (root.player)
            root.player.togglePlaying();
    }
    function next() {
        if (root.player && root.player.canGoNext)
            root.player.next();
    }
    function previous() {
        if (root.player && root.player.canGoPrevious)
            root.player.previous();
    }
    function seek(ratio) {
        if (root.player && root.length > 0)
            root.player.position = Math.max(0, Math.min(1, ratio)) * root.length;
    }
    function playPause() {
        root.toggle();
    }
}
