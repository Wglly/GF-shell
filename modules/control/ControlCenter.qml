import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// ControlCenter — 战术控制中心：链路、输出、模块、通讯、随媒体。
PanelWindow {
    id: root

    readonly property bool open: ShellState.overlay === "control"
    visible: root.open
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "gf-shell-control"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    readonly property var bt: Bluetooth.defaultAdapter

    // 半透明遮罩 + 点击面板外关闭
    Item {
        anchors.fill: parent
        focus: root.open
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                ShellState.close();
                event.accepted = true;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.bg0, 0.3)

        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.close()
        }
    }

    GfFrame {
        id: panel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.barHeight + Theme.px(8)
        anchors.rightMargin: Theme.px(8)
        width: Theme.px(392)
        height: content.implicitHeight + Theme.px(34)
        fill: Theme.alpha(Theme.panel, 0.97)
        borderColor: Theme.alpha(Theme.lineBright, 0.7)
        chamfer: Theme.px(12)
        padding: 0
        accentLeft: true

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            id: content
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.px(16)
            height: implicitHeight
            spacing: Theme.px(8)

            // ---------------------------------------------------------- header
            Item {
                width: parent.width
                height: Theme.px(50)

                GfSectionHeader {
                    anchors.left: parent.left
                    anchors.right: headerRight.left
                    anchors.rightMargin: Theme.px(8)
                    anchors.verticalCenter: parent.verticalCenter
                    title: I18n.t("control.title")
                    subtitle: I18n.t("control.subtitle")
                    rule: false
                }

                Row {
                    id: headerRight
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.px(4)

                    Rectangle {
                        width: Theme.px(46)
                        height: Theme.px(16)
                        color: "transparent"
                        border.width: 1
                        border.color: Theme.alpha(Theme.accent, 0.5)

                        GfText {
                            anchors.centerIn: parent
                            text: Util.opNumber("control")
                            role: "mono"
                            size: Theme.sizeTiny - 2
                            color: Theme.accent
                        }
                    }

                    GfIconButton {
                        icon: "close"
                        glyphSize: Theme.px(13)
                        buttonSize: Theme.px(20)
                        danger: true
                        onClicked: ShellState.close()
                    }
                }
            }

            GfDivider {
                width: parent.width
                color: Theme.alpha(Theme.lineBright, 0.4)
            }

            // ------------------------------------------------------------ 链路
            Column {
                width: parent.width
                spacing: Theme.px(6)

                GfText {
                    text: "01  /  LINK"
                    role: "mono"
                    size: Theme.sizeTiny
                    color: Theme.alpha(Theme.accent, 0.8)
                    tracking: 1.8
                }

                LinkRow {
                    width: parent.width
                    glyph: Net.glyph
                    tint: Net.online ? Theme.accent : Theme.textFaint
                    title: Net.kind === "wifi" ? (Net.ssid !== "" ? Net.ssid : "WIRELESS LINK") : Net.label
                    detail: Net.online ? ("CONNECTED  ·  " + Net.strength + "%  ·  LINK STABLE") : "OFFLINE"
                    detailColor: Net.online ? Theme.accent2 : Theme.red
                    active: Net.wifiEnabled
                    onToggled: Net.toggleWifi()
                }

                GfDivider {
                    width: parent.width
                    color: Theme.alpha(Theme.lineBright, 0.22)
                }

                LinkRow {
                    width: parent.width
                    glyph: root.bt && root.bt.enabled ? "bluetooth" : "bluetooth_disabled"
                    tint: root.bt && root.bt.enabled ? Theme.accent2 : Theme.textFaint
                    title: root.bt ? (root.bt.name || "BLUETOOTH ADAPTER") : "NO ADAPTER"
                    detail: root.bt && root.bt.enabled
                        ? ("ACTIVE  ·  " + Bluetooth.devices.values.filter(d => d.connected).length + " LINKED")
                        : "STANDBY"
                    detailColor: root.bt && root.bt.enabled ? Theme.accent2 : Theme.textFaint
                    active: root.bt ? root.bt.enabled : false
                    onToggled: if (root.bt) root.bt.enabled = !root.bt.enabled
                }
            }

            GfDivider {
                width: parent.width
                color: Theme.alpha(Theme.lineBright, 0.4)
            }

            // ------------------------------------------------------------ 输出
            Column {
                width: parent.width
                spacing: Theme.px(2)

                GfText {
                    text: "02  /  OUTPUT"
                    role: "mono"
                    size: Theme.sizeTiny
                    color: Theme.alpha(Theme.accent, 0.8)
                    tracking: 1.8
                }

                Item {
                    width: parent.width
                    height: Theme.px(26)

                    GfIconButton {
                        id: muteBtn
                        anchors.left: parent.left
                        icon: Audio.muted || Audio.volume < 0.01 ? "volume_off" : "volume_up"
                        glyphSize: Theme.px(15)
                        buttonSize: Theme.px(24)
                        danger: Audio.muted
                        onClicked: Audio.toggleMute()
                    }

                    GfText {
                        anchors.left: muteBtn.right
                        anchors.leftMargin: Theme.px(6)
                        anchors.verticalCenter: parent.verticalCenter
                        text: I18n.t("control.volume")
                        role: "label"
                        size: Theme.sizeTiny
                        tracking: 1.2
                        tone: "dim"
                    }

                    GfSlider {
                        anchors.left: muteBtn.right
                        anchors.leftMargin: Theme.px(58)
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        value: Audio.volume
                        segments: 18
                        onMoved: v => Audio.setVolume(v)
                    }
                }

                Item {
                    width: parent.width
                    height: Theme.px(26)
                    visible: System.brightnessAvailable

                    GfIcon {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.px(4)
                        anchors.verticalCenter: parent.verticalCenter
                        name: "brightness_6"
                        iconSize: Theme.px(15)
                        color: Theme.accent2
                    }

                    GfText {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.px(24)
                        anchors.verticalCenter: parent.verticalCenter
                        text: I18n.t("control.brightness")
                        role: "label"
                        size: Theme.sizeTiny
                        tracking: 1.2
                        tone: "dim"
                    }

                    GfSlider {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.px(82)
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        value: System.brightness
                        segments: 18
                        fillColor: Theme.accent2
                        onMoved: v => System.setBrightness(v)
                    }
                }
            }

            GfDivider {
                width: parent.width
                color: Theme.alpha(Theme.lineBright, 0.4)
            }

            // ------------------------------------------------------------ 模块
            Column {
                width: parent.width
                spacing: Theme.px(6)

                GfText {
                    text: "03  /  MODULES"
                    role: "mono"
                    size: Theme.sizeTiny
                    color: Theme.alpha(Theme.accent, 0.8)
                    tracking: 1.8
                }

                Grid {
                    width: parent.width
                    columns: 2
                    columnSpacing: Theme.px(6)
                    rowSpacing: Theme.px(6)

                    CcToggle {
                        width: (parent.width - Theme.px(6)) / 2
                        label: I18n.t("control.wifi")
                        glyph: "wifi"
                        active: Net.wifiEnabled
                        onClicked: Net.toggleWifi()
                    }

                    CcToggle {
                        width: (parent.width - Theme.px(6)) / 2
                        label: I18n.t("control.bluetooth")
                        glyph: "bluetooth"
                        active: root.bt ? root.bt.enabled : false
                        onClicked: if (root.bt) root.bt.enabled = !root.bt.enabled
                    }

                    CcToggle {
                        width: (parent.width - Theme.px(6)) / 2
                        label: I18n.t("control.dnd")
                        glyph: "notifications_off"
                        active: Notifs.dnd
                        onClicked: {
                            Notifs.dnd = !Notifs.dnd;
                            Settings.set("notifications.dnd", Notifs.dnd);
                        }
                    }

                    CcToggle {
                        width: (parent.width - Theme.px(6)) / 2
                        label: I18n.t("control.awake")
                        glyph: "bedtime"
                        active: Settings.get("shell.keepAwake", false)
                        onClicked: Settings.set("shell.keepAwake", !Settings.get("shell.keepAwake", false))
                    }
                }
            }

            // ------------------------------------------------------------ 生命徵象
            Row {
                width: parent.width
                spacing: Theme.px(6)
                height: Theme.px(66)

                VitalsTile {
                    width: (parent.width - Theme.px(12)) / 3
                    height: parent.height
                    label: "CPU"
                    value: Stats.cpu
                    caption: Util.pad2(Math.round(Stats.cpu * 100)) + "%"
                    tint: Stats.cpu > 0.85 ? Theme.red : Theme.accent
                }
                VitalsTile {
                    width: (parent.width - Theme.px(12)) / 3
                    height: parent.height
                    label: "MEM"
                    value: Stats.mem
                    caption: Util.pad2(Math.round(Stats.mem * 100)) + "%"
                    tint: Theme.accent2
                }
                VitalsTile {
                    width: (parent.width - Theme.px(12)) / 3
                    height: parent.height
                    label: "BAT"
                    value: Battery.present ? Battery.level : 0
                    caption: Battery.present ? Battery.label : "AC"
                    tint: Battery.critical ? Theme.red : Theme.ok
                }
            }

            // ------------------------------------------------------------ 通讯
            Item {
                width: parent.width
                height: Theme.px(20)

                GfText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "04  /  " + I18n.t("control.comms")
                    role: "mono"
                    size: Theme.sizeTiny
                    tone: "faint"
                    tracking: 1.4
                }

                GfText {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: I18n.t("control.clear")
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    color: clearMouse.containsMouse ? Theme.accent : Theme.textFaint

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        anchors.margins: -Theme.px(4)
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.clearHistory()
                    }
                }
            }

            Column {
                width: parent.width
                spacing: Theme.px(4)

                Repeater {
                    model: Notifs.history.slice(0, 3)

                    delegate: Item {
                        required property var modelData
                        width: parent.width
                        height: Theme.px(36)

                        Rectangle {
                            anchors.fill: parent
                            color: Theme.alpha(Theme.panelAlt, 0.5)
                        }
                        Rectangle {
                            width: 2
                            height: parent.height
                            color: Theme.accent
                            opacity: 0.7
                        }

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.px(8)
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - Theme.px(50)
                            spacing: 0

                            GfText {
                                width: parent.width
                                text: modelData.app + "  /  " + modelData.summary
                                role: "ui"
                                size: Theme.sizeTiny
                                elide: Text.ElideRight
                            }

                            GfText {
                                width: parent.width
                                text: modelData.body !== "" ? modelData.body : "—"
                                role: "ui"
                                size: Theme.sizeTiny - 1
                                tone: "faint"
                                elide: Text.ElideRight
                            }
                        }

                        GfText {
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.px(8)
                            anchors.verticalCenter: parent.verticalCenter
                            text: Qt.formatDateTime(new Date(modelData.at), "HH:mm")
                            role: "mono"
                            size: Theme.sizeTiny - 2
                            tone: "faint"
                        }
                    }
                }

                Item {
                    visible: Notifs.history.length === 0
                    width: parent.width
                    height: Theme.px(34)

                    GfText {
                        anchors.centerIn: parent
                        text: I18n.t("control.noComms")
                        role: "mono"
                        size: Theme.sizeTiny
                        tone: "faint"
                    }
                }
            }

            // ------------------------------------------------------------ 媒体
            Item {
                width: parent.width
                height: Theme.px(54)
                visible: Media.active

                Rectangle {
                    anchors.fill: parent
                    color: Theme.alpha(Theme.panelAlt, 0.55)
                }

                Image {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.px(44)
                    height: Theme.px(44)
                    source: Media.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.px(52)
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - Theme.px(118)
                    spacing: 0

                    GfText {
                        width: parent.width
                        text: Media.title
                        role: "ui"
                        size: Theme.sizeSmall
                        elide: Text.ElideRight
                    }

                    GfText {
                        width: parent.width
                        text: Media.artist !== "" ? Media.artist : Media.sourceLabel
                        role: "mono"
                        size: Theme.sizeTiny - 1
                        tone: "faint"
                        elide: Text.ElideRight
                    }

                    GfText {
                        width: parent.width
                        visible: Lyrics.current !== ""
                        text: "♪ " + Lyrics.current
                        role: "mono"
                        size: Theme.sizeTiny - 2
                        color: Theme.alpha(Theme.accent, 0.8)
                        elide: Text.ElideRight
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.px(4)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    GfIconButton { icon: "skip_previous"; glyphSize: Theme.px(13); buttonSize: Theme.px(21); onClicked: Media.previous() }
                    MediaPlayButton { buttonSize: Theme.px(22) }
                    GfIconButton { icon: "skip_next"; glyphSize: Theme.px(13); buttonSize: Theme.px(21); onClicked: Media.next() }
                }
            }

            // ------------------------------------------------------------ 底部
            Row {
                width: parent.width
                spacing: Theme.px(6)

                GfButton {
                    width: (parent.width - Theme.px(6)) / 2
                    text: I18n.t("common.settings")
                    icon: "settings"
                    compact: true
                    onClicked: ShellState.open("settings")
                }

                GfButton {
                    width: (parent.width - Theme.px(6)) / 2
                    text: I18n.t("bar.power")
                    icon: "power_settings_new"
                    compact: true
                    danger: true
                    onClicked: ShellState.open("power")
                }
            }

            Row {
                width: parent.width
                spacing: Theme.px(12)

                GfText {
                    text: "UPTIME " + Util.uptimeText(Stats.uptime)
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    tone: "faint"
                }
                GfText {
                    text: "BAT " + Battery.label + (Battery.timeText !== "" ? " / " + Battery.timeText : "")
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    tone: "faint"
                }
                GfText {
                    text: Compositor.backend.toUpperCase()
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    color: Theme.alpha(Theme.accent2, 0.8)
                }
            }
        }
    }

    // 内部小组件：链路行
    component LinkRow: Item {
        id: link
        property string glyph: ""
        property color tint: Theme.accent
        property string title: ""
        property string detail: ""
        property color detailColor: Theme.accent2
        property bool active: false
        signal toggled()

        implicitHeight: Theme.px(42)

        Rectangle {
            width: Theme.px(40)
            height: Theme.px(40)
            color: Theme.alpha(Theme.panelHi, 0.6)
            border.width: 1
            border.color: Theme.alpha(Theme.accent, 0.45)

            GfIcon {
                anchors.centerIn: parent
                name: link.glyph
                iconSize: Theme.px(19)
                color: link.tint
            }
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.px(48)
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.px(104)
            spacing: 0

            GfText {
                width: parent.width
                text: link.title
                role: "ui"
                size: Theme.sizeNormal
                elide: Text.ElideRight
            }

            GfText {
                width: parent.width
                text: link.detail
                role: "mono"
                size: Theme.sizeTiny - 1
                color: link.detailColor
                elide: Text.ElideRight
            }
        }

        GfToggle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: link.active
            onToggled: link.toggled()
        }
    }

    // 内部小组件：生命徵象
    component VitalsTile: GfFrame {
        id: tile
        property string label: ""
        property real value: 0
        property string caption: ""
        property color tint: Theme.accent

        fill: Theme.alpha(Theme.bg0, 0.65)
        borderColor: Theme.alpha(Theme.accent, 0.3)
        chamfer: Theme.px(6)
        padding: Theme.px(6)
        brackets: false

        GfGauge {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: Theme.px(34)
            height: Theme.px(34)
            value: tile.value
            color: tile.tint
            thickness: 2
            segmentLength: Theme.px(5)
        }

        GfText {
            anchors.top: parent.top
            anchors.left: parent.left
            text: tile.label
            role: "mono"
            size: Theme.sizeTiny - 2
            tone: "faint"
        }

        GfText {
            anchors.top: parent.top
            anchors.right: parent.right
            text: tile.caption
            role: "mono"
            size: Theme.sizeTiny - 1
            color: tile.tint
        }

        GfText {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: "SYS"
            role: "mono"
            size: Theme.sizeTiny - 3
            tone: "faint"
        }
    }
}
