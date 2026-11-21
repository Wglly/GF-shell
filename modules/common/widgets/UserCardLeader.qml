import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// HoI4-style head-of-state portrait and national statistics.
Column {
    id: root
    property bool compact: false
    spacing: Theme.fpx(6)

    Item {
        width: parent.width
        height: root.compact ? Theme.fpx(102) : Theme.fpx(118)

        // National flag band behind the portrait.
        Rectangle {
            x: 0
            y: 0
            width: root.compact ? Theme.fpx(76) : Theme.fpx(86)
            height: parent.height
            color: Theme.alpha(Theme.accentDim, 0.22)
            border.width: 1
            border.color: Theme.lineColor(Theme.alpha(Theme.accent, 0.55))
        }
        Repeater {
            model: 3
            Rectangle {
                required property int index
                x: 0
                y: parent.height * (index + 1) / 4
                width: root.compact ? Theme.fpx(76) : Theme.fpx(86)
                height: 1
                color: Theme.alpha(Theme.accent, 0.22)
            }
        }
        Image {
            x: Theme.fpx(5)
            y: Theme.fpx(5)
            width: (root.compact ? Theme.fpx(66) : Theme.fpx(76))
            height: parent.height - Theme.fpx(10)
            source: User.avatar
            cache: false
            fillMode: Image.PreserveAspectCrop
        }
        Rectangle {
            x: 0
            y: 0
            width: Theme.fpx(3)
            height: parent.height
            color: Theme.accentHi
        }

        Column {
            x: root.compact ? Theme.fpx(88) : Theme.fpx(100)
            width: parent.width - x
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            GfText {
                text: "HEAD OF STATE"
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
                text: "GRIFFIN & KRYUGER · FIELD CABINET"
                role: "mono"
                size: Theme.sizeTiny - 2
                tone: "faint"
                elide: Text.ElideRight
            }
            GfText {
                width: parent.width
                text: User.role + "  ·  " + User.clearance
                role: "mono"
                size: Theme.sizeTiny - 1
                color: Theme.alpha(Theme.accent2, 0.95)
                elide: Text.ElideRight
            }
        }
    }

    GfDivider { width: parent.width; color: Theme.alpha(Theme.accent, 0.35) }

    Row {
        width: parent.width
        spacing: Theme.fpx(4)
        Repeater {
            model: [
                { k: "POLITICAL POWER", v: "152" },
                { k: "STABILITY", v: "68%" },
                { k: "WAR SUPPORT", v: "74%" }
            ]
            delegate: Column {
                required property var modelData
                width: (root.width - Theme.fpx(8)) / 3
                spacing: 0
                GfText {
                    text: modelData.k
                    role: "mono"
                    size: Theme.sizeTiny - 3
                    color: Theme.alpha(Theme.accent, 0.6)
                    elide: Text.ElideRight
                    width: parent.width
                }
                GfText {
                    text: modelData.v
                    role: "display"
                    size: Theme.sizeMedium
                    bold: true
                    color: Theme.text
                }
            }
        }
    }

    Row {
        visible: !root.compact
        width: parent.width
        spacing: Theme.fpx(4)
        Repeater {
            model: ["ORGANIZER", "INFANTRY LEADER"]
            delegate: Rectangle {
                required property string modelData
                width: trait.implicitWidth + Theme.fpx(12)
                height: Theme.fpx(18)
                color: Theme.alpha(Theme.accent, 0.12)
                border.width: 1
                border.color: Theme.alpha(Theme.accent, 0.35)
                Text {
                    id: trait
                    anchors.centerIn: parent
                    text: modelData
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fs(7)
                    color: Theme.alpha(Theme.accent, 0.85)
                }
            }
        }
    }
}
