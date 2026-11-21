import QtQuick
import qs.modules.common

// Theme-specific theatre map behind the Overview (OPERATION MAP) cards.
// Exactly one map is selected by the active preset; other themes have no map layer.
Item {
    id: root
    anchors.fill: parent
    enabled: false
    visible: root.mapFile !== "" && !Theme.light

    readonly property string mapFile: {
        switch (Theme.preset) {
        case "hoi4": return Qt.resolvedUrl("../../assets/maps/hoi4-world-mercator.png");
        case "bf1": return Qt.resolvedUrl("../../assets/maps/bf1-europe.png");
        case "bf4": return Qt.resolvedUrl("../../assets/maps/bf4-world.png");
        case "arknights": return Qt.resolvedUrl("../../assets/maps/arknights-rhodes.png");
        case "gfl":
        case "sangvis":
        case "neural":
        case "arctic": return Qt.resolvedUrl("../../assets/maps/gfl-continent.png");
        default: return "";
        }
    }

    readonly property real mapOpacity: Theme.hoi4 ? 0.72
        : (Theme.bf1 ? 0.62 : (Theme.bf4 ? 0.58 : (Theme.arknights ? 0.55 : 0.48)))

    Image {
        anchors.fill: parent
        source: root.mapFile
        fillMode: Image.PreserveAspectCrop
        cache: true
        opacity: root.mapOpacity
        smooth: true
    }

    // A very light atmospheric scrim keeps widget type readable without hiding the map.
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.bg0, Theme.hoi4 ? 0.10 : 0.16)
    }
}
