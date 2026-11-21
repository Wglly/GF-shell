import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// Battlefield-style soldier dossier with rank and service record.
Column {
    id: root
    property bool compact: false
    spacing: Theme.fpx(5)

    readonly property string rank: Theme.bf4 ? "SERGEANT" : "LIEUTENANT"
    readonly property string rankCode: Theme.bf4 ? "SGT" : "LT"
    readonly property string theater: Theme.bf4 ? "BATTLEFIELD 4" : "BATTLEFIELD 1"

    Item {
        width: parent.width
        height: root.compact ? Theme.fpx(94) : Theme.fpx(108)

        // Rank chevrons, faint behind the dossier.
        Canvas {
            anchors.fill: parent
            opacity: 0.16
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = Theme.accent;
                ctx.lineWidth = Math.max(2, Theme.px(2));
                var w = width * 0.52;
                var x = width - w - Theme.fpx(6);
                var y = height * 0.30;
                for (var i = 0; i < 3; i++) {
                    ctx.beginPath();
                    ctx.moveTo(x, y + i * Theme.fpx(17));
                    ctx.lineTo(x + w / 2, y + Theme.fpx(12) + i * Theme.fpx(17));
                    ctx.lineTo(x + w, y + i * Theme.fpx(17));
                    ctx.stroke();
                }
            }
        }

        // Portrait with dog-tag corner.
        Rectangle {
            x: 0
            y: 0
            width: root.compact ? Theme.fpx(68) : Theme.fpx(78)
            height: parent.height
            color: Theme.alpha(Theme.bg0, 0.85)
            border.width: 1
            border.color: Theme.alpha(Theme.accent2, 0.65)
        }
        Image {
            x: Theme.fpx(4)
            y: Theme.fpx(4)
            width: (root.compact ? Theme.fpx(60) : Theme.fpx(70))
            height: parent.height - Theme.fpx(8)
            source: User.avatar
            cache: false
            fillMode: Image.PreserveAspectCrop
        }
        Rectangle {
            x: 0
            anchors.bottom: parent.bottom
            width: root.compact ? Theme.fpx(68) : Theme.fpx(78)
            height: Theme.fpx(18)
            color: Theme.alpha(Theme.bg0, 0.82)
            Text {
                anchors.centerIn: parent
                text: root.rankCode
                font.family: Theme.fontMono
                font.pixelSize: Theme.fs(9)
                font.bold: true
                font.letterSpacing: 1.5
                color: Theme.accentHi
            }
        }
        Rectangle {
            x: 0
            y: 0
            width: Theme.fpx(2)
            height: parent.height
            color: Theme.accent2
        }

        Column {
            x: root.compact ? Theme.fpx(78) : Theme.fpx(90)
            width: parent.width - x
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            GfText {
                text: "SOLDIER DOSSIER"
                role: "mono"
                size: Theme.sizeTiny - 3
                tracking: 1.8
                color: Theme.alpha(Theme.accent2, 0.9)
            }
            GfText {
                width: parent.width
                text: User.displayName
                role: "display"
                size: root.compact ? Theme.sizeMedium + 2 : Theme.sizeLarge
                tracking: 1.7
                bold: true
                elide: Text.ElideRight
            }
            GfText {
                width: parent.width
                text: root.rank + "  //  " + root.theater
                role: "mono"
                size: Theme.sizeTiny - 1
                color: Theme.alpha(Theme.accent, 0.9)
                elide: Text.ElideRight
            }
            GfText {
                width: parent.width
                text: "UNIT " + (User.opNumber !== "" ? User.opNumber : "G&K-404")
                role: "mono"
                size: Theme.sizeTiny - 2
                tone: "faint"
                elide: Text.ElideRight
            }
        }
    }

    GfDivider { width: parent.width; color: Theme.alpha(Theme.accent2, 0.35) }

    Row {
        width: parent.width
        spacing: Theme.fpx(4)
        Repeater {
            model: [
                { k: "SERVICE", v: "04" },
                { k: "TOURS", v: "12" },
                { k: "STATUS", v: "ACTIVE" }
            ]
            delegate: Column {
                required property var modelData
                width: (root.width - Theme.fpx(8)) / 3
                spacing: 0
                GfText {
                    text: modelData.k
                    role: "mono"
                    size: Theme.sizeTiny - 3
                    color: Theme.alpha(Theme.accent2, 0.7)
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

    GfText {
        visible: !root.compact
        width: parent.width
        text: "SERVICE RECORD · " + User.session + " · " + User.uptime
        role: "mono"
        size: Theme.sizeTiny - 2
        tone: "faint"
        elide: Text.ElideRight
    }
}
