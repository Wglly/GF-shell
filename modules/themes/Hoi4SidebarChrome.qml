import QtQuick
import qs.modules.common

// HoI4-only dossier chrome for a sidebar panel.
Item {
    id: root
    anchors.fill: parent
    visible: Theme.hoi4
    enabled: false

    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.px(6)
        color: "transparent"
        border.width: 1
        border.color: Theme.alpha(Theme.accentHi, 0.18)
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Theme.px(3)
        color: Theme.alpha(Theme.accent, 0.5)
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.alpha(Theme.accentDim, 0.55)
    }
    // Corner staff seals.
    Repeater {
        model: [0, 1]
        Rectangle {
            required property int modelData
            x: modelData === 0 ? Theme.px(9) : parent.width - Theme.px(17)
            y: Theme.px(9)
            width: Theme.px(8)
            height: Theme.px(8)
            rotation: 45
            color: Theme.alpha(Theme.accentHi, 0.45)
        }
    }
    Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.px(11)
        text: "GENERAL STAFF"
        font.family: Theme.fontMono
        font.pixelSize: Theme.fs(7)
        color: Theme.alpha(Theme.accent, 0.28)
    }
}
