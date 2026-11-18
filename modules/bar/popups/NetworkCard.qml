import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// NetworkCard — network link details + nearby Wi-Fi networks.
Item {
    id: root

    property var pendingNetwork: null
    property string psk: ""

    implicitHeight: column.implicitHeight

    function submitPsk() {
        if (!root.pendingNetwork)
            return;
        Net.connect(root.pendingNetwork, root.psk);
        root.pendingNetwork = null;
        root.psk = "";
        if (pskField)
            pskField.text = "";
    }

    component InfoRow: Item {
        property string label: ""
        property string value: ""
        width: parent.width
        height: Theme.fpx(17)

        GfText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.fpx(86)
            text: label
            role: "mono"
            size: Theme.sizeTiny - 2
            color: Theme.alpha(Theme.accent, 0.8)
            tracking: 1
        }
        GfText {
            anchors.left: parent.left
            anchors.leftMargin: Theme.fpx(90)
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: value
            role: "mono"
            size: Theme.sizeTiny - 1
            color: Theme.text
            elide: Text.ElideRight
        }
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.fpx(6)

        InfoRow { label: "STATUS"; value: !Net.wifiEnabled ? "WI-FI OFF" : (Net.online ? "ONLINE" : (Net.portal ? "PORTAL" : "OFFLINE")) }
        InfoRow { label: "SSID"; value: Net.ssid !== "" ? Net.ssid : "—" }
        InfoRow { label: "SECURITY"; value: Net.securityLabel(Net.activeNetwork) }
        InfoRow { label: "HW ADDRESS"; value: Net.activeDevice && Net.activeDevice.address !== "" ? Net.activeDevice.address : "—" }
        InfoRow { label: "DEVICE"; value: Net.activeDevice ? Net.activeDevice.name : (Net.wifiDevice ? Net.wifiDevice.name : "—") }

        Row {
            width: parent.width
            spacing: Theme.fpx(8)
            GfText {
                width: Theme.fpx(86)
                text: "SIGNAL"
                role: "mono"; size: Theme.sizeTiny - 2
                color: Theme.alpha(Theme.accent, 0.8); tracking: 1
            }
            GfMeter {
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.fpx(120); height: Theme.fpx(5)
                value: Net.strength / 100
                segments: 12
                color: Net.bars >= 2 ? Theme.accent : Theme.red
            }
            GfText {
                text: Net.strength + "%"
                role: "mono"; size: Theme.sizeTiny - 1
                color: Theme.textDim
            }
        }

        GfDivider { width: parent.width; color: Theme.alpha(Theme.accent, 0.3) }

        Row {
            width: parent.width
            GfText {
                text: "AVAILABLE NETWORKS"
                role: "mono"; size: Theme.sizeTiny - 2
                color: Theme.accent; tracking: 1.4
            }
            Item { width: parent.width - Theme.fpx(210); height: 1 }
            GfText {
                text: Net.nearbyNetworks.length + " FOUND"
                role: "mono"; size: Theme.sizeTiny - 3; tone: "faint"
            }
        }

        Column {
            width: parent.width
            spacing: Theme.fpx(2)

            Repeater {
                model: Net.nearbyNetworks.length > 8 ? Net.nearbyNetworks.slice(0, 8) : Net.nearbyNetworks

                delegate: Item {
                    required property var modelData
                    readonly property var net: modelData
                    width: parent.width
                    height: Theme.fpx(26)

                    Rectangle {
                        anchors.fill: parent
                        color: netMouse.containsMouse ? Theme.alpha(Theme.accent, 0.12)
                            : (net.connected ? Theme.alpha(Theme.accent, 0.06) : "transparent")
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.fpx(4)
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.fpx(4)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.fpx(6)

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1
                            Repeater {
                                model: 4
                                Rectangle {
                                    width: 2
                                    height: 3 + index * 2.5
                                    anchors.bottom: parent.bottom
                                    color: index < Net.signalBars(net) ? Theme.accent : Theme.alpha(Theme.text, 0.16)
                                }
                            }
                        }
                        GfText {
                            width: Theme.fpx(150)
                            text: net.name
                            role: "ui"; size: Theme.sizeSmall
                            color: net.connected ? Theme.accent : Theme.text
                            elide: Text.ElideRight
                        }
                        GfText {
                            text: net.connected ? "CONNECTED" : Net.securityLabel(net)
                            role: "mono"; size: Theme.sizeTiny - 3
                            color: net.connected ? Theme.accent : Theme.textFaint
                        }
                        Item { width: parent.width - Theme.fpx(300); height: 1 }
                        GfText {
                            text: Math.round((net.signalStrength || 0) * 100) + "%"
                            role: "mono"; size: Theme.sizeTiny - 3
                            tone: "faint"
                        }
                    }

                    MouseArea {
                        id: netMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (net.connected)
                                return;
                            if (Net.isOpen(net)) {
                                Net.connect(net, "");
                            } else {
                                root.pendingNetwork = net;
                                root.psk = "";
                                pskField.text = "";
                            }
                        }
                    }
                }
            }

            GfText {
                visible: Net.nearbyNetworks.length === 0
                text: Net.wifiEnabled ? "SCANNING…" : "WI-FI DISABLED"
                role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
            }
        }

        Row {
            visible: root.pendingNetwork !== null
            width: parent.width
            spacing: Theme.fpx(6)

            GfText {
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.fpx(110)
                text: "PASSWORD"
                role: "mono"; size: Theme.sizeTiny - 2
                color: Theme.accent
            }
            GfTextField {
                id: pskField
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - Theme.fpx(230)
                text: root.psk
                placeholder: root.pendingNetwork ? root.pendingNetwork.name : ""
                echoMode: TextInput.Password
                onAccepted: {
                    root.psk = text;
                    root.submitPsk();
                }
            }
            GfButton {
                anchors.verticalCenter: parent.verticalCenter
                height: Theme.fpx(26)
                compact: true
                text: "JOIN"
                onClicked: {
                    root.psk = pskField.text;
                    root.submitPsk();
                }
            }
            GfButton {
                anchors.verticalCenter: parent.verticalCenter
                height: Theme.fpx(26)
                compact: true
                text: "X"
                square: true
                onClicked: {
                    root.pendingNetwork = null;
                    root.psk = "";
                    pskField.text = "";
                }
            }
        }

        Row {
            width: parent.width
            spacing: Theme.fpx(6)

            GfButton {
                height: Theme.fpx(26)
                compact: true
                text: Net.wifiEnabled ? "WI-FI OFF" : "WI-FI ON"
                onClicked: Net.toggleWifi()
            }
            GfButton {
                height: Theme.fpx(26)
                compact: true
                text: "SCAN"
                enabled: Net.wifiEnabled
                onClicked: Net.scan()
            }
        }
    }
}
