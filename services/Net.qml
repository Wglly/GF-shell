pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Io

// Net.qml — 网络状态（NetworkManager 经由 Quickshell.Networking）。
QtObject {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property bool wifiAvailable: Networking.wifiEnabled !== undefined
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool online: Networking.connectivity === NetworkConnectivity.Full
        || Networking.connectivity === NetworkConnectivity.Limited
    readonly property bool portal: Networking.connectivity === NetworkConnectivity.Portal

    readonly property var activeDevice: {
        var list = root.devices;
        for (var i = 0; i < list.length; i++)
            if (list[i] && list[i].connected)
                return list[i];
        return null;
    }

    readonly property string kind: {
        var d = root.activeDevice;
        if (!d)
            return root.wifiEnabled ? "wifi-idle" : "off";
        if (d.type === DeviceType.Wired)
            return "wired";
        if (d.type === DeviceType.Wifi)
            return "wifi";
        return "other";
    }

    // 已连接的 Wi-Fi：在设备列表里找 connected 的 WifiNetwork。
    readonly property var activeNetwork: {
        var list = root.devices;
        for (var i = 0; i < list.length; i++) {
            var d = list[i];
            if (!d || d.type !== DeviceType.Wifi)
                continue;
            var nets = d.networks ? d.networks.values : [];
            for (var j = 0; j < nets.length; j++)
                if (nets[j] && nets[j].connected)
                    return nets[j];
        }
        return null;
    }

    readonly property var wifiDevice: {
        var list = root.devices;
        for (var i = 0; i < list.length; i++)
            if (list[i] && list[i].type === DeviceType.Wifi)
                return list[i];
        return null;
    }

    readonly property var nearbyNetworks: {
        var dev = root.wifiDevice;
        var nets = dev && dev.networks ? dev.networks.values : [];
        var out = [];
        var seen = {};
        for (var i = 0; i < nets.length; i++) {
            if (!nets[i] || !nets[i].name || seen[nets[i].name])
                continue;
            seen[nets[i].name] = true;
            out.push(nets[i]);
        }
        out.sort(function (a, b) {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            return (b.signalStrength || 0) - (a.signalStrength || 0);
        });
        return out;
    }

    function signalBars(network) {
        var s = network ? (network.signalStrength || 0) : 0;
        if (s >= 0.8) return 4;
        if (s >= 0.6) return 3;
        if (s >= 0.35) return 2;
        if (s > 0) return 1;
        return 0;
    }

    // Quickshell's NetworkManager binding reports Open for many WPA networks;
    // nmcli carries the real security type, so use it for the popup.
    property var wifiSecurity: ({})

    function securityFor(network) {
        if (!network)
            return "";
        var sec = root.wifiSecurity[network.name];
        if (sec !== undefined && sec !== "")
            return ("" + sec).toUpperCase();
        if (network.security === WifiSecurityType.Open
            || network.security === WifiSecurityType.Owe)
            return "OPEN";
        return WifiSecurityType.toString(network.security).toUpperCase();
    }

    function isOpen(network) {
        var sec = root.securityFor(network);
        return sec === "" || sec === "OPEN" || sec === "NONE" || sec === "--";
    }

    function securityLabel(network) {
        if (!network)
            return "—";
        return root.isOpen(network) ? "OPEN" : root.securityFor(network);
    }

    function parseSecurity(raw) {
        var map = {};
        var lines = (raw || "").split("\n");
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            if (!line)
                continue;
            var cut = line.lastIndexOf(":");
            if (cut <= 0)
                continue;
            var ssid = line.slice(0, cut).replace(/\\:/g, ":");
            var sec = line.slice(cut + 1).trim();
            if (ssid !== "" && map[ssid] === undefined)
                map[ssid] = sec;
        }
        root.wifiSecurity = map;
    }

    property Process securityScanner: Process {
        command: ["nmcli", "-t", "-f", "SSID,SECURITY", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.parseSecurity(text)
        }
    }

    property Timer securityTimer: Timer {
        interval: 8000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!root.securityScanner.running) root.securityScanner.running = true
    }

    function connect(network, psk) {
        if (!network)
            return;
        network.connectWithPsk(psk || "");
    }

    function scan() {
        if (root.wifiDevice)
            root.wifiDevice.scannerEnabled = true;
        if (!root.securityScanner.running)
            root.securityScanner.running = true;
    }

    readonly property string ssid: root.activeNetwork ? (root.activeNetwork.name || "") : ""
    readonly property int strength: root.activeNetwork && root.activeNetwork.signalStrength !== undefined
        ? Math.round(root.activeNetwork.signalStrength * 100) : 0

    // 条形信号图标用的段数（0..4）
    readonly property int bars: {
        var s = root.strength;
        if (s >= 80)
            return 4;
        if (s >= 60)
            return 3;
        if (s >= 35)
            return 2;
        if (s > 0)
            return 1;
        return 0;
    }

    readonly property string glyph: {
        switch (root.kind) {
        case "wired": return "lan";
        case "wifi": return root.bars >= 4 ? "signal_wifi_4_bar" : (root.bars === 0 ? "signal_wifi_0_bar" : "wifi");
        case "wifi-idle": return "wifi_find";
        default: return "wifi_off";
        }
    }

    readonly property string label: {
        if (!root.online && !root.activeDevice)
            return "OFFLINE";
        if (root.kind === "wired")
            return "ETHERNET";
        if (root.kind === "wifi")
            return root.ssid !== "" ? root.ssid : "WIFI";
        return "LINKED";
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }
}
