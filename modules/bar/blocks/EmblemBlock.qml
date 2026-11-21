import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import "."

// EmblemBlock — theme-aware deployment terminal.
// The glyph and wording change per game instead of printing the preset name.
Item {
    id: root

    readonly property bool gfl: !(Theme.arknights || Theme.bf4 || Theme.bf1 || Theme.hoi4
        || Theme.preset === "sangvis" || Theme.preset === "neural" || Theme.preset === "arctic")
    readonly property string title: Theme.hoi4 ? "HIGH COMMAND"
        : (Theme.bf4 ? "COMMANDER" : (Theme.bf1 ? "FIELD HQ" : (Theme.arknights ? "OPERATOR"
        : (Theme.preset === "sangvis" ? "HOSTILE" : (Theme.preset === "neural" ? "NETWORK"
        : (Theme.preset === "arctic" ? "ARCTIC" : "DEPLOY"))))))
    readonly property string subtitle: Theme.hoi4 ? "GENERAL STAFF · 1936"
        : (Theme.bf4 ? "SQUAD NETWORK" : (Theme.bf1 ? "ALLIED COMMAND · 1918"
        : (Theme.arknights ? "MOBILE CITY COMMAND" : (Theme.preset === "sangvis" ? "FERRUM DIVISION"
        : (Theme.preset === "neural" ? "NEURAL NODE" : (Theme.preset === "arctic" ? "FIELD COMMAND"
        : "TACTICAL COMMAND"))))))
    readonly property string tag: (Theme.hoi4 || Theme.bf1) ? "YEAR" : (Theme.bf4 ? "NET" : (Theme.arknights ? "CLASS"
        : (Theme.preset === "sangvis" ? "ALERT" : (Theme.preset === "neural" ? "LINK"
        : (Theme.preset === "arctic" ? "TEMP" : "SECTOR")))))
    readonly property string tagValue: Theme.hoi4 ? "1936"
        : (Theme.bf1 ? "1918" : (Theme.bf4 ? "ACTIVE" : (Theme.arknights ? "OP"
        : (Theme.preset === "sangvis" ? "RED" : (Theme.preset === "neural" ? "SYNC"
        : (Theme.preset === "arctic" ? "-40" : "09"))))))

    implicitWidth: row.implicitWidth + Theme.px(16)
    implicitHeight: Theme.barHeight

    Rectangle {
        anchors.fill: parent
        color: mouse.containsMouse ? Theme.alpha(Theme.accent, 0.10) : "transparent"

        // Theme-specific bottom edge.
        Rectangle {
            visible: mouse.containsMouse
            anchors.bottom: parent.bottom
            width: parent.width
            height: Theme.px(Theme.bf4 ? 2 : 1)
            color: Theme.bf4 ? Theme.accent2 : Theme.accent
        }
        Rectangle {
            visible: !mouse.containsMouse && (Theme.hoi4 || Theme.bf1)
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Theme.alpha(Theme.accent, Theme.hoi4 ? 0.5 : 0.25)
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(8)

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(30)
            height: Theme.px(30)

            // The G&K crest is the only preset-specific raster mark.
            Image {
                visible: root.gfl
                anchors.centerIn: parent
                source: Qt.resolvedUrl("../../../assets/icons/emblem-accent.png")
                width: Theme.px(22)
                height: Theme.px(22)
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: mouse.containsMouse ? 1 : 0.9
            }
            Loader {
                id: emblemLoader
                visible: !root.gfl
                anchors.centerIn: parent
                width: Theme.px(28)
                height: Theme.px(28)
                source: "../../common/widgets/ThemeEmblem.qml"
            }
            Binding {
                target: emblemLoader.item
                property: "active"
                value: mouse.containsMouse
                when: emblemLoader.item !== null
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: -Theme.px(2)

            GfText {
                text: root.title
                role: Theme.arknights ? "mono" : "display"
                size: Theme.sizeMedium + (root.hoi4 || Theme.bf4 ? 0 : 1)
                tracking: Theme.hoi4 ? 1.8 : (Theme.arknights ? 1.2 : 2.4)
                bold: true
                color: Theme.arknights ? Theme.text : Theme.accent
            }

            GfText {
                text: root.subtitle
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
                color: Theme.bf4 ? Theme.accent2 : Theme.accent
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
