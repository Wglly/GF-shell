pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

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
