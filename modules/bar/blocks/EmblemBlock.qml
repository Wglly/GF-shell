import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// EmblemBlock — 左端 G&K 识别块：金线徽章 + 公司名 + 扇区号。
Item {
    id: root

    readonly property string brand: Theme.arknights ? "RHODES"
        : (Theme.bf4 ? "BF4" : (Theme.bf1 ? "BF1" : (Theme.hoi4 ? "HOI4"
        : (Theme.preset === "sangvis" ? "SANGVIS" : (Theme.preset === "neural" ? "NEURAL"
        : (Theme.preset === "arctic" ? "ARCTIC" : "G&K"))))))
    readonly property string subBrand: Theme.arknights ? "RHODES ISLAND"
        : (Theme.bf4 ? "BATTLEFIELD 4" : (Theme.bf1 ? "BATTLEFIELD 1" : (Theme.hoi4 ? "HEARTS OF IRON IV"
        : (Theme.preset === "sangvis" ? "SANGVIS FERRI" : (Theme.preset === "neural" ? "NEURAL CLOUD"
        : (Theme.preset === "arctic" ? "ARCTIC OPS" : "GRIFFIN & KRYUGER"))))))
    readonly property string tag: Theme.hoi4 ? "YEAR" : "SECTOR"
    readonly property string tagValue: Theme.hoi4 ? "1936" : "09"

    implicitWidth: row.implicitWidth + Theme.px(16)
    implicitHeight: Theme.barHeight

    Rectangle {
        anchors.fill: parent
        color: mouse.containsMouse ? Theme.alpha(Theme.accent, 0.08) : "transparent"
        Rectangle {
            visible: mouse.containsMouse
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Theme.accent
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(8)

        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: Qt.resolvedUrl("../../../assets/icons/emblem-accent.png")
            width: Theme.px(22)
            height: Theme.px(22)
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: -Theme.px(2)

            GfText {
                text: root.brand
                role: "display"
                size: Theme.sizeMedium + 1
                tracking: 2.6
                bold: true
                color: Theme.accent
            }

            GfText {
                text: root.subBrand
                role: "label"
                size: Theme.sizeTiny - 3
                tracking: 1.1
                tone: "faint"
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: Theme.px(18)
            color: Theme.alpha(Theme.accent, 0.35)
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: -Theme.px(2)

            GfText {
                text: root.tag
                role: "mono"
                size: Theme.sizeTiny - 3
                tone: "faint"
                tracking: 1.2
            }
            GfText {
                text: root.tagValue
                role: "mono"
                size: Theme.sizeTiny
                color: Theme.accent
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.toggle("launcher")
    }
}
