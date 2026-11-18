pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.modules.common

// Audio.qml — default sink volume/mute.
//
// Quickshell's PwNodeAudio reads `channelVolumes` from the node, but on some
// WirePlumber setups (including the author's) that property is empty and the
// soft volume lives on the WirePlumber route. `wpctl` always sees the real
// value, so it is the primary backend; Pipewire stays as a fallback for
// systems without wpctl.
QtObject {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    property real volume: 0
    property bool muted: false
    property bool available: false
    property bool useWpctl: true
    property int wpctlFailures: 0

    readonly property string label: !root.available
        ? "--"
        : (root.muted ? "MUTE" : Math.round(root.volume * 100) + "%")

    property real pwVolume: audio ? audio.volume : 0
    property bool pwMuted: audio ? audio.muted : false
    onPwVolumeChanged: if (!root.useWpctl) root.volume = root.pwVolume
    onPwMutedChanged: if (!root.useWpctl) root.muted = root.pwMuted

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    function applyWpctl(text) {
        var m = ("" + text).match(/Volume:\s*([0-9]+(?:\.[0-9]+)?)(.*)/);
        if (!m) {
            root.wpctlFailures += 1;
            if (root.wpctlFailures >= 3) {
                root.useWpctl = false;
                root.volume = root.pwVolume;
                root.muted = root.pwMuted;
                root.available = root.audio !== null;
            }
            return;
        }
        root.wpctlFailures = 0;
        root.available = true;
        root.volume = root.clamp(parseFloat(m[1]));
        root.muted = /\[MUTED\]/.test(m[2] || "");
    }

    function refresh() {
        if (!root.useWpctl || reader.running)
            return;
        reader.running = true;
    }

    function applyNow() {
        if (!root.useWpctl || setter.running)
            return;
        setter.command = ["sh", "-c",
            "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; "
            + "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + root.volume.toFixed(3)];
        setter.running = true;
    }

    function setVolume(v) {
        var value = root.clamp(v);
        root.volume = value;
        root.muted = false;
        root.available = true;
        if (root.useWpctl) {
            applyTimer.restart();
        } else if (root.audio) {
            root.audio.volume = value;
            if (root.audio.muted)
                root.audio.muted = false;
        }
        ShellState.flashOsd("volume", value);
    }

    function step(delta) {
        root.setVolume(root.volume + delta * 0.05);
    }

    function toggleMute() {
        if (root.useWpctl) {
            root.muted = !root.muted;
            root.available = true;
            muteSetter.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"];
            if (!muteSetter.running)
                muteSetter.running = true;
        } else if (root.audio) {
            root.audio.muted = !root.audio.muted;
            root.muted = root.audio.muted;
        }
        ShellState.flashOsd("volume", root.muted ? 0 : root.volume);
    }

    property Process reader: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: root.applyWpctl(text)
        }
    }

    property Process setter: Process {
        command: ["true"]
        onExited: root.refresh()
    }

    property Process muteSetter: Process {
        command: ["true"]
        onExited: root.refresh()
    }

    property Timer applyTimer: Timer {
        interval: 60
        onTriggered: root.applyNow()
    }

    property Timer pollTimer: Timer {
        interval: 500
        repeat: true
        running: root.useWpctl
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
