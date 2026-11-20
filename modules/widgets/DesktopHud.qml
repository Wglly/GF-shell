import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// DesktopHud — 桌面常驻 HUD：大时钟、系统生命体征、通讯、当前任务。
// 黑金面板 + 金色标题条，活在 background 层，窗口会盖在它上面。
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "gf-shell-desktop-hud"
    WlrLayershell.keyboardFocus: ShellState.widgetsEditing ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    property date now: new Date()

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    function fracX(f) { return width * f; }
    function fracY(f) { return height * f; }

    readonly property bool clockOn: Settings.get("widgets.clock.enabled", true)
    readonly property bool statsOn: Settings.get("widgets.stats.enabled", true)
    readonly property bool mediaOn: Settings.get("widgets.media.enabled", true)
    readonly property bool missionOn: Settings.get("widgets.mission.enabled", true)
    readonly property bool weatherOn: Settings.get("widgets.weather.enabled", true)
    readonly property bool visOn: Settings.get("widgets.visualizer.enabled", false)
    readonly property bool userOn: Settings.get("widgets.user.enabled", true)
    readonly property bool hudVisible: ShellState.widgetsVisible && ShellState.overlay === "none"

    // 桌面右键：召唤命令轮盘；命令轮盘开启时左键桌面关闭。
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        z: -1
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (ShellState.overlay === "none")
                    ShellState.openCommandRose(mouse.x, mouse.y, root.modelData.name);
                return;
            }
            if (ShellState.commandRose)
                ShellState.closeCommandRose();
        }
    }

    // ------------------------------------------------------------------ 时钟
    Item {
        id: clockWidget
        visible: root.clockOn && root.hudVisible
        enabled: !ShellState.widgetsEditing
        opacity: ShellState.widgetsEditing ? 0.55 : 1
        clip: true
        x: root.fracX(Settings.get("widgets.clock.x", 0.045))
        y: root.fracY(Settings.get("widgets.clock.y", 0.10))
        width: Theme.px(Math.max(160, Settings.get("widgets.clock.width", 360)))
        height: Theme.px(Math.max(80, Settings.get("widgets.clock.height", 168)))

        // 左侧金色竖条 + 细线
        Rectangle {
            x: 0
            y: Theme.px(4)
            width: Theme.px(4)
            height: Theme.px(56)
            color: Theme.accent
        }
        Rectangle {
            x: Theme.px(4)
            y: 0
            width: Theme.px(22)
            height: 1
            color: Theme.accent
        }

        Column {
            x: Theme.px(18)
            spacing: 0

            Row {
                spacing: Theme.px(8)

                GfText {
                    text: Util.clockText(root.now, false, true).replace(/ (AM|PM)$/, "")
                    role: "display"
                    size: Math.min(Theme.fs(118), Math.max(Theme.fs(76), clockWidget.width * 0.20))
                    tracking: 2
                    bold: true
                    color: Theme.text
                }

                Column {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.px(16)
                    spacing: -2

                    GfText {
                        text: Util.pad2(root.now.getSeconds())
                        role: "mono"
                        size: Theme.sizeMedium
                        color: Theme.accent
                    }
                    GfText {
                        text: root.now.getHours() >= 12 ? "PM" : "AM"
                        role: "mono"
                        size: Theme.sizeTiny
                        tone: "faint"
                    }
                }
            }

            GfText {
                text: Util.dateText(root.now, false)
                role: "label"
                size: Theme.sizeNormal
                tracking: 4.4
                color: Theme.alpha(Theme.text, 0.7)
            }
        }

        Row {
            x: Theme.px(18)
            y: clockWidget.height - Theme.px(24)
            spacing: Theme.px(10)

            Rectangle {
                width: Theme.px(46)
                height: 1
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.accent
            }

            GfText {
                text: I18n.t("hud.operations")
                role: "mono"
                size: Theme.sizeTiny
                tracking: 2.2
                color: Theme.alpha(Theme.accent, 0.85)
            }
        }
    }

    // -------------------------------------------------------------- 生命体征
    Item {
        id: statsWidget
        visible: root.statsOn && root.hudVisible
        enabled: !ShellState.widgetsEditing
        opacity: ShellState.widgetsEditing ? 0.55 : 1
        clip: true
        x: root.fracX(Settings.get("widgets.stats.x", 0.045))
        y: root.fracY(Settings.get("widgets.stats.y", 0.42))
        width: Theme.px(Math.max(160, Settings.get("widgets.stats.width", 282)))
        height: Theme.px(Math.max(80, Settings.get("widgets.stats.height", 184)))

        GfFrame {
            anchors.fill: parent
            fill: Theme.alpha(Theme.bg0, 0.68)
            borderColor: Theme.alpha(Theme.accent, 0.45)
            chamfer: Theme.px(6)
            padding: 0
            innerLine: true

            // 标题条
            Rectangle {
                x: 0
                y: 0
                width: parent.width
                height: Theme.px(24)
                color: Theme.alpha(Theme.bg0, 0.9)

                Rectangle {
                    x: 0
                    y: 0
                    width: Theme.px(3)
                    height: parent.height
                    color: Theme.accent
                }

                GfText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.px(10)
                    anchors.verticalCenter: parent.verticalCenter
                    text: I18n.t("hud.vitals")
                    role: "mono"
                    size: Theme.sizeTiny
                    tracking: 1.8
                    color: Theme.accent
                }

                GfText {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.px(8)
                    anchors.verticalCenter: parent.verticalCenter
                    text: "LIVE"
                    role: "mono"
                    size: Theme.sizeTiny - 2
                    color: Theme.alpha(Theme.accent2, 0.9)
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.px(12)
                anchors.topMargin: Theme.px(32)
                spacing: Theme.px(8)

                VitalRow {
                    width: parent.width
                    label: "CPU"
                    value: Stats.cpu
                    caption: Util.pad2(Math.round(Stats.cpu * 100)) + "%"
                    tint: Stats.cpu > 0.85 ? Theme.red : Theme.accent
                }
                VitalRow {
                    width: parent.width
                    label: "MEM"
                    value: Stats.mem
                    caption: Util.gib(Stats.memUsed) + "/" + Util.gib(Stats.memTotal) + "G"
                    tint: Theme.accent
                }
                VitalRow {
                    width: parent.width
                    label: "NET"
                    value: Math.min(1, Stats.netRx / (12 * 1024 * 1024))
                    caption: Util.bytesHuman(Stats.netRx)
                    tint: Theme.accent2
                }
                VitalRow {
                    width: parent.width
                    label: "DISK"
                    value: Stats.diskRatio
                    caption: Math.round(Stats.diskRatio * 100) + "%"
                    tint: Theme.accent
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.alpha(Theme.accent, 0.25)
                }

                Row {
                    width: parent.width
                    spacing: Theme.px(10)

                    GfText { text: "UP " + Util.uptimeText(Stats.uptime); role: "mono"; size: Theme.sizeTiny - 1; tone: "faint" }
                    GfText { text: "LOAD " + Stats.load1.toFixed(2); role: "mono"; size: Theme.sizeTiny - 1; tone: "faint" }
                    GfText { text: Stats.processes + " PROC"; role: "mono"; size: Theme.sizeTiny - 1; tone: "faint" }
                }
            }
        }
    }

    // ---------------------------------------------------------------- 通讯
    Item {
        id: mediaWidget
        visible: root.mediaOn && root.hudVisible
        enabled: !ShellState.widgetsEditing
        opacity: ShellState.widgetsEditing ? 0.55 : 1
        clip: true
        x: root.fracX(Settings.get("widgets.media.x", 0.72))
        y: root.fracY(Settings.get("widgets.media.y", 0.10))
        width: Theme.px(Math.max(160, Settings.get("widgets.media.width", 312)))
        height: Theme.px(Math.max(80, Settings.get("widgets.media.height", 132)))

        GfFrame {
            anchors.fill: parent
            fill: Theme.alpha(Theme.bg0, 0.68)
            borderColor: Theme.alpha(Theme.accent, 0.45)
            chamfer: Theme.px(6)
            padding: 0
            innerLine: true

            Rectangle {
                x: 0
                y: 0
                width: parent.width
                height: Theme.px(24)
                color: Theme.alpha(Theme.bg0, 0.9)

                Rectangle {
                    x: 0
                    y: 0
                    width: Theme.px(3)
                    height: parent.height
                    color: Theme.accent
                }
                GfText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.px(10)
                    anchors.verticalCenter: parent.verticalCenter
                    text: I18n.t("hud.transmission")
                    role: "mono"
                    size: Theme.sizeTiny
                    tracking: 1.8
                    color: Theme.accent
                }
                GfText {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.px(8)
                    anchors.verticalCenter: parent.verticalCenter
                    text: Media.active ? Media.sourceLabel : "STANDBY"
                    role: "mono"
                    size: Theme.sizeTiny - 2
                    color: Media.active ? Theme.alpha(Theme.accent2, 0.9) : Theme.textFaint
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.px(11)
                anchors.topMargin: Theme.px(32)
                spacing: Theme.px(6)

                Row {
                    width: parent.width
                    spacing: Theme.px(9)

                    Rectangle {
                        width: Theme.px(52)
                        height: Theme.px(52)
                        color: Theme.alpha(Theme.panelAlt, 0.8)
                        border.width: 1
                        border.color: Theme.lineColor(Theme.alpha(Theme.accent, 0.5))

                        Image {
                            anchors.fill: parent
                            source: Media.artUrl
                            visible: Media.artUrl !== ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        GfIcon {
                            anchors.centerIn: parent
                            visible: Media.artUrl === ""
                            name: "graphic_eq"
                            iconSize: Theme.px(20)
                            color: Theme.textFaint
                        }
                    }

                    Column {
                        width: parent.width - Theme.px(62)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        GfText {
                            width: parent.width
                            text: Media.active ? Media.title : I18n.t("media.noSignal")
                            role: "ui"
                            size: Theme.sizeSmall
                            color: Media.active ? Theme.text : Theme.textFaint
                            elide: Text.ElideRight
                        }
                        GfText {
                            width: parent.width
                            text: Media.active ? Media.artist : I18n.t("media.awaiting")
                            role: "ui"
                            size: Theme.sizeTiny
                            tone: "faint"
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            width: parent.width
                            height: 2
                            color: Theme.alpha(Theme.text, 0.12)
                            Rectangle {
                                width: parent.width * Media.progress
                                height: 2
                                color: Theme.accent
                            }
                        }

                        GfText {
                            width: parent.width
                            text: Lyrics.current !== "" ? Lyrics.current
                                : (Lyrics.loading ? I18n.t("media.syncing")
                                    : (Media.active ? I18n.t("media.noRecord") : I18n.t("media.awaiting")))
                            role: "ui"
                            size: Theme.sizeTiny
                            color: Lyrics.current !== "" ? Theme.accentHi : Theme.textFaint
                            elide: Text.ElideRight
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: Theme.px(4)

                    GfIconButton { icon: "skip_previous"; glyphSize: Theme.px(13); buttonSize: Theme.px(22); onClicked: Media.previous() }
                    MediaPlayButton { buttonSize: Theme.px(24) }
                    GfIconButton { icon: "skip_next"; glyphSize: Theme.px(13); buttonSize: Theme.px(22); onClicked: Media.next() }
                }
            }
        }
    }

    // ---------------------------------------------------------------- 任务
    Item {
        id: missionWidget
        visible: root.missionOn && root.hudVisible
        enabled: !ShellState.widgetsEditing
        opacity: ShellState.widgetsEditing ? 0.55 : 1
        clip: true
        x: root.fracX(Settings.get("widgets.mission.x", 0.72))
        y: root.fracY(Settings.get("widgets.mission.y", 0.87))
        width: Theme.px(Math.max(160, Settings.get("widgets.mission.width", 312)))
        height: Theme.px(Math.max(80, Settings.get("widgets.mission.height", 128)))

        GfFrame {
            anchors.fill: parent
            fill: Theme.alpha(Theme.bg0, 0.68)
            borderColor: Theme.alpha(Theme.accent, 0.5)
            chamfer: Theme.px(6)
            padding: 0
            innerLine: true

            Rectangle {
                x: 0
                y: 0
                width: parent.width
                height: Theme.px(24)
                color: Theme.alpha(Theme.bg0, 0.9)

                Rectangle {
                    x: 0
                    y: 0
                    width: Theme.px(3)
                    height: parent.height
                    color: Theme.red
                }
                GfText {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.px(10)
                    anchors.verticalCenter: parent.verticalCenter
                    text: I18n.t("hud.currentMission")
                    role: "mono"
                    size: Theme.sizeTiny
                    tracking: 1.8
                    color: Theme.accent
                }
                GfText {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.px(8)
                    anchors.verticalCenter: parent.verticalCenter
                    text: I18n.t("hud.priorityHigh")
                    role: "mono"
                    size: Theme.sizeTiny - 2
                    color: Theme.red
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.px(11)
                anchors.topMargin: Theme.px(30)
                spacing: Theme.px(4)

                GfText {
                    text: "OPERATION NIGHTFALL"
                    role: "display"
                    size: Theme.sizeMedium + 1
                    tracking: 2
                    bold: true
                    color: Theme.text
                }

                GfText {
                    text: "维持 SEC-09 补给线，等待梯队 404 回报。"
                    role: "ui"
                    size: Theme.sizeTiny
                    tone: "dim"
                }

                Rectangle {
                    width: parent.width
                    height: 4
                    color: Theme.alpha(Theme.text, 0.12)
                    Rectangle {
                        width: parent.width * ((root.now.getHours() * 60 + root.now.getMinutes()) / 1440)
                        height: 4
                        color: Theme.accent
                    }
                }

                Row {
                    width: parent.width
                    GfText {
                        text: Util.opNumber("nightfall")
                        role: "mono"
                        size: Theme.sizeTiny - 1
                        tone: "faint"
                    }
                    Item { width: parent.width - 120; height: 1 }
                    GfText {
                        text: "ETA " + Util.pad2(24 - root.now.getHours()) + "H"
                        role: "mono"
                        size: Theme.sizeTiny - 1
                        tone: "faint"
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------------- 天气
    Item {
        id: weatherWidget
        visible: root.weatherOn && root.hudVisible
        enabled: !ShellState.widgetsEditing
        opacity: ShellState.widgetsEditing ? 0.55 : 1
        clip: true
        x: root.fracX(Settings.get("widgets.weather.x", 0.045))
        y: root.fracY(Settings.get("widgets.weather.y", 0.72))
        width: Theme.px(Math.max(160, Settings.get("widgets.weather.width", 282)))
        height: Theme.px(Math.max(80, Settings.get("widgets.weather.height", 150)))

        GfFrame {
            anchors.fill: parent
            fill: Theme.alpha(Theme.bg0, 0.68)
            borderColor: Theme.alpha(Theme.accent, 0.45)
            chamfer: Theme.px(6)
            padding: 0
            innerLine: true

            Rectangle {
                x: 0; y: 0
                width: parent.width; height: Theme.px(24)
                color: Theme.alpha(Theme.bg0, 0.9)
                Rectangle { x: 0; y: 0; width: Theme.px(3); height: parent.height; color: Theme.accent }
                GfText {
                    anchors.left: parent.left; anchors.leftMargin: Theme.px(10)
                    anchors.verticalCenter: parent.verticalCenter
                    text: I18n.t("hud.weather")
                    role: "mono"; size: Theme.sizeTiny; tracking: 1.8; color: Theme.accent
                }
                GfText {
                    anchors.right: parent.right; anchors.rightMargin: Theme.px(8)
                    anchors.verticalCenter: parent.verticalCenter
                    text: Weather.ok ? I18n.t("common.live") : (Weather.loading ? I18n.t("common.loading") : I18n.t("common.noData"))
                    role: "mono"; size: Theme.sizeTiny - 2
                    color: Weather.ok ? Theme.alpha(Theme.accent2, 0.9) : Theme.textFaint
                }
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: Theme.px(12)
                anchors.rightMargin: Theme.px(12)
                anchors.topMargin: Theme.px(34)
                spacing: Theme.px(10)

                WeatherIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    kind: Weather.iconName
                    color: Theme.accent
                    implicitWidth: Theme.px(42)
                    implicitHeight: Theme.px(42)
                }

                Column {
                    spacing: -4
                    GfText {
                        text: Weather.ok ? Math.round(Weather.tempC) + "°" : "--°"
                        role: "display"
                        size: Theme.sizeTitle
                        bold: true
                        color: Theme.text
                    }
                    GfText {
                        text: Weather.ok
                            ? I18n.t("hud." + (Weather.iconName === "sun" ? "clear"
                                : (Weather.iconName === "cloud" ? "cloudy" : Weather.iconName)))
                            : I18n.t("hud.noData")
                        role: "mono"
                        size: Theme.sizeTiny
                        color: Theme.alpha(Theme.accent, 0.85)
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1
                    GfText {
                        text: Weather.ok ? "H " + Weather.maxC + "°  L " + Weather.minC + "°" : ""
                        role: "mono"; size: Theme.sizeTiny - 1; tone: "faint"
                    }
                    GfText {
                        text: Weather.ok ? "HUM " + Weather.humidity + "%  WIND " + Weather.windKmph : ""
                        role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
                    }
                }
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Theme.px(11)
                GfText {
                    text: Weather.ok ? (Weather.location !== "" ? Weather.location.toUpperCase() : "SECTOR 09") : "—"
                    role: "mono"; size: Theme.sizeTiny - 2; color: Theme.alpha(Theme.accent, 0.55)
                }
                Item { width: parent.width - 200; height: 1 }
                GfText {
                    text: Weather.ok ? Weather.condition.toUpperCase() : ""
                    role: "mono"; size: Theme.sizeTiny - 3; tone: "faint"
                    elide: Text.ElideRight
                    width: Theme.px(170)
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    // ------------------------------------------------------------ 音频频谱
    Item {
        id: visWidget
        visible: root.visOn && root.hudVisible
        enabled: !ShellState.widgetsEditing
        opacity: ShellState.widgetsEditing ? 0.55 : 1
        clip: true
        x: root.fracX(Settings.get("widgets.visualizer.x", 0.72))
        y: root.fracY(Settings.get("widgets.visualizer.y", 0.42))
        width: Theme.px(Math.max(160, Settings.get("widgets.visualizer.width", 312)))
        height: Theme.px(Math.max(80, Settings.get("widgets.visualizer.height", 104)))

        GfFrame {
            anchors.fill: parent
            fill: Theme.alpha(Theme.bg0, 0.68)
            borderColor: Theme.alpha(Theme.accent, 0.45)
            chamfer: Theme.px(6)
            padding: 0
            innerLine: true

            Rectangle {
                x: 0; y: 0
                width: parent.width; height: Theme.px(24)
                color: Theme.alpha(Theme.bg0, 0.9)
                Rectangle { x: 0; y: 0; width: Theme.px(3); height: parent.height; color: Theme.accent }
                GfText {
                    anchors.left: parent.left; anchors.leftMargin: Theme.px(10)
                    anchors.verticalCenter: parent.verticalCenter
                    text: I18n.t("hud.audioSpectrum")
                    role: "mono"; size: Theme.sizeTiny; tracking: 1.8; color: Theme.accent
                }
                GfText {
                    anchors.right: parent.right; anchors.rightMargin: Theme.px(8)
                    anchors.verticalCenter: parent.verticalCenter
                    text: Visualizer.active ? "CAVA / LIVE" : "CAVA / IDLE"
                    role: "mono"; size: Theme.sizeTiny - 2
                    color: Theme.alpha(Theme.accent2, 0.85)
                }
            }

            VisualizerBars {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: Theme.px(12)
                anchors.rightMargin: Theme.px(12)
                anchors.topMargin: Theme.px(34)
                anchors.bottomMargin: Theme.px(12)
                count: 48
                color: Theme.accent
            }

            GfText {
                anchors.centerIn: parent
                visible: !Visualizer.active
                text: I18n.t("hud.noAudio")
                role: "mono"
                size: Theme.sizeTiny
                color: Theme.alpha(Theme.text, 0.3)
                tracking: 1.4
            }
        }
    }

    // ---------------------------------------------------------------- 用户卡
    Item {
        id: userWidget
        visible: root.userOn && root.hudVisible
        enabled: !ShellState.widgetsEditing
        opacity: ShellState.widgetsEditing ? 0.55 : 1
        clip: true
        x: root.fracX(Settings.get("widgets.user.x", 0.72))
        y: root.fracY(Settings.get("widgets.user.y", 0.60))
        width: Theme.px(Math.max(160, Settings.get("widgets.user.width", 312)))
        height: Theme.px(Math.max(80, Settings.get("widgets.user.height", 232)))

        GfFrame {
            anchors.fill: parent
            fill: Theme.alpha(Theme.bg0, 0.68)
            borderColor: Theme.alpha(Theme.accent, 0.45)
            chamfer: Theme.px(6)
            padding: 0
            innerLine: true

            Rectangle {
                x: 0; y: 0
                width: parent.width; height: Theme.px(24)
                color: Theme.alpha(Theme.bg0, 0.9)
                Rectangle { x: 0; y: 0; width: Theme.px(3); height: parent.height; color: Theme.accent }
                GfText {
                    anchors.left: parent.left; anchors.leftMargin: Theme.px(10)
                    anchors.verticalCenter: parent.verticalCenter
                    text: "OPERATOR"
                    role: "mono"; size: Theme.sizeTiny; tracking: 1.8; color: Theme.accent
                }
                GfText {
                    anchors.right: parent.right; anchors.rightMargin: Theme.px(8)
                    anchors.verticalCenter: parent.verticalCenter
                    text: User.opNumber
                    role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
                }
            }

            UserCard {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: Theme.px(12)
                anchors.rightMargin: Theme.px(12)
                anchors.topMargin: Theme.px(32)
                compact: true
                showActions: true
            }
        }
    }


    // ------------------------------------------------------ 桌面布局编辑
    readonly property var widgetDefs: [
        { key: "clock",      x: 0.045, y: 0.10, w: 360, h: 168, minW: 260, minH: 110 },
        { key: "stats",      x: 0.045, y: 0.42, w: 282, h: 184, minW: 220, minH: 130 },
        { key: "media",      x: 0.72,  y: 0.10, w: 312, h: 132, minW: 260, minH: 120 },
        { key: "weather",    x: 0.045, y: 0.72, w: 282, h: 150, minW: 220, minH: 120 },
        { key: "visualizer", x: 0.72,  y: 0.42, w: 312, h: 104, minW: 220, minH: 80 },
        { key: "user",       x: 0.72,  y: 0.60, w: 312, h: 232, minW: 260, minH: 170 },
        { key: "mission",    x: 0.72,  y: 0.87, w: 312, h: 128, minW: 260, minH: 120 }
    ]

    function resetWidgetLayout() {
        for (var i = 0; i < root.widgetDefs.length; i++) {
            var d = root.widgetDefs[i];
            Settings.set("widgets." + d.key + ".x", d.x);
            Settings.set("widgets." + d.key + ".y", d.y);
            Settings.set("widgets." + d.key + ".width", d.w);
            Settings.set("widgets." + d.key + ".height", d.h);
        }
    }

    Item {
        id: editLayer
        anchors.fill: parent
        z: 1000
        visible: ShellState.widgetsEditing
        focus: visible

        Rectangle {
            anchors.fill: parent
            color: Theme.alpha(Theme.bg0, 0.42)
        }

        Canvas {
            id: gridCanvas
            anchors.fill: parent
            property int grid: Math.max(8, Settings.get("widgets.grid", 48))
            onGridChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Component.onCompleted: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                var g = grid;
                if (g < 8)
                    return;
                ctx.lineWidth = 1;
                for (var x = 0; x <= width; x += g) {
                    ctx.strokeStyle = (Math.round(x / g) % 4 === 0)
                        ? "rgba(232,189,79,0.16)" : "rgba(232,189,79,0.07)";
                    ctx.beginPath();
                    ctx.moveTo(x + 0.5, 0);
                    ctx.lineTo(x + 0.5, height);
                    ctx.stroke();
                }
                for (var y = 0; y <= height; y += g) {
                    ctx.strokeStyle = (Math.round(y / g) % 4 === 0)
                        ? "rgba(232,189,79,0.16)" : "rgba(232,189,79,0.07)";
                    ctx.beginPath();
                    ctx.moveTo(0, y + 0.5);
                    ctx.lineTo(width, y + 0.5);
                    ctx.stroke();
                }
            }
        }

        // 顶部工具条
        GfFrame {
            id: editToolbar
            z: 5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Settings.get("bar.position", "top") !== "bottom"
                ? Settings.get("bar.thickness", 38) + Theme.px(12) : Theme.px(12)
            width: Math.min(Theme.px(760), parent.width - Theme.px(40))
            height: Theme.px(62)
            fill: Theme.alpha(Theme.bg0, 0.94)
            borderColor: Theme.alpha(Theme.accent, 0.8)
            chamfer: Theme.px(6)
            padding: 0
            innerLine: true

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.px(14)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.px(10)

                Rectangle {
                    width: Theme.px(4)
                    height: Theme.px(34)
                    color: Theme.accent
                }
                Column {
                    spacing: -2
                    GfText {
                        text: I18n.t("widget.editMode")
                        role: "display"; size: Theme.sizeMedium + 1
                        tracking: 2.4; bold: true
                    }
                    GfText {
                        text: I18n.t("widget.dragHint")
                        role: "ui"; size: Theme.sizeTiny - 1
                        tone: "faint"
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.px(12)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.px(8)

                GfText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "GRID " + Settings.get("widgets.grid", 48)
                    role: "mono"; size: Theme.sizeTiny - 1
                    color: Theme.alpha(Theme.accent, 0.8)
                }
                GfButton {
                    height: Theme.px(30)
                    text: I18n.t("widget.reset")
                    onClicked: root.resetWidgetLayout()
                }
                GfButton {
                    height: Theme.px(30)
                    text: I18n.t("widget.done")
                    checked: true
                    onClicked: ShellState.widgetsEditing = false
                }
            }
        }

        // 每个组件的拖动框
        Repeater {
            model: root.widgetDefs

            delegate: Item {
                id: ghost
                required property var modelData
                readonly property string key: modelData.key
                readonly property int grid: Math.max(8, Settings.get("widgets.grid", 48))
                readonly property bool on: Settings.get("widgets." + key + ".enabled", false)
                readonly property int minW: Theme.px(modelData.minW !== undefined ? modelData.minW : 160)
                readonly property int minH: Theme.px(modelData.minH !== undefined ? modelData.minH : 80)
                property bool dragging: false
                property bool resizing: false

                Binding {
                    target: ghost
                    property: "width"
                    when: !ghost.dragging && !ghost.resizing
                    value: Theme.px(Settings.get("widgets." + ghost.key + ".width", ghost.modelData.w))
                    restoreMode: Binding.RestoreBindingOrValue
                }
                Binding {
                    target: ghost
                    property: "height"
                    when: !ghost.dragging && !ghost.resizing
                    value: Theme.px(Settings.get("widgets." + ghost.key + ".height", ghost.modelData.h))
                    restoreMode: Binding.RestoreBindingOrValue
                }

                Binding {
                    target: ghost
                    property: "x"
                    when: !ghost.dragging
                    value: root.fracX(Settings.get("widgets." + ghost.key + ".x", ghost.modelData.x))
                    restoreMode: Binding.RestoreBindingOrValue
                }
                Binding {
                    target: ghost
                    property: "y"
                    when: !ghost.dragging
                    value: root.fracY(Settings.get("widgets." + ghost.key + ".y", ghost.modelData.y))
                    restoreMode: Binding.RestoreBindingOrValue
                }

                Rectangle {
                    anchors.fill: parent
                    color: ghost.on ? Theme.alpha(Theme.bg0, 0.42) : Theme.alpha(Theme.bg0, 0.22)
                    border.width: ghost.on ? 2 : 1
                    border.color: Theme.lineColor(ghost.on ? Theme.accent : Theme.alpha(Theme.accent, 0.35))
                }

                // 拖动层（在标题/按钮之下）
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor
                    drag.target: ghost
                    drag.axis: Drag.XAndYAxis
                    onPressed: ghost.dragging = true
                    onReleased: {
                        var g = ghost.grid;
                        var nx = Math.max(0, Math.min(root.width - ghost.width, Math.round(ghost.x / g) * g));
                        var ny = Math.max(0, Math.min(root.height - ghost.height, Math.round(ghost.y / g) * g));
                        ghost.x = nx;
                        ghost.y = ny;
                        Settings.set("widgets." + ghost.key + ".x", nx / Math.max(1, root.width));
                        Settings.set("widgets." + ghost.key + ".y", ny / Math.max(1, root.height));
                        ghost.dragging = false;
                    }
                }

                // 标题条
                Rectangle {
                    x: 1
                    y: 1
                    width: parent.width - 2
                    height: Theme.px(26)
                    color: Theme.alpha(Theme.bg0, 0.85)

                    GfText {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.px(8)
                        anchors.verticalCenter: parent.verticalCenter
                        text: I18n.t("set.widgets." + ghost.key)
                        role: "mono"; size: Theme.sizeTiny
                        color: ghost.on ? Theme.accent : Theme.textFaint
                    }
                }

                // 开关
                Rectangle {
                    id: power
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.px(4)
                    anchors.top: parent.top
                    anchors.topMargin: Theme.px(4)
                    width: Theme.px(42)
                    height: Theme.px(18)
                    color: ghost.on ? Theme.accent : "transparent"
                    border.width: 1
                    border.color: Theme.lineColor(ghost.on ? Theme.accentHi : Theme.alpha(Theme.accent, 0.5))

                    GfText {
                        anchors.centerIn: parent
                        text: ghost.on ? I18n.t("common.on") : I18n.t("common.off")
                        role: "mono"; size: Theme.sizeTiny - 3
                        color: ghost.on ? Theme.ink : Theme.textFaint
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Settings.toggle("widgets." + ghost.key + ".enabled")
                    }
                }

                GfText {
                    anchors.centerIn: parent
                    width: parent.width - Theme.px(20)
                    text: ghost.on ? I18n.t("widget.dragHint") : I18n.t("widget.offHint")
                    role: "ui"; size: Theme.sizeTiny
                    color: Theme.alpha(Theme.text, 0.5)
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }

                // 右下角缩放手柄
                Item {
                    id: resizeHandle
                    width: Theme.px(22)
                    height: Theme.px(22)
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.alpha(Theme.bg0, 0.85)
                        border.width: 1
                        border.color: Theme.lineColor(Theme.accent)
                    }
                    Rectangle {
                        x: Theme.px(5); y: Theme.px(13)
                        width: Theme.px(12); height: 1
                        color: Theme.accent
                    }
                    Rectangle {
                        x: Theme.px(9); y: Theme.px(9)
                        width: Theme.px(8); height: 1
                        color: Theme.alpha(Theme.accent, 0.7)
                    }
                    Rectangle {
                        x: Theme.px(13); y: Theme.px(5)
                        width: Theme.px(4); height: 1
                        color: Theme.alpha(Theme.accent, 0.5)
                    }

                    property real startW: 0
                    property real startH: 0
                    property real startSceneX: 0
                    property real startSceneY: 0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.SizeFDiagCursor
                        onPressed: {
                            ghost.resizing = true;
                            resizeHandle.startW = ghost.width;
                            resizeHandle.startH = ghost.height;
                            var p = mapToItem(null, mouse.x, mouse.y);
                            resizeHandle.startSceneX = p.x;
                            resizeHandle.startSceneY = p.y;
                        }
                        onPositionChanged: {
                            if (!pressed)
                                return;
                            var p = mapToItem(null, mouse.x, mouse.y);
                            ghost.width = Math.max(ghost.minW, resizeHandle.startW + (p.x - resizeHandle.startSceneX));
                            ghost.height = Math.max(ghost.minH, resizeHandle.startH + (p.y - resizeHandle.startSceneY));
                        }
                        onReleased: {
                            var g = Math.max(8, ghost.grid);
                            var w = Math.max(ghost.minW, Math.round(ghost.width / g) * g);
                            var h = Math.max(ghost.minH, Math.round(ghost.height / g) * g);
                            ghost.width = w;
                            ghost.height = h;
                            Settings.set("widgets." + ghost.key + ".width", w / Math.max(0.1, Theme.uiScale));
                            Settings.set("widgets." + ghost.key + ".height", h / Math.max(0.1, Theme.uiScale));
                            ghost.resizing = false;
                        }
                    }
                }
            }
        }

        // Esc 退出
        Item {
            anchors.fill: parent
            focus: editLayer.visible
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    ShellState.widgetsEditing = false;
                    event.accepted = true;
                }
            }
        }
    }

    component VitalRow: Row {
        id: vital
        property string label: ""
        property real value: 0
        property string caption: ""
        property color tint: Theme.accent

        spacing: Theme.px(8)
        height: Theme.px(16)

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: vital.label
            role: "mono"
            size: Theme.sizeTiny - 1
            color: Theme.alpha(Theme.accent, 0.8)
            width: Theme.px(30)
        }

        GfMeter {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(90)
            height: Theme.px(5)
            value: vital.value
            segments: 12
            segmentGap: 1
            color: vital.tint
        }

        GfText {
            anchors.verticalCenter: parent.verticalCenter
            text: vital.caption
            role: "mono"
            size: Theme.sizeTiny - 1
            color: Theme.textDim
            width: parent.width - Theme.px(140)
            horizontalAlignment: Text.AlignRight
        }
    }
}
