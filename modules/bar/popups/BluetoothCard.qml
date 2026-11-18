import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// BluetoothCard — adapter state and paired/known devices.
Item {
    id: root

    readonly property var deviceList: {
        var list = (Blue.devices || []).slice();
        list.sort(function (a, b) {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            return ("" + a.name).localeCompare("" + b.name);
        });
        return list;
    }

    implicitHeight: column.implicitHeight

    component InfoRow: Item {
        property string label: ""
        property string value: ""
        width: parent.width
        height: Theme.fpx(17)

        GfText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.fpx(100)
            text: label
            role: "mono"; size: Theme.sizeTiny - 2
            color: Theme.alpha(Theme.accent, 0.8); tracking: 1
        }
        GfText {
            anchors.left: parent.left
            anchors.leftMargin: Theme.fpx(104)
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: value
            role: "mono"; size: Theme.sizeTiny - 1
            color: Theme.text
            elide: Text.ElideRight
        }
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.fpx(6)

        InfoRow { label: "STATUS"; value: !Blue.available ? "NO ADAPTER" : (Blue.enabled ? "ENABLED" : "OFF") }
        InfoRow { label: "ADAPTER"; value: Blue.name !== "" ? Blue.name : "—" }
        InfoRow { label: "ADDRESS"; value: Blue.address !== "" ? Blue.address : "—" }
        InfoRow { label: "DEVICES"; value: Blue.connectedCount + " CONNECTED / " + Blue.devices.length + " KNOWN" }

        GfDivider { width: parent.width; color: Theme.alpha(Theme.accent, 0.3) }

        Row {
            width: parent.width
            GfText {
                text: "KNOWN DEVICES"
                role: "mono"; size: Theme.sizeTiny - 2
                color: Theme.accent; tracking: 1.4
            }
            Item { width: parent.width - Theme.fpx(160); height: 1 }
            GfText {
                text: Blue.connectedCount + " LINKED"
                role: "mono"; size: Theme.sizeTiny - 3; tone: "faint"
            }
        }

        Column {
            width: parent.width
            spacing: Theme.fpx(2)

            Repeater {
                model: root.deviceList.length > 8 ? root.deviceList.slice(0, 8) : root.deviceList

                delegate: Item {
                    required property var modelData
                    readonly property var dev: modelData
                    width: parent.width
                    height: Theme.fpx(28)

                    Rectangle {
                        anchors.fill: parent
                        color: devMouse.containsMouse ? Theme.alpha(Theme.accent, 0.12)
                            : (dev.connected ? Theme.alpha(Theme.accent, 0.06) : "transparent")
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.fpx(6)
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.fpx(6)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.fpx(8)

                        GfIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "bluetooth"
                            iconSize: Theme.fpx(13)
                            color: dev.connected ? Theme.accent : Theme.textFaint
                        }
                        GfText {
                            width: Theme.fpx(190)
                            text: dev.name || dev.address
                            role: "ui"; size: Theme.sizeSmall
                            color: dev.connected ? Theme.text : Theme.textDim
                            elide: Text.ElideRight
                        }
                        GfText {
                            text: dev.connected ? "CONNECTED" : "PAIRED"
                            role: "mono"; size: Theme.sizeTiny - 3
                            color: dev.connected ? Theme.accent : Theme.textFaint
                        }
                        Item { width: parent.width - Theme.fpx(340); height: 1 }
                        GfText {
                            visible: dev.battery !== undefined && dev.battery > 0
                            text: (dev.battery || 0) + "%"
                            role: "mono"; size: Theme.sizeTiny - 3
                            color: dev.battery > 20 ? Theme.textDim : Theme.red
                        }
                    }

                    MouseArea {
                        id: devMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dev.connected = !dev.connected
                    }
                }
            }

            GfText {
                visible: root.deviceList.length === 0
                text: Blue.enabled ? "NO KNOWN DEVICES" : "BLUETOOTH DISABLED"
                role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
            }
        }

        Row {
            width: parent.width
            spacing: Theme.fpx(6)

            GfButton {
                height: Theme.fpx(26)
                compact: true
                text: Blue.enabled ? "BLUETOOTH OFF" : "BLUETOOTH ON"
                enabled: Blue.available
                onClicked: Blue.toggle()
            }
        }
    }
}
