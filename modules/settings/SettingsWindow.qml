import QtQuick
import Quickshell
import Quickshell.Wayland
import "SgStyle.js" as Sg
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// SettingsWindow — 副官设置。少前式黑白设置界面：
// 纸白底 + 黑色线条/黑带、黑灰按钮，悬停与选中变黄。
PanelWindow {
    id: root

    readonly property bool open: ShellState.overlay === "settings"
    visible: root.open

    function focusedScreen() {
        var name = Compositor.outputName;
        var list = Quickshell.screens;
        for (var i = 0; i < list.length; i++)
            if (list[i].name === name)
                return list[i];
        return list.length > 0 ? list[0] : null;
    }
    screen: root.focusedScreen()
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "gf-shell-settings"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property color settingsVeil: Theme.mix("#f4f1e9", "#8d897f",
        Settings.get("theme.settingsGray", 0.22))
    readonly property real settingsVeilAlpha: Settings.get("theme.settingsOpacity", 0.9)

    property int tab: ShellState.settingsTab
    onTabChanged: ShellState.settingsTab = root.tab

    readonly property var barKinds: [
        { key: "launcher", labelKey: "bar.launcher" },
        { key: "user", labelKey: "bar.user" },
        { key: "workspaces", labelKey: "bar.workspaces" },
        { key: "title", labelKey: "bar.title" },
        { key: "clock", labelKey: "bar.clock" },
        { key: "media", labelKey: "bar.media" },
        { key: "stats", labelKey: "bar.stats" },
        { key: "net", labelKey: "bar.network" },
        { key: "volume", labelKey: "bar.volume" },
        { key: "battery", labelKey: "bar.battery" },
        { key: "tray", labelKey: "bar.tray" },
        { key: "overview", labelKey: "bar.overview" },
        { key: "control", labelKey: "bar.control" },
        { key: "power", labelKey: "bar.power" }
    ]

    readonly property var sidebarKinds: [
        { key: "user", labelKey: "sb.user", descKey: "sb.user.desc" },
        { key: "calendar", labelKey: "sb.calendar", descKey: "sb.calendar.desc" },
        { key: "roster", labelKey: "sb.roster", descKey: "sb.roster.desc" },
        { key: "actions", labelKey: "sb.actions", descKey: "sb.actions.desc" },
        { key: "stats", labelKey: "sb.stats", descKey: "sb.stats.desc" },
        { key: "weather", labelKey: "sb.weather", descKey: "sb.weather.desc" },
        { key: "clock", labelKey: "sb.clock", descKey: "sb.clock.desc" },
        { key: "media", labelKey: "sb.media", descKey: "sb.media.desc" },
        { key: "visualizer", labelKey: "sb.visualizer", descKey: "sb.visualizer.desc" },
        { key: "comms", labelKey: "sb.comms", descKey: "sb.comms.desc" },
        { key: "mission", labelKey: "sb.mission", descKey: "sb.mission.desc" }
    ]

    function barSection(kind) {
        var sections = ["left", "center", "right"];
        for (var i = 0; i < sections.length; i++) {
            var arr = Settings.get("bar." + sections[i], []);
            for (var j = 0; j < arr.length; j++)
                if (arr[j] === kind)
                    return sections[i];
        }
        return "off";
    }

    function setBarSection(kind, section) {
        var sections = ["left", "center", "right"];
        for (var i = 0; i < sections.length; i++) {
            var arr = Settings.get("bar." + sections[i], []).slice();
            var out = [];
            for (var j = 0; j < arr.length; j++)
                if (arr[j] !== kind)
                    out.push(arr[j]);
            if (section === sections[i])
                out.push(kind);
            Settings.set("bar." + sections[i], out);
        }
    }

    function sidebarSide(id) {
        return Settings.get("sidebar.assign." + id, "off");
    }

    function setSidebarSide(id, side) {
        Settings.set("sidebar.assign." + id, side);
    }

    function setHex(key, value) {
        var v = ("" + value).trim();
        if (!/^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(v))
            return;
        Settings.set("theme." + key, v);
        Settings.set("theme.mode", "custom");
        Settings.set("theme.preset", "custom");
    }

    readonly property var tabs: [
        { key: "appearance", label: "APPEARANCE", zh: "外觀" },
        { key: "bar", label: "STATUS BAR", zh: "狀態列" },
        { key: "dock", label: "DOCK", zh: "梯隊" },
        { key: "sidebar", label: "SIDEBARS", zh: "側邊欄" },
        { key: "widgets", label: "WIDGETS", zh: "桌面組件" },
        { key: "wallpaper", label: "WALLPAPER", zh: "壁紙" },
        { key: "system", label: "SYSTEM", zh: "系統" },
        { key: "about", label: "ABOUT", zh: "關於" }
    ]

    // ---------------------------------------------------------------- 背景
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(root.settingsVeil, root.settingsVeilAlpha)
    }

    Canvas {
        anchors.fill: parent
        opacity: 0.5
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var w = width, h = height;
            ctx.strokeStyle = "rgba(20,20,20,0.08)";
            ctx.lineWidth = 1;
            for (var x = 0; x < w; x += 64) {
                ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, h); ctx.stroke();
            }
            for (var y = 0; y < h; y += 64) {
                ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(w, y); ctx.stroke();
            }
            ctx.strokeStyle = "rgba(20,20,20,0.12)";
            for (var i = -h; i < w; i += 220) {
                ctx.beginPath(); ctx.moveTo(i, h); ctx.lineTo(i + h * 0.55, 0); ctx.stroke();
            }
            ctx.strokeStyle = "rgba(20,20,20,0.35)";
            ctx.strokeRect(18, 18, w - 36, h - 36);
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../../assets/textures/halftone.png")
        fillMode: Image.Tile
        opacity: 0.22
    }

    // 键盘
    Item {
        anchors.fill: parent
        focus: root.open
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                ShellState.close();
                event.accepted = true;
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                root.tab = (root.tab + 1) % root.tabs.length;
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                root.tab = (root.tab + root.tabs.length - 1) % root.tabs.length;
                event.accepted = true;
            }
        }
    }

    // ---------------------------------------------------------------- 外框
    Item {
        anchors.fill: parent
        anchors.margins: 18

        Rectangle {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: Theme.px(64)
            color: Sg.ink

            Rectangle {
                x: 0
                y: 0
                width: Theme.px(8)
                height: parent.height
                color: Sg.yellow
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: Theme.px(20)
                anchors.verticalCenter: parent.verticalCenter
                spacing: -4

                Text {
                    text: "ADJUTANT CONFIG"
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fs(24)
                    font.letterSpacing: Theme.px(6)
                    font.bold: true
                    color: Sg.paper
                }
                Row {
                    spacing: Theme.px(10)
                    Rectangle { width: Theme.px(28); height: 1; anchors.verticalCenter: parent.verticalCenter; color: Sg.yellow }
                    Text {
                        text: "副官設置   //   GF-SHELL CONFIGURATION"
                        font.family: Theme.fontUI
                        font.pixelSize: Theme.fs(9)
                        font.letterSpacing: Theme.px(2)
                        color: "#b8b1a3"
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.px(14)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.px(10)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "CONFIG v" + Settings.get("version", 2) + "   ·   AUTO-SAVE"
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fs(9)
                    color: "#9c9587"
                }

                Rectangle { width: 1; height: Theme.px(24); color: "#3a3a3a" }

                Item {
                    width: Theme.px(30)
                    height: Theme.px(30)

                    Rectangle {
                        anchors.fill: parent
                        color: closeMouse.containsMouse ? Sg.yellow : "transparent"
                        border.width: 1
                        border.color: closeMouse.containsMouse ? Sg.yellow : "#5a5a5a"
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: Theme.fs(14)
                        color: closeMouse.containsMouse ? Sg.ink : Sg.paper
                    }
                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ShellState.close()
                    }
                }
            }
        }

        Rectangle {
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Theme.px(30)
            color: Sg.ink

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.px(12)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.px(8)
                Rectangle { width: Theme.px(5); height: Theme.px(5); color: Sg.yellow }
                Text {
                    text: I18n.t("set.footer.autoSave")
                    font.family: Theme.fontUI
                    font.pixelSize: Theme.fs(9)
                    color: "#b8b1a3"
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Theme.px(12)
                anchors.verticalCenter: parent.verticalCenter
                text: "GF-SHELL  ·  " + Compositor.backend.toUpperCase() + "  ·  QUICKSHELL 0.3"
                font.family: Theme.fontMono
                font.pixelSize: Theme.fs(9)
                color: "#9c9587"
            }
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: footer.top

            Rectangle {
                id: rail
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Theme.px(224)
                color: Sg.ink

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.px(12)
                    spacing: Theme.px(2)

                    Text {
                        x: Theme.px(8)
                        text: "SECTIONS"
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fs(9)
                        color: "#8c8679"
                        font.letterSpacing: Theme.px(2)
                    }

                    Item { width: 1; height: Theme.px(6) }

                    Repeater {
                        model: root.tabs

                        delegate: Item {
                            required property var modelData
                            required property int index
                            readonly property bool active: root.tab === index

                            width: parent.width
                            height: Theme.px(46)

                            Rectangle {
                                anchors.fill: parent
                                color: active ? Sg.yellow : (tabMouse.containsMouse ? "#2c2c2c" : "transparent")
                            }
                            Rectangle {
                                x: 0; y: 0
                                width: Theme.px(3)
                                height: parent.height
                                color: active ? Sg.ink : (tabMouse.containsMouse ? Sg.yellow : "transparent")
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.px(12)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.px(10)

                                Text {
                                    text: "0" + (index + 1)
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fs(9)
                                    color: active ? Sg.ink : "#7d7668"
                                }
                                Column {
                                    spacing: -3
                                    Text {
                                        text: modelData.label
                                        font.family: Theme.fontUI
                                        font.pixelSize: Theme.fs(12)
                                        font.letterSpacing: Theme.px(1.6)
                                        font.bold: true
                                        color: active ? Sg.ink : Sg.paper
                                    }
                                    Text {
                                        text: I18n.t("set.tab." + modelData.key)
                                        font.family: Theme.fontUI
                                        font.pixelSize: Theme.fs(8)
                                        color: active ? "#4a463d" : "#8c8679"
                                    }
                                }
                            }

                            MouseArea {
                                id: tabMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.tab = index
                            }
                        }
                    }

                    Item { width: 1; height: Theme.px(10) }
                    Rectangle { width: parent.width - Theme.px(16); x: Theme.px(8); height: 1; color: "#3a3a3a" }
                    Item { width: 1; height: Theme.px(10) }

                    Column {
                        width: parent.width
                        spacing: Theme.px(4)
                        Text {
                            x: Theme.px(8); text: "OPERATOR"
                            font.family: Theme.fontMono; font.pixelSize: Theme.fs(8); color: "#8c8679"
                        }
                        Text {
                            x: Theme.px(8); text: User.displayName + "  //  " + User.opNumber
                            font.family: Theme.fontMono; font.pixelSize: Theme.fs(9); color: Sg.paper
                        }
                        Text {
                            x: Theme.px(8)
                            text: User.session + "  ·  " + User.host
                            font.family: Theme.fontMono; font.pixelSize: Theme.fs(8); color: "#9c9587"
                            elide: Text.ElideRight
                            width: parent.width - Theme.px(16)
                        }
                    }
                }
            }

            Rectangle {
                anchors.left: rail.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Sg.paper

                Item {
                    id: pageHead
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.px(22)
                    height: Theme.px(46)

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: -3
                        Text {
                            text: root.tabs[root.tab].label
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.fs(26)
                            font.letterSpacing: Theme.px(4)
                            font.bold: true
                            color: Sg.ink
                        }
                        Text {
                            text: I18n.t("set.page." + root.tabs[root.tab].key)
                            font.family: Theme.fontUI
                            font.pixelSize: Theme.fs(9)
                            font.letterSpacing: Theme.px(2)
                            color: Sg.mute
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: Theme.px(120)
                        height: Theme.px(24)
                        color: Sg.ink
                        Text {
                            anchors.centerIn: parent
                            text: "SECTION 0" + (root.tab + 1)
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fs(9)
                            color: Sg.yellow
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 2
                        color: Sg.ink
                    }
                }

                Flickable {
                    id: flick
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: pageHead.bottom
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: Theme.px(22)
                    anchors.rightMargin: Theme.px(22)
                    anchors.topMargin: Theme.px(8)
                    clip: true
                    contentWidth: width
                    contentHeight: pageColumn.implicitHeight + Theme.px(24)
                    boundsBehavior: Flickable.StopAtBounds

                    Rectangle {
                        visible: flick.contentHeight > flick.height
                        x: flick.width - 4
                        y: flick.visibleArea.yPosition * flick.height
                        width: 3
                        height: Math.max(20, flick.visibleArea.heightRatio * flick.height)
                        color: Sg.ink
                        opacity: 0.45
                    }

                    Column {
                        id: pageColumn
                        width: flick.width
                        spacing: Theme.px(12)

                        // APPEARANCE
                        Column {
                            visible: root.tab === 0
                            width: parent.width
                            spacing: Theme.px(10)

                            SgSection { width: parent.width; number: "01"; title: "IDENTITY"; note: I18n.t("set.sec.identity") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.themePreset"); desc: I18n.t("set.themePreset.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "gfl", label: "G&K" },
                                        { value: "sangvis", label: "SANGVIS" },
                                        { value: "neural", label: "NEURAL" },
                                        { value: "arctic", label: "ARCTIC" },
                                        { value: "light", label: "DAYLIGHT" }
                                    ]
                                    current: Settings.get("theme.preset", "gfl")
                                    onSelected: value => Settings.applyPreset(value)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.mode"); desc: I18n.t("set.mode.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "dark", label: "DARK" },
                                        { value: "light", label: "LIGHT" },
                                        { value: "custom", label: "CUSTOM" }
                                    ]
                                    current: Settings.get("theme.mode", "dark")
                                    onSelected: value => {
                                        if (value === "dark")
                                            Settings.applyPreset("gfl");
                                        else if (value === "light")
                                            Settings.applyPreset("light");
                                        else {
                                            Settings.set("theme.mode", "custom");
                                            Settings.set("theme.preset", "custom");
                                        }
                                    }
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.accent"); desc: I18n.t("set.accent.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "#e8bd4f", label: "GOLD" },
                                        { value: "#d34a34", label: "RED" },
                                        { value: "#6f9bc4", label: "STEEL" },
                                        { value: "#e9e5da", label: "PAPER" }
                                    ]
                                    current: Settings.get("theme.accent", "#e8bd4f")
                                    onSelected: value => Settings.set("theme.accent", value)
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "SURFACE"; note: I18n.t("set.sec.surface") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.uiScale"); desc: I18n.t("set.uiScale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0.8; to: 1.3; step: 0.05; decimals: 2
                                    value: Settings.get("theme.scale", 1.0)
                                    onMoved: v => Settings.set("theme.scale", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.fontScale"); desc: I18n.t("set.fontScale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0.8; to: 1.4; step: 0.05; decimals: 2
                                    value: Settings.get("theme.fontScale", 1.0)
                                    onMoved: v => Settings.set("theme.fontScale", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.panelOpacity"); desc: I18n.t("set.panelOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0.5; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("theme.panelOpacity", 0.95)
                                    onMoved: v => Settings.set("theme.panelOpacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.animations"); desc: I18n.t("set.animations.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("theme.animations", true)
                                    onToggled: Settings.toggle("theme.animations")
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.brackets"); desc: I18n.t("set.brackets.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("theme.brackets", true)
                                    onToggled: Settings.toggle("theme.brackets")
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.scanlines"); desc: I18n.t("set.scanlines.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("theme.scanlines", false)
                                    onToggled: Settings.toggle("theme.scanlines")
                                }
                            }

                            SgSection { width: parent.width; number: "03"; title: "SETTINGS SURFACE"; note: I18n.t("set.settingsSurface") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.settingsOpacity"); desc: I18n.t("set.settingsOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0.5; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("theme.settingsOpacity", 0.9)
                                    onMoved: v => Settings.set("theme.settingsOpacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.settingsGray"); desc: I18n.t("set.settingsGray.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("theme.settingsGray", 0.22)
                                    onMoved: v => Settings.set("theme.settingsGray", v)
                                }
                            }

                            SgSection { width: parent.width; number: "04"; title: "CUSTOM COLORS"; note: I18n.t("set.customColors") }
                            SgRow {
                                width: parent.width; label: "BG0"; desc: I18n.t("set.hex.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(180)
                                    text: Settings.get("theme.bg0", "#070708")
                                    onAccepted: value => root.setHex("bg0", value)
                                }
                            }
                            SgRow {
                                width: parent.width; label: "BG1"; desc: I18n.t("set.hex.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(180)
                                    text: Settings.get("theme.bg1", "#0d0d0f")
                                    onAccepted: value => root.setHex("bg1", value)
                                }
                            }
                            SgRow {
                                width: parent.width; label: "PANEL"; desc: I18n.t("set.hex.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(180)
                                    text: Settings.get("theme.panel", "#141416")
                                    onAccepted: value => root.setHex("panel", value)
                                }
                            }
                            SgRow {
                                width: parent.width; label: "TEXT"; desc: I18n.t("set.hex.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(180)
                                    text: Settings.get("theme.text", "#f2eee3")
                                    onAccepted: value => root.setHex("text", value)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: "ACCENT"; desc: I18n.t("set.hex.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(180)
                                    text: Settings.get("theme.accent", "#e8bd4f")
                                    onAccepted: value => root.setHex("accent", value)
                                }
                            }

                            SgButton {
                                text: I18n.t("set.resetTheme")
                                onClicked: Settings.applyPreset("gfl")
                            }
                        }

                        // BAR
                        Column {
                            visible: root.tab === 1
                            width: parent.width
                            spacing: Theme.px(10)

                            SgSection { width: parent.width; number: "01"; title: "PLACEMENT"; note: I18n.t("set.sec.placement") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.position"); desc: I18n.t("set.position.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [{ value: "top", label: "TOP" }, { value: "bottom", label: "BOTTOM" }]
                                    current: Settings.get("bar.position", "top")
                                    onSelected: v => Settings.set("bar.position", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.thickness"); desc: I18n.t("set.thickness.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 30; to: 56; step: 1
                                    value: Settings.get("bar.thickness", 38)
                                    onMoved: v => Settings.set("bar.thickness", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.autoHide"); desc: I18n.t("set.autoHide.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("bar.autoHide", false)
                                    onToggled: Settings.toggle("bar.autoHide")
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "SURFACE"; note: I18n.t("set.sec.barSurface") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.opacity"); desc: I18n.t("set.opacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0.3; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("bar.opacity", 0.94)
                                    onMoved: v => Settings.set("bar.opacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.grayscale"); desc: I18n.t("set.grayscale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("bar.gray", 0)
                                    onMoved: v => Settings.set("bar.gray", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.blur"); desc: I18n.t("set.blur.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("bar.blur", 0)
                                    onMoved: v => Settings.set("bar.blur", v)
                                }
                            }

                            SgSection { width: parent.width; number: "03"; title: "CLOCK"; note: I18n.t("set.sec.clock") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.clock24"); desc: I18n.t("set.clock24.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("bar.clock24h", true)
                                    onToggled: Settings.toggle("bar.clock24h")
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.seconds"); desc: I18n.t("set.seconds.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("bar.showSeconds", false)
                                    onToggled: Settings.toggle("bar.showSeconds")
                                }
                            }

                            SgSection { width: parent.width; number: "04"; title: "COMPONENTS"; note: I18n.t("set.sec.barComponents") }
                            Repeater {
                                model: root.barKinds
                                delegate: SgRow {
                                    required property var modelData
                                    width: parent.width
                                    label: I18n.t(modelData.labelKey)
                                    desc: "OFF / LEFT / CENTER / RIGHT"
                                    controlWidth: Theme.px(300)
                                    SgChoice {
                                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                        options: [
                                            { value: "off", label: "OFF" },
                                            { value: "left", label: "LEFT" },
                                            { value: "center", label: "CENTER" },
                                            { value: "right", label: "RIGHT" }
                                        ]
                                        current: root.barSection(modelData.key)
                                        onSelected: v => root.setBarSection(modelData.key, v)
                                    }
                                }
                            }
                        }

                        // DOCK
                        Column {
                            visible: root.tab === 2
                            width: parent.width
                            spacing: Theme.px(10)

                            SgSection { width: parent.width; number: "01"; title: "BEHAVIOUR"; note: I18n.t("set.sec.behaviour") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.enabled"); desc: I18n.t("set.enabled.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("dock.enabled", true)
                                    onToggled: Settings.toggle("dock.enabled")
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.avoid"); desc: I18n.t("set.avoid.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("dock.avoid", true)
                                    onToggled: Settings.toggle("dock.avoid")
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.autoHide"); desc: I18n.t("set.autoHide.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("dock.autoHide", true)
                                    onToggled: Settings.toggle("dock.autoHide")
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.trigger"); desc: I18n.t("set.trigger.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 4; to: 48; step: 1
                                    value: Settings.get("dock.trigger", 24)
                                    onMoved: v => Settings.set("dock.trigger", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.position"); desc: I18n.t("set.position.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [{ value: "bottom", label: "BOTTOM" }, { value: "top", label: "TOP" }]
                                    current: Settings.get("dock.position", "bottom")
                                    onSelected: v => Settings.set("dock.position", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.maxItems"); desc: I18n.t("set.maxItems.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 5; to: 12; step: 1
                                    value: Settings.get("dock.maxItems", 9)
                                    onMoved: v => Settings.set("dock.maxItems", v)
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "SIZE & LOOK"; note: I18n.t("set.sec.dockLook") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.iconSize"); desc: I18n.t("set.iconSize.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 32; to: 64; step: 1
                                    value: Settings.get("dock.iconSize", 44)
                                    onMoved: v => Settings.set("dock.iconSize", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.opacity"); desc: I18n.t("set.opacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0.3; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("dock.opacity", 0.94)
                                    onMoved: v => Settings.set("dock.opacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.grayscale"); desc: I18n.t("set.grayscale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("dock.gray", 0)
                                    onMoved: v => Settings.set("dock.gray", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.blur"); desc: I18n.t("set.blur.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("dock.blur", 0)
                                    onMoved: v => Settings.set("dock.blur", v)
                                }
                            }
                        }

                        // SIDEBARS
                        Column {
                            visible: root.tab === 3
                            width: parent.width
                            spacing: Theme.px(10)

                            SgSection { width: parent.width; number: "01"; title: "LEFT SIDEBAR"; note: I18n.t("set.sec.left") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.enabled"); desc: I18n.t("set.leftEnabled.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("sidebar.left.enabled", true)
                                    onToggled: Settings.toggle("sidebar.left.enabled")
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.width"); desc: I18n.t("set.width.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 280; to: 460; step: 2
                                    value: Settings.get("sidebar.left.width", 356)
                                    onMoved: v => Settings.set("sidebar.left.width", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.height"); desc: I18n.t("set.height.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0.4; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("sidebar.left.height", 0.92)
                                    onMoved: v => Settings.set("sidebar.left.height", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.align"); desc: I18n.t("set.align.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "top", label: "TOP" },
                                        { value: "center", label: "CENTER" },
                                        { value: "bottom", label: "BOTTOM" }
                                    ]
                                    current: Settings.get("sidebar.left.align", "top")
                                    onSelected: v => Settings.set("sidebar.left.align", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.opacity"); desc: I18n.t("set.opacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0.4; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("sidebar.left.opacity", 0.96)
                                    onMoved: v => Settings.set("sidebar.left.opacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.grayscale"); desc: I18n.t("set.grayscale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("sidebar.left.gray", 0)
                                    onMoved: v => Settings.set("sidebar.left.gray", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.blur"); desc: I18n.t("set.blur.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("sidebar.left.blur", 0)
                                    onMoved: v => Settings.set("sidebar.left.blur", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.delay"); desc: I18n.t("set.delay.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 200; to: 1400; step: 50
                                    value: Settings.get("sidebar.left.delay", 650)
                                    onMoved: v => Settings.set("sidebar.left.delay", v)
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "RIGHT SIDEBAR"; note: I18n.t("set.sec.right") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.enabled"); desc: I18n.t("set.rightEnabled.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("sidebar.right.enabled", true)
                                    onToggled: Settings.toggle("sidebar.right.enabled")
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.width"); desc: I18n.t("set.width.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 280; to: 460; step: 2
                                    value: Settings.get("sidebar.right.width", 372)
                                    onMoved: v => Settings.set("sidebar.right.width", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.height"); desc: I18n.t("set.height.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0.4; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("sidebar.right.height", 0.92)
                                    onMoved: v => Settings.set("sidebar.right.height", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.align"); desc: I18n.t("set.align.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "top", label: "TOP" },
                                        { value: "center", label: "CENTER" },
                                        { value: "bottom", label: "BOTTOM" }
                                    ]
                                    current: Settings.get("sidebar.right.align", "top")
                                    onSelected: v => Settings.set("sidebar.right.align", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.opacity"); desc: I18n.t("set.opacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0.4; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("sidebar.right.opacity", 0.96)
                                    onMoved: v => Settings.set("sidebar.right.opacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.grayscale"); desc: I18n.t("set.grayscale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("sidebar.right.gray", 0)
                                    onMoved: v => Settings.set("sidebar.right.gray", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.blur"); desc: I18n.t("set.blur.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("sidebar.right.blur", 0)
                                    onMoved: v => Settings.set("sidebar.right.blur", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.delay"); desc: I18n.t("set.delay.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 200; to: 1400; step: 50
                                    value: Settings.get("sidebar.right.delay", 650)
                                    onMoved: v => Settings.set("sidebar.right.delay", v)
                                }
                            }

                            SgSection { width: parent.width; number: "03"; title: "COMPONENTS"; note: I18n.t("set.sec.sidebarComponents") }
                            Repeater {
                                model: root.sidebarKinds
                                delegate: SgRow {
                                    required property var modelData
                                    width: parent.width
                                    label: I18n.t(modelData.labelKey)
                                    desc: I18n.t(modelData.descKey)
                                    controlWidth: Theme.px(250)
                                    SgChoice {
                                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                        options: [
                                            { value: "off", label: "OFF" },
                                            { value: "left", label: "LEFT" },
                                            { value: "right", label: "RIGHT" }
                                        ]
                                        current: root.sidebarSide(modelData.key)
                                        onSelected: v => root.setSidebarSide(modelData.key, v)
                                    }
                                }
                            }
                        }

                        // WIDGETS
                        Column {
                            visible: root.tab === 4
                            width: parent.width
                            spacing: Theme.px(10)

                            SgSection { width: parent.width; number: "01"; title: "DESKTOP WIDGETS"; note: I18n.t("set.sec.widgets") }
                            Repeater {
                                model: [
                                    { key: "clock", label: "CLOCK", desc: "大時計 + 日期 + 秒" },
                                    { key: "stats", label: "SYSTEM VITALS", desc: "CPU / MEM / NET / DISK" },
                                    { key: "media", label: "MEDIA", desc: "通訊 + 歌詞 + 頻譜" },
                                    { key: "weather", label: "WEATHER", desc: "wttr.in 即時天氣" },
                                    { key: "visualizer", label: "VISUALIZER", desc: "cava 音樂頻譜" },
                                    { key: "user", label: "USER CARD", desc: "操作員 / 會話 / 上線時間" },
                                    { key: "mission", label: "MISSION", desc: "當前任務卡" }
                                ]

                                delegate: SgRow {
                                    id: widgetRow
                                    required property var modelData
                                    readonly property string wkey: modelData.key
                                    width: parent.width
                                    label: I18n.t("set.widgets." + widgetRow.wkey)
                                    desc: I18n.t("set.widgets." + widgetRow.wkey + ".desc")
                                    controlWidth: Theme.px(80)
                                    SgToggle {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        checked: Settings.get("widgets." + widgetRow.wkey + ".enabled", false)
                                        onToggled: Settings.toggle("widgets." + widgetRow.wkey + ".enabled")
                                    }
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "WEATHER SOURCE"; note: I18n.t("set.sec.weather") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.city"); desc: I18n.t("set.city.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200)
                                    text: Settings.get("widgets.weather.city", "")
                                    placeholder: "auto"
                                    onAccepted: value => Settings.set("widgets.weather.city", value)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.resetLayout"); desc: I18n.t("set.resetLayout.desc")
                                SgButton {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: I18n.t("set.reset")
                                    onClicked: Settings.set("widgets", Settings.defaults().widgets)
                                }
                            }

                            SgSection { width: parent.width; number: "03"; title: "LAYOUT"; note: I18n.t("widget.layout") }
                            SgRow {
                                width: parent.width; label: I18n.t("widget.grid"); desc: I18n.t("widget.grid.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 16; to: 96; step: 8
                                    value: Settings.get("widgets.grid", 48)
                                    onMoved: v => Settings.set("widgets.grid", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true
                                label: I18n.t("widget.editLayout")
                                desc: I18n.t("widget.editLayout.desc")
                                SgButton {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: I18n.t("widget.editLayout")
                                    active: true
                                    onClicked: {
                                        ShellState.close();
                                        ShellState.widgetsEditing = true;
                                    }
                                }
                            }
                        }

                        // WALLPAPER
                        Column {
                            visible: root.tab === 5
                            width: parent.width
                            spacing: Theme.px(10)

                            SgSection { width: parent.width; number: "01"; title: "BUILT-IN WALLPAPERS"; note: I18n.t("set.sec.builtin") }
                            Row {
                                width: parent.width
                                spacing: Theme.px(10)

                                Repeater {
                                    model: Wallpapers.builtin

                                    delegate: Item {
                                        required property var modelData
                                        required property int index
                                        readonly property bool active: Wallpapers.selected === (Wallpapers.folder + modelData.file)

                                        width: (parent.width - Theme.px(30)) / 4
                                        height: Theme.px(104)

                                        Rectangle {
                                            anchors.fill: parent
                                            color: active ? Sg.yellow : Sg.ink
                                        }
                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            source: Wallpapers.folder + modelData.file
                                            fillMode: Image.PreserveAspectCrop
                                        }
                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            height: Theme.px(20)
                                            color: Sg.ink
                                            opacity: 0.86
                                        }
                                        Text {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 6
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: 4
                                            text: modelData.name
                                            font.family: Theme.fontMono
                                            font.pixelSize: Theme.fs(8)
                                            color: active ? Sg.yellow : Sg.paper
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Wallpapers.choose(index)
                                        }
                                    }
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "CUSTOM IMAGE"; note: I18n.t("set.sec.custom") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.path"); desc: I18n.t("set.path.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(380)
                                    text: Settings.get("wallpaper.path", "")
                                    placeholder: "file:///home/you/Pictures/wallpaper.png"
                                    onAccepted: value => Settings.set("wallpaper.path", value)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.fillMode"); desc: I18n.t("set.fillMode.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "fill", label: "FILL" },
                                        { value: "fit", label: "FIT" },
                                        { value: "stretch", label: "STRETCH" }
                                    ]
                                    current: Settings.get("wallpaper.fillMode", "fill")
                                    onSelected: v => Settings.set("wallpaper.fillMode", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.dim"); desc: I18n.t("set.dim.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.px(200); from: 0; to: 0.6; step: 0.01; decimals: 2
                                    value: Settings.get("wallpaper.dim", 0.06)
                                    onMoved: v => Settings.set("wallpaper.dim", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.enabled"); desc: I18n.t("set.wallEnabled.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("wallpaper.enabled", true)
                                    onToggled: Settings.toggle("wallpaper.enabled")
                                }
                            }
                        }

                        // SYSTEM
                        Column {
                            visible: root.tab === 6
                            width: parent.width
                            spacing: Theme.px(10)

                            SgSection { width: parent.width; number: "01"; title: "SESSION"; note: I18n.t("set.sec.session") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.lang"); desc: I18n.t("set.lang.desc")
                                controlWidth: Theme.px(330)
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "zh_TW", label: "繁中" },
                                        { value: "zh_CN", label: "简中" },
                                        { value: "en", label: "EN" },
                                        { value: "ja", label: "日本語" }
                                    ]
                                    current: I18n.locale
                                    onSelected: v => Settings.set("language", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.keepAwake"); desc: I18n.t("set.keepAwake.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("shell.keepAwake", false)
                                    onToggled: Settings.toggle("shell.keepAwake")
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.osd"); desc: I18n.t("set.osd.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("osd.enabled", true)
                                    onToggled: Settings.toggle("osd.enabled")
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "NOTIFICATIONS"; note: I18n.t("set.sec.notifications") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.dnd"); desc: I18n.t("set.dnd.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("notifications.dnd", false)
                                    onToggled: Settings.toggle("notifications.dnd")
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.toasts"); desc: I18n.t("set.toasts.desc")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("notifications.toasts", true)
                                    onToggled: Settings.toggle("notifications.toasts")
                                }
                            }

                            SgSection { width: parent.width; number: "03"; title: "HOTKEYS"; note: I18n.t("set.sec.hotkeys") }
                            Repeater {
                                model: [
                                    { k: "LAUNCHER", v: "SUPER + SPACE" },
                                    { k: "OVERVIEW", v: "SUPER + TAB" },
                                    { k: "CONTROL", v: "SUPER + SHIFT + C" },
                                    { k: "POWER", v: "SUPER + SHIFT + Q" },
                                    { k: "WIDGETS", v: "SUPER + SHIFT + W" }
                                ]
                                delegate: SgRow {
                                    required property var modelData
                                    width: parent.width
                                    label: modelData.k
                                    desc: I18n.t("set.sec.hotkeys")
                                    controlWidth: Theme.px(210)
                                    Text {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.v
                                        font.family: Theme.fontMono
                                        font.pixelSize: Theme.fs(10)
                                        color: Sg.ink
                                    }
                                }
                            }
                        }

                        // ABOUT
                        Column {
                            visible: root.tab === 7
                            width: parent.width
                            spacing: Theme.px(10)

                            SgSection { width: parent.width; number: "01"; title: "ABOUT"; note: I18n.t("set.sec.about") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.version"); desc: I18n.t("set.version.desc")
                                controlWidth: Theme.px(160)
                                Text {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: "v1.0  //  MIT"
                                    font.family: Theme.fontMono; font.pixelSize: Theme.fs(10); color: Sg.ink
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.runtime"); desc: I18n.t("set.runtime.desc")
                                controlWidth: Theme.px(200)
                                Text {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: Compositor.backend.toUpperCase() + "  ·  " + User.session
                                    font.family: Theme.fontMono; font.pixelSize: Theme.fs(10); color: Sg.ink
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.configFile"); desc: I18n.t("set.configFile.desc")
                                controlWidth: Theme.px(320)
                                Text {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: Settings.path
                                    font.family: Theme.fontMono; font.pixelSize: Theme.fs(9); color: Sg.ink
                                    elide: Text.ElideLeft
                                    width: parent.width
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "ART & LICENSING"; note: I18n.t("set.sec.licensing") }
                            Text {
                                width: parent.width
                                wrapMode: Text.Wrap
                                text: I18n.t("set.license")
                                font.family: Theme.fontUI
                                font.pixelSize: Theme.fs(10)
                                color: Sg.inkSoft
                                lineHeight: 1.4
                            }

                            Row {
                                spacing: Theme.px(8)
                                SgButton { text: I18n.t("set.gfwiki"); onClicked: Qt.openUrlExternally("https://www.gfwiki.org/") }
                                SgButton { text: I18n.t("set.resetAll"); danger: true; onClicked: Settings.reset() }
                            }
                        }

                        Item { width: 1; height: Theme.px(20) }
                    }
                }
            }
        }
    }
}
