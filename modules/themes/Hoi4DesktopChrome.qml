import QtQuick
import qs.modules.common
import qs.modules.common.widgets

// HoI4-only situation map treatment behind desktop widgets.
Item {
    id: root
    anchors.fill: parent
    visible: Theme.hoi4
    enabled: false

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../../assets/textures/hexgrid.png")
        fillMode: Image.Tile
        opacity: 0.10
    }

    // Map graticule.
    Repeater {
        model: Math.max(1, Math.floor(parent.width / Theme.px(96)))
        Rectangle {
            required property int index
            x: index * Theme.px(96)
            y: 0
            width: 1
            height: parent.height
            color: Theme.alpha(Theme.accent, 0.055)
        }
    }
    Repeater {
        model: Math.max(1, Math.floor(parent.height / Theme.px(96)))
        Rectangle {
            required property int index
            x: 0
            y: index * Theme.px(96)
            width: parent.width
            height: 1
            color: Theme.alpha(Theme.accent, 0.055)
        }
    }

    // Staff-map border.
    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.px(16)
        color: "transparent"
        border.width: 1
        border.color: Theme.alpha(Theme.accent, 0.22)
    }
    GfCorners {
        anchors.fill: parent
        anchors.margins: Theme.px(13)
        color: Theme.alpha(Theme.accentHi, 0.55)
        size: Theme.px(16)
    }

    // Report cartouche.
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.px(48)
        width: Theme.px(360)
        height: Theme.px(46)
        Rectangle {
            anchors.fill: parent
            color: Theme.alpha(Theme.bg0, 0.45)
            border.width: 1
            border.color: Theme.alpha(Theme.accent, 0.4)
        }
        Column {
            anchors.centerIn: parent
            spacing: -2
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "NATIONAL SITUATION REPORT"
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fs(17)
                font.letterSpacing: 2.6
                font.bold: true
                color: Theme.alpha(Theme.text, 0.72)
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "GENERAL STAFF · CLASSIFIED"
                font.family: Theme.fontMono
                font.pixelSize: Theme.fs(7)
                font.letterSpacing: 1.8
                color: Theme.alpha(Theme.accent, 0.6)
            }
        }
    }

    // Bottom-right archive stamp.
    Column {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.px(28)
        spacing: 1
        Text {
            anchors.right: parent.right
            text: "THE WORLD SITUATION"
            font.family: Theme.fontMono
            font.pixelSize: Theme.fs(7)
            font.letterSpacing: 1.5
            color: Theme.alpha(Theme.accent, 0.4)
        }
        Text {
            anchors.right: parent.right
            text: "1936 — 1948"
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fs(12)
            color: Theme.alpha(Theme.text, 0.35)
        }
    }
}
