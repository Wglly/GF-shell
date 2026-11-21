import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
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

    readonly property color settingsVeil: Theme.mix(
        Theme.mix("#f4f1e9", "#8d897f", Settings.get("theme.settingsGray", 0.22)),
        Theme.accent, 0.035)
    readonly property real settingsVeilAlpha: Settings.get("theme.settingsOpacity", 0.9)

    property string fontRole: "ui"
    property string fontQuery: ""
    property string cursorQuery: ""

    function fontFor(role) {
        var defaults = { ui: "Chakra Petch", display: "Saira Condensed",
            mono: "Share Tech Mono", label: "Rajdhani" };
        var value = Settings.get("fonts." + role, "");
        return value !== "" ? value : defaults[role];
    }

    function setFont(family) {
        Settings.set("fonts." + root.fontRole, family);
    }

    readonly property var cursorChoices: {
        var q = root.cursorQuery.toLowerCase().trim();
        var out = [];
        for (var i = 0; i < Cursors.themes.length; i++) {
            var name = "" + Cursors.themes[i];
            if (q === "" || name.toLowerCase().indexOf(q) >= 0)
                out.push(name);
        }
        return out;
    }

    readonly property var fontChoices: {
        var q = root.fontQuery.toLowerCase().trim();
        var core = ["Chakra Petch", "Saira Condensed", "Share Tech Mono", "Rajdhani", "Noto Sans CJK SC"];
        var all = core.concat(Fonts.families);
        var seen = {};
        var out = [];
        for (var i = 0; i < all.length; i++) {
            var f = "" + all[i];
            if (f === "" || seen[f])
                continue;
            if (q !== "" && f.toLowerCase().indexOf(q) < 0)
                continue;
            seen[f] = true;
            out.push(f);
        }
        return out;
    }

    property int tab: ShellState.settingsTab
    onTabChanged: {
        ShellState.settingsTab = root.tab;
        if (flick)
            flick.contentY = 0;
    }
    onOpenChanged: if (root.open && flick) flick.contentY = 0

    readonly property var barKinds: [
        { key: "launcher", labelKey: "bar.launcher" },
        { key: "user", labelKey: "bar.user" },
        { key: "workspaces", labelKey: "bar.workspaces" },
        { key: "title", labelKey: "bar.title" },
        { key: "clock", labelKey: "bar.clock" },
        { key: "media", labelKey: "bar.media" },
        { key: "stats", labelKey: "bar.stats" },
        { key: "net", labelKey: "bar.network" },
        { key: "bluetooth", labelKey: "bar.bluetooth" },
        { key: "wallpaper", labelKey: "bar.wallpaper" },
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
        { key: "mission", labelKey: "sb.mission", descKey: "sb.mission.desc" },
        { key: "wallpaper", labelKey: "sb.wallpaper", descKey: "sb.wallpaper.desc" }
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

    function pinByName(value) {
        var q = ("" + value).trim().toLowerCase();
        if (q === "")
            return;
        var ids = (Settings.get("dock.pinned", []) || []).slice();
        if (ids.length >= Settings.get("dock.maxItems", 12))
            return;
        for (var i = 0; i < Apps.apps.length; i++) {
            var app = Apps.apps[i];
            var base = app.path.split("/").pop();
            if (app.name.toLowerCase().indexOf(q) < 0 && base.toLowerCase().indexOf(q) < 0)
                continue;
            var found = false;
            for (var j = 0; j < ids.length; j++)
                if (("" + ids[j]).toLowerCase() === base.toLowerCase())
                    found = true;
            if (!found) {
                ids.push(base);
                Settings.set("dock.pinned", ids);
            }
            return;
        }
    }

    function pickWallpaperDir() {
        if (!wallpaperDirPicker.running)
            wallpaperDirPicker.running = true;
    }

    property Process wallpaperDirPicker: Process {
        command: ["sh", "-c", "zenity --file-selection --directory --title='Wallpaper directory' 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var p = ("" + text).trim();
                if (p !== "")
                    Wallpapers.setDirectory(p);
            }
        }
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
            height: Theme.fpx(64)
            color: Theme.sgBand

            Rectangle {
                x: 0
                y: 0
                width: Theme.fpx(8)
                height: parent.height
                color: Theme.sgAccent
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: Theme.fpx(20)
                anchors.verticalCenter: parent.verticalCenter
                spacing: -4

                Text {
                    text: "ADJUTANT CONFIG"
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fs(24)
                    font.letterSpacing: Theme.fpx(6)
                    font.bold: true
                    color: Theme.sgBandText
                }
                Row {
                    spacing: Theme.fpx(10)
                    Rectangle { width: Theme.fpx(28); height: 1; anchors.verticalCenter: parent.verticalCenter; color: Theme.sgAccent }
                    Text {
                        text: "副官設置   //   GF-SHELL CONFIGURATION"
                        font.family: Theme.fontUI
                        font.pixelSize: Theme.fs(9)
                        font.letterSpacing: Theme.fpx(2)
                        color: Theme.alpha(Theme.sgBandText, 0.65)
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.fpx(14)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.fpx(10)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "CONFIG v" + Settings.get("version", 2) + "   ·   AUTO-SAVE"
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fs(9)
                    color: Theme.alpha(Theme.sgBandText, 0.5)
                }

                Rectangle { width: 1; height: Theme.fpx(24); color: Theme.alpha(Theme.sgBandText, 0.18) }

                Item {
                    width: Theme.fpx(30)
                    height: Theme.fpx(30)

                    Rectangle {
                        anchors.fill: parent
                        color: closeMouse.containsMouse ? Theme.sgAccent : "transparent"
                        border.width: 1
                        border.color: Theme.lineColor(closeMouse.containsMouse ? Theme.sgAccent : Theme.alpha(Theme.sgBandText, 0.35))
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: Theme.fs(14)
                        color: closeMouse.containsMouse ? Theme.sgOnAccent : Theme.sgBandText
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
            height: Theme.fpx(30)
            color: Theme.sgBand

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.fpx(12)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.fpx(8)
                Rectangle { width: Theme.fpx(5); height: Theme.fpx(5); color: Theme.sgAccent }
                Text {
                    text: I18n.t("set.footer.autoSave")
                    font.family: Theme.fontUI
                    font.pixelSize: Theme.fs(9)
                    color: Theme.alpha(Theme.sgBandText, 0.62)
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Theme.fpx(12)
                anchors.verticalCenter: parent.verticalCenter
                text: "GF-SHELL  ·  " + Compositor.backend.toUpperCase() + "  ·  QUICKSHELL 0.3"
                font.family: Theme.fontMono
                font.pixelSize: Theme.fs(9)
                color: Theme.alpha(Theme.sgBandText, 0.5)
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
                width: Theme.fpx(224)
                color: Theme.sgBand

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.fpx(12)
                    spacing: Theme.fpx(2)

                    Text {
                        x: Theme.fpx(8)
                        text: "SECTIONS"
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fs(9)
                        color: Theme.alpha(Theme.sgBandText, 0.45)
                        font.letterSpacing: Theme.fpx(2)
                    }

                    Item { width: 1; height: Theme.fpx(6) }

                    Repeater {
                        model: root.tabs

                        delegate: Item {
                            required property var modelData
                            required property int index
                            readonly property bool active: root.tab === index

                            width: parent.width
                            height: Theme.fpx(46)

                            Rectangle {
                                anchors.fill: parent
                                color: active ? Theme.sgAccent : (tabMouse.containsMouse ? Theme.sgGrayHi : "transparent")
                            }
                            Rectangle {
                                x: 0; y: 0
                                width: Theme.fpx(3)
                                height: parent.height
                                color: active ? Theme.sgOnAccent : (tabMouse.containsMouse ? Theme.sgAccent : "transparent")
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.fpx(12)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.fpx(10)

                                Text {
                                    text: "0" + (index + 1)
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fs(9)
                                    color: active ? Theme.sgOnAccent : Theme.alpha(Theme.sgBandText, 0.55)
                                }
                                Column {
                                    spacing: -3
                                    Text {
                                        text: modelData.label
                                        font.family: Theme.fontUI
                                        font.pixelSize: Theme.fs(12)
                                        font.letterSpacing: Theme.fpx(1.6)
                                        font.bold: true
                                        color: active ? Theme.sgOnAccent : Theme.sgBandText
                                    }
                                    Text {
                                        text: I18n.t("set.tab." + modelData.key)
                                        font.family: Theme.fontUI
                                        font.pixelSize: Theme.fs(8)
                                        color: active ? Theme.alpha(Theme.sgOnAccent, 0.65) : Theme.alpha(Theme.sgBandText, 0.45)
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

                    Item { width: 1; height: Theme.fpx(10) }
                    Rectangle { width: parent.width - Theme.fpx(16); x: Theme.fpx(8); height: 1; color: Theme.alpha(Theme.sgBandText, 0.18) }
                    Item { width: 1; height: Theme.fpx(10) }

                    Column {
                        width: parent.width
                        spacing: Theme.fpx(4)
                        Text {
                            x: Theme.fpx(8)
                            text: Theme.hoi4 ? "HEAD OF STATE"
                                : (Theme.battle ? "COMMANDER" : (Theme.arknights ? "DOCTOR" : "OPERATOR"))
                            font.family: Theme.fontMono; font.pixelSize: Theme.fs(8); color: Theme.alpha(Theme.sgBandText, 0.45)
                        }
                        Text {
                            x: Theme.fpx(8); text: User.displayName + "  //  " + User.opNumber
                            font.family: Theme.fontMono; font.pixelSize: Theme.fs(9); color: Theme.sgBandText
                        }
                        Text {
                            x: Theme.fpx(8)
                            text: User.session + "  ·  " + User.host
                            font.family: Theme.fontMono; font.pixelSize: Theme.fs(8); color: Theme.alpha(Theme.sgBandText, 0.5)
                            elide: Text.ElideRight
                            width: parent.width - Theme.fpx(16)
                        }
                    }
                }
            }

            Rectangle {
                anchors.left: rail.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Theme.sgPaper

                Item {
                    id: pageHead
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.fpx(22)
                    height: Theme.fpx(46)

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: -3
                        Text {
                            text: root.tabs[root.tab].label
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.fs(26)
                            font.letterSpacing: Theme.fpx(4)
                            font.bold: true
                            color: Theme.sgInk
                        }
                        Text {
                            text: I18n.t("set.page." + root.tabs[root.tab].key)
                            font.family: Theme.fontUI
                            font.pixelSize: Theme.fs(9)
                            font.letterSpacing: Theme.fpx(2)
                            color: Theme.sgMute
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: Theme.fpx(120)
                        height: Theme.fpx(24)
                        color: Theme.sgInk
                        Text {
                            anchors.centerIn: parent
                            text: "SECTION 0" + (root.tab + 1)
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fs(9)
                            color: Theme.sgAccent
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 2
                        color: Theme.sgInk
                    }
                }

                Flickable {
                    id: flick
                    interactive: !barEditor.dragging && !sidebarEditor.dragging
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: pageHead.bottom
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: Theme.fpx(22)
                    anchors.rightMargin: Theme.fpx(22)
                    anchors.topMargin: Theme.fpx(8)
                    clip: true
                    contentWidth: width
                    contentHeight: pageColumn.implicitHeight + Theme.fpx(24)
                    boundsBehavior: Flickable.StopAtBounds

                    Rectangle {
                        visible: flick.contentHeight > flick.height
                        x: flick.width - 4
                        y: flick.visibleArea.yPosition * flick.height
                        width: 3
                        height: Math.max(20, flick.visibleArea.heightRatio * flick.height)
                        color: Theme.sgInk
                        opacity: 0.45
                    }

                    Column {
                        id: pageColumn
                        width: flick.width
                        spacing: Theme.fpx(12)

                        // APPEARANCE
                        Column {
                            visible: root.tab === 0
                            width: parent.width
                            spacing: Theme.fpx(10)

                            SgSection { width: parent.width; number: "00"; title: "HOME"; note: I18n.t("set.sec.home") }

                            Row {
                                width: parent.width
                                height: Theme.fpx(96)
                                spacing: Theme.fpx(14)

                                Rectangle {
                                    width: Theme.fpx(84); height: Theme.fpx(84)
                                    color: Theme.sgInk
                                    border.width: 1
                                    border.color: Theme.lineColor(Theme.sgAccent)
                                    Image {
                                        anchors.fill: parent; anchors.margins: 2
                                        source: User.avatar
                                        cache: false
                                        fillMode: Image.PreserveAspectCrop
                                    }
                                }

                                Column {
                                    width: parent.width - Theme.fpx(108)
                                    spacing: Theme.fpx(2)
                                    Text {
                                        text: User.displayName
                                        font.family: Theme.fontDisplay
                                        font.pixelSize: Theme.fs(20)
                                        font.bold: true
                                        color: Theme.sgInk
                                    }
                                    Text {
                                        text: "USER  " + User.name + "   //   SESSION  " + User.session
                                        font.family: Theme.fontMono
                                        font.pixelSize: Theme.fs(8)
                                        color: Theme.sgInk
                                    }
                                    Text {
                                        text: "HOST  " + (User.host || "—") + "   ·   UPTIME  " + User.uptime
                                        font.family: Theme.fontMono
                                        font.pixelSize: Theme.fs(8)
                                        color: Theme.sgInk
                                    }
                                    Text {
                                        text: "OS  " + (User.osName || "—") + "   ·   KERNEL  " + (User.kernel || "—")
                                        font.family: Theme.fontMono
                                        font.pixelSize: Theme.fs(8)
                                        color: Theme.sgInk
                                    }
                                    Text {
                                        text: "CPU  " + (User.cpuModel || "—")
                                        font.family: Theme.fontMono
                                        font.pixelSize: Theme.fs(8)
                                        color: Theme.sgInk
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            SgRow {
                                width: parent.width
                                label: I18n.t("set.avatar")
                                desc: I18n.t("set.avatar.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(300)
                                    text: Settings.get("user.avatar", "")
                                    placeholder: "/home/you/Pictures/avatar.png"
                                    onAccepted: value => User.setAvatar(value)
                                }
                                SgButton {
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.fpx(310)
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: I18n.t("set.browse")
                                    onClicked: User.pickAvatar()
                                }
                            }

                            SgRow {
                                width: parent.width; last: true
                                label: I18n.t("set.quick")
                                desc: I18n.t("set.quick.desc")
                                Row {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.fpx(6)
                                    SgButton {
                                        text: Settings.get("theme.mode", "dark") === "light" ? "DARK" : "LIGHT"
                                        onClicked: Settings.applyPreset(Settings.get("theme.mode", "dark") === "light" ? "gfl" : "light")
                                    }
                                    SgButton {
                                        text: "WIDGETS"
                                        onClicked: {
                                            ShellState.close();
                                            ShellState.widgetsEditing = true;
                                        }
                                    }
                                    SgButton { text: "WALLPAPER"; onClicked: root.tab = 5 }
                                    SgButton { text: "DOCK"; onClicked: root.tab = 2 }
                                }
                            }

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
                                        { value: "arknights", label: "RHODES" },
                                        { value: "bf4", label: "BF4" },
                                        { value: "bf1", label: "BF1" },
                                        { value: "hoi4", label: "HOI4" },
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
                                    width: Theme.fpx(200); from: 0.8; to: 1.3; step: 0.05; decimals: 2
                                    value: Settings.get("theme.scale", 1.0)
                                    onMoved: v => Settings.set("theme.scale", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.fontScale"); desc: I18n.t("set.fontScale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0.8; to: 1.4; step: 0.05; decimals: 2
                                    value: Settings.get("theme.fontScale", 1.0)
                                    onMoved: v => Settings.set("theme.fontScale", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.panelOpacity"); desc: I18n.t("set.panelOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0.5; to: 1.0; step: 0.01; decimals: 2
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
                                width: parent.width; label: I18n.t("set.animSpeed"); desc: I18n.t("set.animSpeed.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0.5; to: 2.0; step: 0.05; decimals: 2
                                    value: Settings.get("theme.animSpeed", 1.0)
                                    onMoved: v => Settings.set("theme.animSpeed", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.lineOpacity"); desc: I18n.t("set.lineOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0.0; to: 1.0; step: 0.05; decimals: 2
                                    value: Settings.get("theme.lineOpacity", 1.0)
                                    onMoved: v => Settings.set("theme.lineOpacity", v)
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

                            SgRow {
                                width: parent.width
                                visible: Settings.get("theme.preset", "gfl") === "bf1"
                                label: I18n.t("set.bf1Radius")
                                desc: I18n.t("set.bf1Radius.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 28; step: 1; decimals: 0
                                    value: Settings.get("theme.bf1Radius", 12)
                                    onMoved: v => Settings.set("theme.bf1Radius", Math.round(v))
                                }
                            }

                            SgSection { width: parent.width; number: "03"; title: "SETTINGS SURFACE"; note: I18n.t("set.settingsSurface") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.settingsOpacity"); desc: I18n.t("set.settingsOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0.5; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("theme.settingsOpacity", 0.9)
                                    onMoved: v => Settings.set("theme.settingsOpacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.settingsGray"); desc: I18n.t("set.settingsGray.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("theme.settingsGray", 0.22)
                                    onMoved: v => Settings.set("theme.settingsGray", v)
                                }
                            }

                            SgSection { width: parent.width; number: "04"; title: "CUSTOM COLORS"; note: I18n.t("set.customColors") }
                            SgRow {
                                width: parent.width; label: "BG0"; desc: I18n.t("set.hex.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(180)
                                    text: Settings.get("theme.bg0", "#070708")
                                    onAccepted: value => root.setHex("bg0", value)
                                }
                            }
                            SgRow {
                                width: parent.width; label: "BG1"; desc: I18n.t("set.hex.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(180)
                                    text: Settings.get("theme.bg1", "#0d0d0f")
                                    onAccepted: value => root.setHex("bg1", value)
                                }
                            }
                            SgRow {
                                width: parent.width; label: "PANEL"; desc: I18n.t("set.hex.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(180)
                                    text: Settings.get("theme.panel", "#141416")
                                    onAccepted: value => root.setHex("panel", value)
                                }
                            }
                            SgRow {
                                width: parent.width; label: "TEXT"; desc: I18n.t("set.hex.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(180)
                                    text: Settings.get("theme.text", "#f2eee3")
                                    onAccepted: value => root.setHex("text", value)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: "ACCENT"; desc: I18n.t("set.hex.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(180)
                                    text: Settings.get("theme.accent", "#e8bd4f")
                                    onAccepted: value => root.setHex("accent", value)
                                }
                            }

                            SgButton {
                                text: I18n.t("set.resetTheme")
                                onClicked: Settings.applyPreset("gfl")
                            }

                            SgSection {
                                width: parent.width; number: "05"; title: "TYPOGRAPHY"
                                note: I18n.t("set.typography.note")
                            }
                            SgRow {
                                width: parent.width
                                label: I18n.t("set.fontRole")
                                desc: I18n.t("set.fontRole.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "ui", label: "UI" },
                                        { value: "display", label: "DISPLAY" },
                                        { value: "mono", label: "MONO" },
                                        { value: "label", label: "LABEL" }
                                    ]
                                    current: root.fontRole
                                    onSelected: v => root.fontRole = v
                                }
                            }
                            SgRow {
                                width: parent.width
                                label: I18n.t("set.fontCurrent")
                                desc: I18n.t("set.fontCurrent.desc")
                                Text {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: root.fontFor(root.fontRole)
                                    font.family: root.fontFor(root.fontRole)
                                    font.pixelSize: Theme.fs(11)
                                    color: Theme.sgInk
                                }
                            }
                            SgRow {
                                width: parent.width
                                label: I18n.t("set.fontSearch")
                                desc: I18n.t("set.fontSearch.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(300)
                                    text: root.fontQuery
                                    placeholder: I18n.t("set.fontSearch.placeholder")
                                    onTextChanged: root.fontQuery = text
                                }
                            }
                            Flickable {
                                id: fontScroller
                                width: parent.width
                                height: Theme.fpx(190)
                                clip: true
                                contentWidth: width
                                contentHeight: fontColumn.height
                                boundsBehavior: Flickable.StopAtBounds

                                WheelHandler {
                                    onWheel: wheel => {
                                        var dy = (wheel.angleDelta.y / 120) * Theme.fpx(64);
                                        fontScroller.contentY = Math.max(0, Math.min(fontScroller.contentHeight - fontScroller.height, fontScroller.contentY - dy));
                                        wheel.accepted = true;
                                    }
                                }

                                Column {
                                    id: fontColumn
                                    width: parent.width
                                    spacing: 1

                                    Repeater {
                                        model: root.fontChoices
                                        delegate: Item {
                                            required property string modelData
                                            width: fontColumn.width
                                            height: Theme.fpx(28)
                                            readonly property bool active: root.fontFor(root.fontRole) === modelData

                                            Rectangle {
                                                anchors.fill: parent
                                                color: active ? Theme.alpha(Theme.sgAccent, 0.22)
                                                    : (fontMouse.containsMouse ? Theme.alpha(Theme.sgInk, 0.06) : "transparent")
                                                border.width: 0
                                            }
                                            Text {
                                                anchors.left: parent.left
                                                anchors.leftMargin: Theme.fpx(8)
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData
                                                font.family: modelData
                                                font.pixelSize: Theme.fs(11)
                                                color: Theme.sgInk
                                            }
                                            MouseArea {
                                                id: fontMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.setFont(modelData)
                                            }
                                        }
                                    }
                                }
                            }
                            Row {
                                spacing: Theme.fpx(6)
                                SgButton {
                                    text: I18n.t("set.fontReset")
                                    onClicked: root.setFont("")
                                }
                                SgButton {
                                    text: I18n.t("set.fontRefresh")
                                    onClicked: Fonts.refresh()
                                }
                            }

                            SgSection {
                                width: parent.width; number: "06"; title: "POINTER"
                                note: I18n.t("set.pointer.note")
                            }
                            SgRow {
                                width: parent.width
                                label: I18n.t("set.cursorTheme")
                                desc: I18n.t("set.cursorTheme.desc")
                                Text {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: Cursors.current
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fs(10)
                                    color: Theme.sgInk
                                }
                            }
                            SgRow {
                                width: parent.width
                                label: I18n.t("set.cursorSize")
                                desc: I18n.t("set.cursorSize.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 16; to: 48; step: 1; decimals: 0
                                    value: Settings.get("cursor.size", 24)
                                    onMoved: v => Cursors.applySize(v)
                                }
                            }
                            SgRow {
                                width: parent.width
                                label: I18n.t("set.cursorSearch")
                                desc: I18n.t("set.cursorSearch.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(300)
                                    text: root.cursorQuery
                                    placeholder: I18n.t("set.cursorSearch.placeholder")
                                    onTextChanged: root.cursorQuery = text
                                }
                            }
                            Flickable {
                                id: cursorScroller
                                width: parent.width
                                height: Theme.fpx(150)
                                clip: true
                                contentWidth: width
                                contentHeight: cursorColumn.height
                                boundsBehavior: Flickable.StopAtBounds

                                WheelHandler {
                                    onWheel: wheel => {
                                        var dy = (wheel.angleDelta.y / 120) * Theme.fpx(60);
                                        cursorScroller.contentY = Math.max(0, Math.min(cursorScroller.contentHeight - cursorScroller.height, cursorScroller.contentY - dy));
                                        wheel.accepted = true;
                                    }
                                }

                                Column {
                                    id: cursorColumn
                                    width: parent.width
                                    spacing: 1

                                    Repeater {
                                        model: root.cursorChoices
                                        delegate: Item {
                                            required property string modelData
                                            width: cursorColumn.width
                                            height: Theme.fpx(28)
                                            readonly property bool active: Cursors.current === modelData

                                            Rectangle {
                                                anchors.fill: parent
                                                color: active ? Theme.alpha(Theme.sgAccent, 0.22)
                                                    : (cursorMouse.containsMouse ? Theme.alpha(Theme.sgInk, 0.06) : "transparent")
                                            }
                                            Text {
                                                anchors.left: parent.left
                                                anchors.leftMargin: Theme.fpx(8)
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData
                                                font.family: Theme.fontUI
                                                font.pixelSize: Theme.fs(10)
                                                color: Theme.sgInk
                                            }
                                            MouseArea {
                                                id: cursorMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: Cursors.apply(modelData)
                                            }
                                        }
                                    }
                                }
                            }
                            Row {
                                spacing: Theme.fpx(6)
                                SgButton {
                                    text: I18n.t("set.cursorRefresh")
                                    onClicked: Cursors.refresh()
                                }
                            }
                        }

                        // BAR
                        Column {
                            visible: root.tab === 1
                            width: parent.width
                            spacing: Theme.fpx(10)

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
                                    width: Theme.fpx(200); from: 30; to: 56; step: 1
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
                                    width: Theme.fpx(200); from: 0.3; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("bar.opacity", 0.94)
                                    onMoved: v => Settings.set("bar.opacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.grayscale"); desc: I18n.t("set.grayscale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("bar.gray", 0)
                                    onMoved: v => Settings.set("bar.gray", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.blur"); desc: I18n.t("set.blur.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("bar.blur", 0)
                                    onMoved: v => Settings.set("bar.blur", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.edgeWidth"); desc: I18n.t("set.edgeWidth.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 1; to: 4; step: 1; decimals: 0
                                    value: Settings.get("bar.edgeWidth", 1)
                                    onMoved: v => Settings.set("bar.edgeWidth", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.edgeOpacity"); desc: I18n.t("set.edgeOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("bar.edgeOpacity", 0.55)
                                    onMoved: v => Settings.set("bar.edgeOpacity", v)
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
                            BarLayoutEditor {
                                id: barEditor
                                width: parent.width
                                entries: root.barKinds
                            }
                            SgButton {
                                text: I18n.t("set.barResetLayout")
                                onClicked: {
                                    Settings.set("bar.left", ["launcher", "user", "workspaces", "title"]);
                                    Settings.set("bar.center", ["clock"]);
                                    Settings.set("bar.right", ["media", "wallpaper", "stats", "net", "bluetooth", "volume", "battery", "tray", "overview", "control", "power"]);
                                }
                            }
                        }

                        // DOCK
                        Column {
                            visible: root.tab === 2
                            width: parent.width
                            spacing: Theme.fpx(10)

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
                                    onToggled: {
                                        Settings.toggle("dock.avoid");
                                        if (!Settings.get("dock.avoid", true))
                                            Settings.set("dock.autoHide", false);
                                    }
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.autoHide")
                                desc: I18n.t("set.autoHide.desc")
                                enabled: Settings.get("dock.avoid", true)
                                opacity: enabled ? 1 : 0.45
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("dock.avoid", true) && Settings.get("dock.autoHide", false)
                                    onToggled: Settings.toggle("dock.autoHide")
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.position"); desc: I18n.t("set.position.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "bottom", label: "BOTTOM" },
                                        { value: "top", label: "TOP" },
                                        { value: "left", label: "LEFT" },
                                        { value: "right", label: "RIGHT" }
                                    ]
                                    current: Settings.get("dock.position", "bottom")
                                    onSelected: v => {
                                        Settings.set("dock.position", v);
                                        if (v === "left" || v === "right")
                                            Settings.set("dock.align", "center");
                                    }
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.dockAlign"); desc: I18n.t("set.dockAlign.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: {
                                        var p = Settings.get("dock.position", "bottom");
                                        if (p === "left" || p === "right")
                                            return [
                                                { value: "top", label: "TOP" },
                                                { value: "center", label: "CENTER" },
                                                { value: "bottom", label: "BOTTOM" }
                                            ];
                                        return [
                                            { value: "left", label: "LEFT" },
                                            { value: "center", label: "CENTER" },
                                            { value: "right", label: "RIGHT" }
                                        ];
                                    }
                                    current: Settings.get("dock.align", "center")
                                    onSelected: v => Settings.set("dock.align", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.deployMode"); desc: I18n.t("set.deployMode.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "launcher", label: "DEPLOY TERMINAL" },
                                        { value: "dashboard", label: "DASHBOARD" }
                                    ]
                                    current: Settings.get("dock.deployMode", "launcher")
                                    onSelected: v => Settings.set("dock.deployMode", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.maxItems"); desc: I18n.t("set.maxItems.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 5; to: 12; step: 1
                                    value: Settings.get("dock.maxItems", 12)
                                    onMoved: v => Settings.set("dock.maxItems", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true
                                label: I18n.t("set.addPinned")
                                desc: I18n.t("set.addPinned.desc") + "  ·  "
                                    + Settings.get("dock.pinned", []).length + " / "
                                    + Settings.get("dock.maxItems", 12)
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(220)
                                    placeholder: "app name"
                                    onAccepted: value => root.pinByName(value)
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "SIZE & LOOK"; note: I18n.t("set.sec.dockLook") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.iconSize"); desc: I18n.t("set.iconSize.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 32; to: 64; step: 1
                                    value: Settings.get("dock.iconSize", 44)
                                    onMoved: v => Settings.set("dock.iconSize", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.opacity"); desc: I18n.t("set.opacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0.3; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("dock.opacity", 0.94)
                                    onMoved: v => Settings.set("dock.opacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.grayscale"); desc: I18n.t("set.grayscale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("dock.gray", 0)
                                    onMoved: v => Settings.set("dock.gray", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.blur"); desc: I18n.t("set.blur.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("dock.blur", 0)
                                    onMoved: v => Settings.set("dock.blur", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.edgeWidth"); desc: I18n.t("set.edgeWidth.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 1; to: 4; step: 1; decimals: 0
                                    value: Settings.get("dock.edgeWidth", 1)
                                    onMoved: v => Settings.set("dock.edgeWidth", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.edgeOpacity"); desc: I18n.t("set.edgeOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("dock.edgeOpacity", 0.55)
                                    onMoved: v => Settings.set("dock.edgeOpacity", v)
                                }
                            }
                        }

                        // SIDEBARS
                        Column {
                            visible: root.tab === 3
                            width: parent.width
                            spacing: Theme.fpx(10)

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
                                width: parent.width; label: I18n.t("set.triggerWidth"); desc: I18n.t("set.triggerWidth.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 60; to: 420; step: 4
                                    value: Settings.get("sidebar.left.triggerWidth", 180)
                                    onMoved: v => Settings.set("sidebar.left.triggerWidth", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.triggerPos"); desc: I18n.t("set.triggerPos.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "top", label: "TOP" },
                                        { value: "bottom", label: "BOTTOM" }
                                    ]
                                    current: Settings.get("sidebar.left.triggerPosition", "top")
                                    onSelected: v => Settings.set("sidebar.left.triggerPosition", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.triggerHeight"); desc: I18n.t("set.triggerHeight.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 4; to: 48; step: 1
                                    value: Settings.get("sidebar.left.trigger", 12)
                                    onMoved: v => Settings.set("sidebar.left.trigger", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.width"); desc: I18n.t("set.width.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 280; to: 460; step: 2
                                    value: Settings.get("sidebar.left.width", 356)
                                    onMoved: v => Settings.set("sidebar.left.width", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.height"); desc: I18n.t("set.height.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0.4; to: 1.0; step: 0.01; decimals: 2
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
                                    width: Theme.fpx(200); from: 0.4; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("sidebar.left.opacity", 0.96)
                                    onMoved: v => Settings.set("sidebar.left.opacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.grayscale"); desc: I18n.t("set.grayscale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("sidebar.left.gray", 0)
                                    onMoved: v => Settings.set("sidebar.left.gray", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.blur"); desc: I18n.t("set.blur.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("sidebar.left.blur", 0)
                                    onMoved: v => Settings.set("sidebar.left.blur", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.edgeWidth"); desc: I18n.t("set.edgeWidth.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 1; to: 4; step: 1; decimals: 0
                                    value: Settings.get("sidebar.left.edgeWidth", 1)
                                    onMoved: v => Settings.set("sidebar.left.edgeWidth", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.edgeOpacity"); desc: I18n.t("set.edgeOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("sidebar.left.edgeOpacity", 0.55)
                                    onMoved: v => Settings.set("sidebar.left.edgeOpacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.delay"); desc: I18n.t("set.delay.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 200; to: 1400; step: 50
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
                                width: parent.width; label: I18n.t("set.triggerWidth"); desc: I18n.t("set.triggerWidth.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 60; to: 420; step: 4
                                    value: Settings.get("sidebar.right.triggerWidth", 180)
                                    onMoved: v => Settings.set("sidebar.right.triggerWidth", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.triggerPos"); desc: I18n.t("set.triggerPos.desc")
                                SgChoice {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    options: [
                                        { value: "top", label: "TOP" },
                                        { value: "bottom", label: "BOTTOM" }
                                    ]
                                    current: Settings.get("sidebar.right.triggerPosition", "top")
                                    onSelected: v => Settings.set("sidebar.right.triggerPosition", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.triggerHeight"); desc: I18n.t("set.triggerHeight.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 4; to: 48; step: 1
                                    value: Settings.get("sidebar.right.trigger", 12)
                                    onMoved: v => Settings.set("sidebar.right.trigger", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.width"); desc: I18n.t("set.width.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 280; to: 460; step: 2
                                    value: Settings.get("sidebar.right.width", 372)
                                    onMoved: v => Settings.set("sidebar.right.width", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.height"); desc: I18n.t("set.height.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0.4; to: 1.0; step: 0.01; decimals: 2
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
                                    width: Theme.fpx(200); from: 0.4; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("sidebar.right.opacity", 0.96)
                                    onMoved: v => Settings.set("sidebar.right.opacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.grayscale"); desc: I18n.t("set.grayscale.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("sidebar.right.gray", 0)
                                    onMoved: v => Settings.set("sidebar.right.gray", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.blur"); desc: I18n.t("set.blur.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("sidebar.right.blur", 0)
                                    onMoved: v => Settings.set("sidebar.right.blur", v)
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.edgeWidth"); desc: I18n.t("set.edgeWidth.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 1; to: 4; step: 1; decimals: 0
                                    value: Settings.get("sidebar.right.edgeWidth", 1)
                                    onMoved: v => Settings.set("sidebar.right.edgeWidth", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.edgeOpacity"); desc: I18n.t("set.edgeOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 1; step: 0.05; decimals: 2
                                    value: Settings.get("sidebar.right.edgeOpacity", 0.55)
                                    onMoved: v => Settings.set("sidebar.right.edgeOpacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.delay"); desc: I18n.t("set.delay.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 200; to: 1400; step: 50
                                    value: Settings.get("sidebar.right.delay", 650)
                                    onMoved: v => Settings.set("sidebar.right.delay", v)
                                }
                            }

                            SgSection { width: parent.width; number: "03"; title: "COMPONENTS"; note: I18n.t("set.sec.sidebarComponents") }
                            SidebarLayoutEditor {
                                id: sidebarEditor
                                width: parent.width
                                entries: root.sidebarKinds
                            }
                        }

                        // WIDGETS
                        Column {
                            visible: root.tab === 4
                            width: parent.width
                            spacing: Theme.fpx(10)

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
                                    controlWidth: Theme.fpx(80)
                                    SgToggle {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        checked: Settings.get("widgets." + widgetRow.wkey + ".enabled", false)
                                        onToggled: Settings.toggle("widgets." + widgetRow.wkey + ".enabled")
                                    }
                                }
                            }

                            SgRow {
                                width: parent.width; label: I18n.t("widget.opacity"); desc: I18n.t("set.widgetOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0.2; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("widgets.opacity", 1.0)
                                    onMoved: v => Settings.set("widgets.opacity", v)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("widget.lineOpacity"); desc: I18n.t("set.widgetLineOpacity.desc")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0.0; to: 1.0; step: 0.01; decimals: 2
                                    value: Settings.get("widgets.lineOpacity", 1.0)
                                    onMoved: v => Settings.set("widgets.lineOpacity", v)
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "WEATHER SOURCE"; note: I18n.t("set.sec.weather") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.city"); desc: I18n.t("set.city.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200)
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
                                    width: Theme.fpx(200); from: 16; to: 96; step: 8
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
                            spacing: Theme.fpx(10)

                            SgSection { width: parent.width; number: "01"; title: "BUILT-IN WALLPAPERS"; note: I18n.t("set.sec.builtin") }
                            Row {
                                width: parent.width
                                spacing: Theme.fpx(10)

                                Repeater {
                                    model: Wallpapers.builtin

                                    delegate: Item {
                                        required property var modelData
                                        required property int index
                                        readonly property bool active: Wallpapers.selected === (Wallpapers.folder + modelData.file)

                                        width: (parent.width - Theme.fpx(30)) / 4
                                        height: Theme.fpx(104)

                                        Rectangle {
                                            anchors.fill: parent
                                            color: active ? Theme.sgAccent : Theme.sgBand
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
                                            height: Theme.fpx(20)
                                            color: Theme.sgBand
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
                                            color: active ? Theme.sgAccent : Theme.sgBandText
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Wallpapers.choose(index)
                                        }
                                    }
                                }
                            }

                            SgSection { width: parent.width; number: "02"; title: "WALLPAPER DIRECTORY"; note: I18n.t("set.sec.wallpaperDir") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.wallpaperDir"); desc: I18n.t("set.wallpaperDir.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(320)
                                    text: Wallpapers.directory
                                    placeholder: "/home/you/Pictures/Wallpapers"
                                    onAccepted: value => Wallpapers.setDirectory(value)
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.wallpaperLibrary"); desc: I18n.t("set.wallpaperLibrary.desc")
                                Row {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.fpx(6)
                                    SgButton { text: I18n.t("set.browse"); onClicked: root.pickWallpaperDir() }
                                    SgButton { text: I18n.t("set.scan"); onClicked: Wallpapers.refresh() }
                                }
                            }
                            Grid {
                                width: parent.width
                                columns: 4
                                spacing: Theme.fpx(8)
                                visible: Wallpapers.user.length > 0

                                Repeater {
                                    model: Wallpapers.user
                                    delegate: Item {
                                        required property var modelData
                                        width: (parent.width - Theme.fpx(24)) / 4
                                        height: Theme.fpx(88)
                                        Rectangle {
                                            anchors.fill: parent
                                            color: Wallpapers.selected === modelData.path ? Theme.sgAccent : Theme.sgBand
                                        }
                                        Image {
                                            anchors.fill: parent; anchors.margins: 2
                                            source: modelData.path
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                        }
                                        Text {
                                            anchors.left: parent.left; anchors.leftMargin: 5
                                            anchors.bottom: parent.bottom; anchors.bottomMargin: 4
                                            width: parent.width - 10
                                            text: modelData.name
                                            font.family: Theme.fontMono
                                            font.pixelSize: Theme.fs(7)
                                            color: Wallpapers.selected === modelData.path ? Theme.sgAccent : Theme.sgBandText
                                            elide: Text.ElideRight
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Wallpapers.choosePath(modelData.path)
                                        }
                                    }
                                }
                            }
                            Text {
                                visible: Wallpapers.directory === "" || Wallpapers.user.length === 0
                                width: parent.width
                                text: Wallpapers.directory === "" ? I18n.t("set.wallpaperDir.empty") : I18n.t("set.wallpaperDir.none")
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fs(9)
                                color: Theme.sgInk
                                opacity: 0.55
                            }

                            SgSection { width: parent.width; number: "03"; title: "CUSTOM IMAGE"; note: I18n.t("set.sec.custom") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.path"); desc: I18n.t("set.path.desc")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(380)
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
                                    width: Theme.fpx(200); from: 0; to: 0.6; step: 0.01; decimals: 2
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
                            spacing: Theme.fpx(10)

                            SgSection { width: parent.width; number: "01"; title: "SESSION"; note: I18n.t("set.sec.session") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.lang"); desc: I18n.t("set.lang.desc")
                                controlWidth: Theme.fpx(330)
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
                                    { k: "OVERVIEW", v: "SUPER + ALT + TAB" },
                                    { k: "CONTROL", v: "SUPER + SHIFT + C" },
                                    { k: "POWER", v: "SUPER + SHIFT + Q" },
                                    { k: "WIDGETS", v: "SUPER + SHIFT + W" }
                                ]
                                delegate: SgRow {
                                    required property var modelData
                                    width: parent.width
                                    label: modelData.k
                                    desc: I18n.t("set.sec.hotkeys")
                                    controlWidth: Theme.fpx(210)
                                    Text {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.v
                                        font.family: Theme.fontMono
                                        font.pixelSize: Theme.fs(10)
                                        color: Theme.sgInk
                                    }
                                }
                            }

                            SgSection {
                                width: parent.width; number: "04"; title: "HYPRLAND"
                                note: I18n.t("set.compositor.hypr")
                                visible: Compositor.isHyprland
                            }
                            SgRow {
                                width: parent.width
                                visible: Compositor.isHyprland
                                label: I18n.t("set.gapsIn"); desc: I18n.t("set.compositor.live")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 40; step: 1; decimals: 0
                                    value: Settings.get("compositor.hypr.gapsIn", 5)
                                    onMoved: v => CompositorSettings.setHypr("gapsIn", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width
                                visible: Compositor.isHyprland
                                label: I18n.t("set.gapsOut"); desc: I18n.t("set.compositor.live")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 80; step: 1; decimals: 0
                                    value: Settings.get("compositor.hypr.gapsOut", 10)
                                    onMoved: v => CompositorSettings.setHypr("gapsOut", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width
                                visible: Compositor.isHyprland
                                label: I18n.t("set.borderWidth"); desc: I18n.t("set.compositor.live")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 10; step: 1; decimals: 0
                                    value: Settings.get("compositor.hypr.borderWidth", 1)
                                    onMoved: v => CompositorSettings.setHypr("borderWidth", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width
                                visible: Compositor.isHyprland
                                label: I18n.t("set.rounding"); desc: I18n.t("set.compositor.live")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 30; step: 1; decimals: 0
                                    value: Settings.get("compositor.hypr.rounding", 8)
                                    onMoved: v => CompositorSettings.setHypr("rounding", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width
                                visible: Compositor.isHyprland
                                label: I18n.t("set.activeColor"); desc: I18n.t("set.compositor.color")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(220)
                                    text: Settings.get("compositor.hypr.activeColor", "#e8bd4f")
                                    onAccepted: value => CompositorSettings.setHypr("activeColor", value)
                                }
                            }
                            SgRow {
                                width: parent.width
                                visible: Compositor.isHyprland
                                label: I18n.t("set.inactiveColor"); desc: I18n.t("set.compositor.color")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(220)
                                    text: Settings.get("compositor.hypr.inactiveColor", "#403a2e")
                                    onAccepted: value => CompositorSettings.setHypr("inactiveColor", value)
                                }
                            }
                            SgRow {
                                width: parent.width
                                visible: Compositor.isHyprland
                                label: I18n.t("set.blur"); desc: I18n.t("set.compositor.live")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("compositor.hypr.blur", true)
                                    onToggled: CompositorSettings.setHypr("blur", !Settings.get("compositor.hypr.blur", true))
                                }
                            }
                            SgRow {
                                width: parent.width; visible: Compositor.isHyprland; last: true
                                label: I18n.t("set.animations"); desc: I18n.t("set.compositor.live")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("compositor.hypr.animations", true)
                                    onToggled: CompositorSettings.setHypr("animations", !Settings.get("compositor.hypr.animations", true))
                                }
                            }

                            SgSection {
                                width: parent.width; number: "05"; title: "NIRI"
                                note: I18n.t("set.compositor.niri")
                                visible: Compositor.isNiri
                            }
                            SgRow {
                                width: parent.width; visible: Compositor.isNiri
                                label: I18n.t("set.gapsIn"); desc: I18n.t("set.compositor.niriLive")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 80; step: 1; decimals: 0
                                    value: Settings.get("compositor.niri.gaps", 16)
                                    onMoved: v => CompositorSettings.setNiri("gaps", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width; visible: Compositor.isNiri
                                label: I18n.t("set.borderWidth"); desc: I18n.t("set.compositor.niriLive")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 10; step: 1; decimals: 0
                                    value: Settings.get("compositor.niri.borderWidth", 2)
                                    onMoved: v => CompositorSettings.setNiri("borderWidth", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width; visible: Compositor.isNiri
                                label: I18n.t("set.focusWidth"); desc: I18n.t("set.compositor.niriLive")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 10; step: 1; decimals: 0
                                    value: Settings.get("compositor.niri.focusWidth", 4)
                                    onMoved: v => CompositorSettings.setNiri("focusWidth", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width; visible: Compositor.isNiri
                                label: I18n.t("set.cornerRadius"); desc: I18n.t("set.compositor.niriLive")
                                SgSlider {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(200); from: 0; to: 30; step: 1; decimals: 0
                                    value: Settings.get("compositor.niri.radius", 12)
                                    onMoved: v => CompositorSettings.setNiri("radius", Math.round(v))
                                }
                            }
                            SgRow {
                                width: parent.width; visible: Compositor.isNiri
                                label: I18n.t("set.activeColor"); desc: I18n.t("set.compositor.color")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(220)
                                    text: Settings.get("compositor.niri.activeColor", "#e8bd4f")
                                    onAccepted: value => CompositorSettings.setNiri("activeColor", value)
                                }
                            }
                            SgRow {
                                width: parent.width; visible: Compositor.isNiri
                                label: I18n.t("set.inactiveColor"); desc: I18n.t("set.compositor.color")
                                SgField {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.fpx(220)
                                    text: Settings.get("compositor.niri.inactiveColor", "#403a2e")
                                    onAccepted: value => CompositorSettings.setNiri("inactiveColor", value)
                                }
                            }
                            SgRow {
                                width: parent.width; visible: Compositor.isNiri
                                label: I18n.t("set.border"); desc: I18n.t("set.compositor.niriLive")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("compositor.niri.border", true)
                                    onToggled: CompositorSettings.setNiri("border", !Settings.get("compositor.niri.border", true))
                                }
                            }
                            SgRow {
                                width: parent.width; visible: Compositor.isNiri; last: true
                                label: I18n.t("set.focusRing"); desc: I18n.t("set.compositor.niriLive")
                                SgToggle {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    checked: Settings.get("compositor.niri.focus", false)
                                    onToggled: CompositorSettings.setNiri("focus", !Settings.get("compositor.niri.focus", false))
                                }
                            }
                        }

                        // ABOUT
                        Column {
                            visible: root.tab === 7
                            width: parent.width
                            spacing: Theme.fpx(10)

                            SgSection { width: parent.width; number: "01"; title: "ABOUT"; note: I18n.t("set.sec.about") }
                            SgRow {
                                width: parent.width; label: I18n.t("set.version"); desc: I18n.t("set.version.desc")
                                controlWidth: Theme.fpx(160)
                                Text {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: "v1.0  //  MIT"
                                    font.family: Theme.fontMono; font.pixelSize: Theme.fs(10); color: Theme.sgInk
                                }
                            }
                            SgRow {
                                width: parent.width; label: I18n.t("set.runtime"); desc: I18n.t("set.runtime.desc")
                                controlWidth: Theme.fpx(200)
                                Text {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: Compositor.backend.toUpperCase() + "  ·  " + User.session
                                    font.family: Theme.fontMono; font.pixelSize: Theme.fs(10); color: Theme.sgInk
                                }
                            }
                            SgRow {
                                width: parent.width; last: true; label: I18n.t("set.configFile"); desc: I18n.t("set.configFile.desc")
                                controlWidth: Theme.fpx(320)
                                Text {
                                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                                    text: Settings.path
                                    font.family: Theme.fontMono; font.pixelSize: Theme.fs(9); color: Theme.sgInk
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
                                color: Theme.sgInkSoft
                                lineHeight: 1.4
                            }

                            Row {
                                spacing: Theme.fpx(8)
                                SgButton { text: I18n.t("set.gfwiki"); onClicked: Qt.openUrlExternally("https://www.gfwiki.org/") }
                                SgButton { text: I18n.t("set.resetAll"); danger: true; onClicked: Settings.reset() }
                            }
                        }

                        Item { width: 1; height: Theme.fpx(20) }
                    }
                }
            }
        }
    }
}
