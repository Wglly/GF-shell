import QtQuick
import qs.modules.common
import qs.modules.common.widgets

// HoI4-only command strip chrome; transparent to input and sits under bar blocks.
Item {
    id: root
    anchors.fill: parent
    visible: Theme.hoi4
    enabled: false

    // Parchment/brass edge treatment
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        y: 0
        height: Theme.px(2)
        color: Theme.alpha(Theme.accentHi, 0.75)
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        y: Theme.px(2)
        height: 1
        color: Theme.alpha(Theme.accent, 0.35)
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.px(2)
        color: Theme.alpha(Theme.accent, 0.55)
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.px(2)
        height: 1
        color: Theme.alpha(Theme.accentDim, 0.5)
    }

    // Brass end caps + hatched editorial strips
    Repeater {
        model: [0, 1]
        Rectangle {
            required property int modelData
            x: modelData === 0 ? 0 : parent.width - Theme.px(52)
            width: Theme.px(52)
            height: parent.height - Theme.px(4)
            y: Theme.px(2)
            color: Theme.alpha(Theme.accentDim, 0.16)
            Image {
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/textures/hatch.png")
                fillMode: Image.Tile
                opacity: 0.45
            }
            Rectangle {
                width: 1
                height: parent.height
                x: modelData === 0 ? parent.width - 1 : 0
                color: Theme.alpha(Theme.accent, 0.45)
            }
        }
    }

    // Centre diamond + double tick, a small general-staff ornament.
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        width: Theme.px(34)
        height: Theme.px(7)
        Rectangle {
            anchors.centerIn: parent
            width: Theme.px(7)
            height: Theme.px(7)
            rotation: 45
            color: Theme.alpha(Theme.accentHi, 0.8)
        }
        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(12)
            height: 1
            color: Theme.alpha(Theme.accent, 0.5)
        }
        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(12)
            height: 1
            color: Theme.alpha(Theme.accent, 0.5)
        }
    }

    // Vertical brass rivets at both ends.
    Repeater {
        model: 3
        Rectangle {
            required property int index
            x: Theme.px(10 + index * 8)
            y: Theme.px(8)
            width: Theme.px(3)
            height: parent.height - Theme.px(16)
            color: Theme.alpha(Theme.accent, 0.18 - index * 0.04)
        }
    }
}
