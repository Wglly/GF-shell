import QtQuick
import qs.modules.common

// ThemeEmblemBadge — the larger deployment medal used by the launcher.
// Ribbon + ring + the active theme's sigil; the G&K raster crest is used for GFL.
Item {
    id: root
    property int size: 36
    property bool active: false
    property bool ribbon: true

    width: size
    height: size

    readonly property bool gfl: !(Theme.arknights || Theme.bf4 || Theme.bf1 || Theme.hoi4
        || Theme.preset === "sangvis" || Theme.preset === "neural" || Theme.preset === "arctic")

    // Medal ribbon.
    Row {
        visible: root.ribbon
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -root.size * 0.03
        spacing: root.size * 0.025
        Rectangle {
            width: root.size * 0.10
            height: root.size * 0.22
            rotation: -14
            color: Theme.alpha(Theme.accentDim, 0.9)
        }
        Rectangle {
            width: root.size * 0.10
            height: root.size * 0.22
            rotation: 14
            color: Theme.alpha(Theme.accent, 0.9)
        }
    }

    // Outer medal ring.
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.width: Math.max(1, root.size * 0.025)
        border.color: Theme.alpha(Theme.accent, root.active ? 0.95 : 0.55)
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: root.size * 0.07
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: Theme.alpha(Theme.accent, 0.25)
    }

    Image {
        visible: root.gfl
        anchors.centerIn: parent
        width: root.size * 0.64
        height: root.size * 0.64
        source: Qt.resolvedUrl("../../../assets/icons/emblem-accent.png")
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Loader {
        id: glyph
        visible: !root.gfl
        anchors.centerIn: parent
        width: root.size * 0.66
        height: root.size * 0.66
        source: "ThemeEmblem.qml"
    }
    Binding {
        target: glyph.item
        property: "active"
        value: root.active
        when: glyph.item !== null
    }
}
