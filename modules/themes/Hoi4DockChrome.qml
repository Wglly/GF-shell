import QtQuick
import qs.modules.common

// HoI4-only dock chrome. Sits inside the dock frame behind the app icons.
Item {
    id: root
    anchors.fill: parent
    visible: Theme.hoi4
    enabled: false

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Theme.px(2)
        color: Theme.alpha(Theme.accentHi, 0.65)
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.alpha(Theme.accent, 0.35)
    }
    Repeater {
        model: 2
        Rectangle {
            required property int index
            x: index === 0 ? Theme.px(2) : parent.width - Theme.px(5)
            y: Theme.px(4)
            width: Theme.px(3)
            height: parent.height - Theme.px(8)
            color: Theme.alpha(Theme.accent, 0.25)
        }
    }
    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../../assets/textures/hatch.png")
        fillMode: Image.Tile
        opacity: 0.08
    }
}
