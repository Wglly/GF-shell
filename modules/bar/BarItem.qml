import QtQuick
import qs.modules.common

// BarItem — 按 kind 动态加载 bar 上的一个块。
// kind: launcher | emblem | workspaces | title | clock | media | stats | net
//       | volume | battery | tray | overview | control | power
Item {
    id: root

    property string kind: ""
    property var bar: null

    implicitWidth: loader.item ? loader.item.implicitWidth : 0
    implicitHeight: loader.item ? loader.item.implicitHeight : root.bar ? root.bar.thickness : Theme.barHeight

    Loader {
        id: loader
        anchors.verticalCenter: parent.verticalCenter
        source: {
            switch (root.kind) {
            case "launcher":
            case "emblem":
                return Qt.resolvedUrl("blocks/EmblemBlock.qml");
            case "user":
                return Qt.resolvedUrl("blocks/UserBlock.qml");
            case "workspaces":
                return Qt.resolvedUrl("blocks/WorkspacesBlock.qml");
            case "title":
                return Qt.resolvedUrl("blocks/TitleBlock.qml");
            case "clock":
                return Qt.resolvedUrl("blocks/ClockBlock.qml");
            case "media":
                return Qt.resolvedUrl("blocks/MediaBlock.qml");
            case "stats":
                return Qt.resolvedUrl("blocks/StatsBlock.qml");
            case "net":
                return Qt.resolvedUrl("blocks/NetBlock.qml");
            case "volume":
                return Qt.resolvedUrl("blocks/VolumeBlock.qml");
            case "battery":
                return Qt.resolvedUrl("blocks/BatteryBlock.qml");
            case "tray":
                return Qt.resolvedUrl("blocks/TrayBlock.qml");
            case "overview":
                return Qt.resolvedUrl("blocks/OverviewBlock.qml");
            case "control":
                return Qt.resolvedUrl("blocks/ControlBlock.qml");
            case "power":
                return Qt.resolvedUrl("blocks/PowerBlock.qml");
            default:
                return "";
            }
        }
    }
}
