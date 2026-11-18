import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets

PanelWindow {
    id: root
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#0b0f13"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    readonly property var names: [
        "search", "close", "add", "remove", "chevron_left", "chevron_right", "expand_more",
        "arrow_forward", "arrow_back", "refresh", "more_horiz", "check", "settings", "tune",
        "palette", "wallpaper", "dashboard", "grid_view", "apps", "terminal", "rocket_launch",
        "bolt", "power_settings_new", "lock", "logout", "restart_alt", "bedtime", "dark_mode",
        "nightlight", "brightness_6", "brightness_low", "volume_up", "volume_off", "volume_down",
        "mic", "headphones", "graphic_eq", "music_note", "play_arrow", "pause", "skip_next",
        "skip_previous", "shuffle", "repeat", "notifications", "notifications_off", "delete_sweep",
        "wifi", "wifi_off", "wifi_find", "signal_wifi_4_bar", "lan", "bluetooth", "bluetooth_disabled",
        "devices", "battery_full", "battery_charging_full", "battery_5_bar", "battery_1_bar", "power",
        "memory", "speed", "storage", "dns", "cloud", "sunny", "rainy", "ac_unit", "thunderstorm",
        "visibility", "screenshot_monitor", "fullscreen", "crop_free", "layers", "radar", "map",
        "my_location", "science", "shield", "security", "workspace_premium", "military_tech",
        "group", "person", "account_circle", "calendar_month", "schedule", "history", "keyboard",
        "language", "info", "warning", "error", "circle", "radio_button_checked", "play_circle",
        "folder", "folder_open", "image", "desktop_windows", "window", "unfold_more",
        "drag_indicator", "crop_square", "stop_circle", "home", "autorenew", "filter_list", "sort"
    ]

    Row {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 20
        spacing: 20

        Repeater {
            model: ["map", "tune", "power_settings_new", "settings", "notifications"]
            delegate: Column {
                required property string modelData
                spacing: 4
                GfIconButton { icon: parent.modelData }
                GfText { text: parent.modelData; role: "mono"; size: 10; tone: "dim" }
            }
        }
    }

    Grid {
        id: grid
        anchors.fill: parent
        anchors.margins: 20
        columns: 12
        rowSpacing: 4
        columnSpacing: 4

        Repeater {
            model: root.names

            delegate: Item {
                required property string modelData
                width: (grid.width - 11 * 4) / 12
                height: 56

                Rectangle {
                    anchors.fill: parent
                    color: "#121a22"
                    border.width: 1
                    border.color: "#283844"
                }

                GfIcon {
                    anchors.top: parent.top
                    anchors.topMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    name: parent.modelData
                    iconSize: 22
                    color: "#eae6dc"
                }

                GfText {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: parent.modelData
                    role: "mono"
                    size: 7
                    tone: "faint"
                }
            }
        }
    }
}
