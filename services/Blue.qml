pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Blue.qml — Bluetooth adapter/device summary for the bar and popup.
QtObject {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property var devices: Bluetooth.devices ? Bluetooth.devices.values : []
    readonly property var connectedDevices: root.devices.filter(d => d && d.connected)
    readonly property int connectedCount: root.connectedDevices.length
    readonly property string name: adapter ? (adapter.name || "") : ""
    readonly property string address: adapter ? (adapter.address || "") : ""

    readonly property string label: !root.available ? "NO BT"
        : (!root.enabled ? "BT OFF"
            : (root.connectedCount > 0 ? "BT " + root.connectedCount : "BT"))

    function toggle() {
        if (!root.adapter)
            return;
        root.adapter.enabled = !root.adapter.enabled;
    }
}
