import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// TrayCard — expandable system tray + recent messages.
Item {
    id: root

    readonly property var items: SystemTray.items.values
    readonly property var messages: Notifs.history.length > 6 ? Notifs.history.slice(0, 6) : Notifs.history

    implicitHeight: column.implicitHeight

    function iconFor(item) {
        if (!item || !item.icon || item.icon === "")
            return "";
        var p = Quickshell.iconPath(item.icon, "");
        if (!p || p.indexOf("qspixmap") >= 0 || p.indexOf("image://") === 0)
            return "";
        return p;
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.fpx(6)

        GfText {
            text: "TRAY ITEMS  ·  " + root.items.length
            role: "mono"; size: Theme.sizeTiny - 2
            color: Theme.accent; tracking: 1.4
        }

        Column {
            width: parent.width
            spacing: Theme.fpx(2)

            Repeater {
                model: root.items

                delegate: Item {
                    required property var modelData
                    width: parent.width
                    height: Theme.fpx(34)

                    Rectangle {
                        anchors.fill: parent
                        color: trayMouse.containsMouse ? Theme.alpha(Theme.accent, 0.12) : "transparent"
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.fpx(6)
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.fpx(6)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.fpx(8)

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: Theme.fpx(18); height: Theme.fpx(18)
                            source: root.iconFor(modelData)
                            sourceSize.width: Theme.fpx(36)
                            sourceSize.height: Theme.fpx(36)
                            smooth: true
                            visible: status === Image.Ready
                        }
                        GfIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !modelData.icon
                            name: "radio_button_checked"
                            iconSize: Theme.fpx(12)
                            color: Theme.textDim
                        }
                        Column {
                            width: parent.width - Theme.fpx(80)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0
                            GfText {
                                width: parent.width
                                text: modelData.title || modelData.tooltipTitle || "UNIT"
                                role: "ui"; size: Theme.sizeSmall
                                color: Theme.text; elide: Text.ElideRight
                            }
                            GfText {
                                width: parent.width
                                text: modelData.tooltipDescription || "SYSTEM TRAY"
                                role: "mono"; size: Theme.sizeTiny - 3
                                color: Theme.textFaint; elide: Text.ElideRight
                            }
                        }
                        GfText {
                            text: "OPEN"
                            role: "mono"; size: Theme.sizeTiny - 3
                            color: Theme.alpha(Theme.accent, 0.8)
                        }
                    }

                    MouseArea {
                        id: trayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.activate()
                    }
                }
            }

            GfText {
                visible: root.items.length === 0
                text: "NO TRAY ITEMS"
                role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
            }
        }

        GfDivider { width: parent.width; color: Theme.alpha(Theme.accent, 0.3) }

        GfText {
            text: "RECENT MESSAGES  ·  " + root.messages.length
            role: "mono"; size: Theme.sizeTiny - 2
            color: Theme.accent; tracking: 1.4
        }

        Column {
            width: parent.width
            spacing: Theme.fpx(4)

            Repeater {
                model: root.messages

                delegate: Item {
                    required property var modelData
                    width: parent.width
                    height: body.implicitHeight + Theme.fpx(10)

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.alpha(Theme.bg0, 0.35)
                        border.width: 1
                        border.color: Theme.alpha(Theme.accent, 0.15)
                    }

                    Column {
                        id: body
                        x: Theme.fpx(8); y: Theme.fpx(5)
                        width: parent.width - Theme.fpx(16)
                        spacing: 0
                        GfText {
                            width: parent.width
                            text: (modelData.app || "SYSTEM").toUpperCase() + "  //  " + (modelData.summary || "")
                            role: "mono"; size: Theme.sizeTiny - 2
                            color: Theme.accent; elide: Text.ElideRight
                        }
                        GfText {
                            width: parent.width
                            visible: (modelData.body || "") !== ""
                            text: modelData.body || ""
                            role: "ui"; size: Theme.sizeTiny
                            color: Theme.textDim
                            elide: Text.ElideRight
                        }
                        GfText {
                            text: root.timeText(modelData.at)
                            role: "mono"; size: Theme.sizeTiny - 3
                            color: Theme.textFaint
                        }
                    }
                }
            }

            GfText {
                visible: root.messages.length === 0
                text: "NO RECENT MESSAGES"
                role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
            }
        }
    }

    function timeText(at) {
        var d = new Date(at);
        var h = d.getHours(), m = d.getMinutes();
        return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
    }
}
