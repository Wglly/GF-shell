pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery.qml — 电池/供电状态。
QtObject {
    id: root

    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev !== null && dev !== undefined && dev.isPresent
    readonly property real level: dev && dev.percentage !== undefined ? dev.percentage : 1.0
    readonly property bool charging: dev && (dev.state === UPowerDeviceState.Charging
        || dev.state === UPowerDeviceState.PendingCharge)
    readonly property bool full: dev && dev.state === UPowerDeviceState.FullyCharged
    readonly property bool critical: present && !charging && level <= 0.15
    readonly property int percent: Math.round(level * 100)

    readonly property string glyph: {
        if (!root.present)
            return "power";
        if (root.charging)
            return "battery_charging_full";
        if (root.percent >= 95)
            return "battery_full";
        if (root.percent >= 80)
            return "battery_6_bar";
        if (root.percent >= 60)
            return "battery_5_bar";
        if (root.percent >= 40)
            return "battery_3_bar";
        if (root.percent >= 20)
            return "battery_2_bar";
        return "battery_1_bar";
    }

    readonly property string timeText: {
        if (!root.present || !root.dev)
            return "";
        var secs = root.charging ? root.dev.timeToFull : root.dev.timeToEmpty;
        if (!secs || secs <= 0)
            return "";
        var h = Math.floor(secs / 3600);
        var m = Math.floor((secs % 3600) / 60);
        return (h > 0 ? h + "H " : "") + m + "M";
    }

    readonly property string label: root.present ? (root.percent + "%") : "AC"
}
