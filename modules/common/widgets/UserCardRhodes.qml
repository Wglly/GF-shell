import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// Rhodes Island operator file: class badge, rarity and trust level.
Column {
    id: root
    property bool compact: false
    spacing: Theme.fpx(6)

    Item {
        width: parent.width
        height: root.compact ? Theme.fpx(96) : Theme.fpx(110)

        // Class badge watermark.
        Text {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: "6"
            font.family: Theme.fontDisplay
            font.pixelSize: root.compact ? Theme.fs(68) : Theme.fs(82)
            font.bold: true
            color: Theme.alpha(Theme.accent, 0.08)
        }

        Item {
            width: root.compact ? Theme.fpx(66) : Theme.fpx(76)
            height: parent.height
            Rectangle {
                anchors.fill: parent
                color: Theme.alpha(Theme.bg0, 0.9)
                border.width: 1
                border.color: Theme.alpha(Theme.accent, 0.55)
            }
            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: User.avatar
                cache: false
                fillMode: Image.PreserveAspectCrop
            }
            // Class tag.
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Theme.fpx(18)
                color: Theme.alpha(Theme.bg0, 0.86)
                Text {
                    anchors.centerIn: parent
                    text: "SNIPER"
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fs(8)
                    font.bold: true
                    font.letterSpacing: 1.2
                    color: Theme.accent
                }
            }
            Rectangle {
                x: 0; y: 0
                width: Theme.fpx(20); height: 2
                color: Theme.accent
            }
        }

        Column {
            x: root.compact ? Theme.fpx(78) : Theme.fpx(90)
            width: parent.width - x
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            GfText {
                text: "OPERATOR"
                role: "mono"
                size: Theme.sizeTiny - 2
                tracking: 1.8
                color: Theme.alpha(Theme.accent, 0.85)
            }
            GfText {
                width: parent.width
                text: User.displayName
                role: "display"
                size: root.compact ? Theme.sizeMedium + 3 : Theme.sizeLarge
                tracking: 1.8
                bold: true
                elide: Text.ElideRight
            }
            GfText {
                width: parent.width
                text: "RHODES ISLAND · SPECIALIST"
                role: "mono"
                size: Theme.sizeTiny - 2
                tone: "faint"
                elide: Text.ElideRight
            }
            GfText {
                width: parent.width
                text: "CLASS  SNIPER   ·   RARITY  6★"
                role: "mono"
                size: Theme.sizeTiny - 2
                color: Theme.alpha(Theme.accent, 0.9)
                elide: Text.ElideRight
            }
        }
    }

    Row {
        width: parent.width
        spacing: Theme.fpx(4)
        Repeater {
            model: [
                { k: "LEVEL", v: "90" },
                { k: "TRUST", v: "200" },
                { k: "POTENTIAL", v: "6" }
            ]
            delegate: Column {
                required property var modelData
                width: (root.width - Theme.fpx(8)) / 3
                spacing: 0
                GfText {
                    text: modelData.k
                    role: "mono"
                    size: Theme.sizeTiny - 3
                    color: Theme.alpha(Theme.accent, 0.65)
                }
                GfText {
                    text: modelData.v
                    role: "display"
                    size: Theme.sizeMedium - 1
                    bold: true
                    color: Theme.text
                }
            }
        }
    }

    Row {
        visible: !root.compact
        width: parent.width
        spacing: Theme.fpx(5)
        GfText {
            text: "★★★★★★"
            role: "mono"
            size: Theme.sizeTiny
            color: Theme.accent
        }
        GfText {
            text: User.clearance + "  ·  " + User.session
            role: "mono"
            size: Theme.sizeTiny - 2
            tone: "faint"
            elide: Text.ElideRight
            width: parent.width - Theme.fpx(80)
        }
    }
}
