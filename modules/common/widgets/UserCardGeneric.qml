import QtQuick
import qs.modules.common
import qs.services

// The original GFL-style operator dossier, used by GFL and other neutral themes.
Column {
    id: root
    property bool compact: false
    spacing: Theme.fpx(10)

    Row {
        width: parent.width
        spacing: Theme.fpx(12)
        Item {
            width: root.compact ? Theme.fpx(54) : Theme.fpx(64)
            height: width
            Rectangle {
                anchors.fill: parent
                color: Theme.alpha(Theme.bg0, 0.75)
                border.width: 1
                border.color: Theme.lineColor(Theme.alpha(Theme.accent, 0.7))
            }
            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: Qt.resolvedUrl("../../../assets/textures/hatch.png")
                fillMode: Image.Tile
                opacity: 0.5
            }
            Image {
                anchors.centerIn: parent
                width: parent.width * 0.66
                height: parent.height * 0.66
                source: User.avatar
                cache: false
                fillMode: Image.PreserveAspectFit
            }
            Rectangle { x: 0; y: 0; width: Theme.fpx(18); height: Theme.fpx(2); color: Theme.accent }
            Rectangle { x: 0; y: 0; width: Theme.fpx(2); height: Theme.fpx(18); color: Theme.accent }
            GfText {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 3
                text: "L3"
                role: "mono"
                size: Theme.sizeTiny - 3
                color: Theme.accent
            }
        }
        Column {
            width: parent.width - (root.compact ? Theme.fpx(66) : Theme.fpx(76))
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            GfText {
                width: parent.width
                text: User.displayName
                role: "display"
                size: root.compact ? Theme.sizeMedium + 2 : Theme.sizeLarge
                tracking: 2.4
                bold: true
                elide: Text.ElideRight
            }
            GfText {
                text: User.role + "  ·  " + User.clearance
                role: "mono"
                size: Theme.sizeTiny - 1
                color: Theme.alpha(Theme.accent, 0.85)
            }
            GfText {
                width: parent.width
                text: User.opNumber + "  //  " + User.session
                role: "mono"
                size: Theme.sizeTiny - 1
                tone: "faint"
                elide: Text.ElideRight
            }
        }
    }

    GfDivider { width: parent.width; color: Theme.alpha(Theme.accent, 0.3) }

    Column {
        width: parent.width
        spacing: Theme.fpx(3)
        Repeater {
            model: [
                { k: I18n.t("user.session"), v: User.session },
                { k: I18n.t("user.host"), v: User.host !== "" ? User.host : "—" },
                { k: I18n.t("user.uptime"), v: User.uptime },
                { k: I18n.t("user.loadout"), v: "TACTICAL / FIELD" }
            ]
            delegate: Row {
                required property var modelData
                width: parent.width
                height: Theme.fpx(15)
                GfText {
                    text: modelData.k
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    color: Theme.alpha(Theme.accent, 0.7)
                    width: Theme.fpx(70)
                }
                GfText {
                    width: parent.width - Theme.fpx(70)
                    text: modelData.v
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    color: Theme.textDim
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
