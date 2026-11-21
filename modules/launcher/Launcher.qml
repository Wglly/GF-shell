import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// Launcher — 部署终端。少前主菜单/编成式布局：
// 左侧斜切页签、中央单位卡（名条 + 图标）、右侧单位档案与红色战斗力。
PanelWindow {
    id: root

    readonly property bool open: ShellState.overlay === "launcher"
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
    WlrLayershell.namespace: "gf-shell-launcher"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    function focusedScreen() {
        var name = Compositor.outputName;
        var list = Quickshell.screens;
        for (var i = 0; i < list.length; i++) {
            if (list[i].name === name)
                return list[i];
        }
        return list.length > 0 ? list[0] : null;
    }
    screen: root.focusedScreen()

    // ---------------------------------------------------------------- 状态
    property string category: "ALL"
    property int selected: 0
    readonly property int columns: 5
    property string query: field.text

    readonly property var categories: [
        { key: "ALL", label: "ALL UNITS", zh: "全部" },
        { key: "RECENT", label: "RECENT", zh: "最近" },
        { key: "NET", label: "NETWORK", zh: "通讯" },
        { key: "DEV", label: "DEVELOP", zh: "开发" },
        { key: "MEDIA", label: "MEDIA", zh: "媒体" },
        { key: "OFFICE", label: "OFFICE", zh: "文书" },
        { key: "GAME", label: "COMBAT", zh: "作战" },
        { key: "SYS", label: "SYSTEM", zh: "系统" }
    ]

    function categoryOf(app) {
        var s = (app.name + " " + app.exec + " " + app.path).toLowerCase();
        if (/(steam|lutris|game|minecraft|wine|heroic|retroarch)/.test(s))
            return "GAME";
        if (/(code|kitty|terminal|foot|nvim|vim|git|qtcreator|python|postman|docker)/.test(s))
            return "DEV";
        if (/(firefox|chrom|browser|network|wifi|ftp|torrent|transmission)/.test(s))
            return "NET";
        if (/(mpv|vlc|music|spotify|player|image|photo|gimp|kdenlive|obs|audacity|easyeffects)/.test(s))
            return "MEDIA";
        if (/(libreoffice|writer|calc|impress|pdf|office|onlyoffice|zettlr|obsidian)/.test(s))
            return "OFFICE";
        return "SYS";
    }

    function hashOf(name) {
        var h = 0;
        var s = "" + name;
        for (var i = 0; i < s.length; i++)
            h = (h * 31 + s.charCodeAt(i)) % 9973;
        return h;
    }

    function combatPower(app) {
        if (!app)
            return 0;
        return 2800 + (root.hashOf(app.name) * 7) % 5200;
    }

    function combatText(app) {
        var v = root.combatPower(app);
        return ("" + v).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    readonly property var filtered: {
        var q = ("" + root.query).trim().toLowerCase();
        var cat = root.category;
        var recent = Settings.get("launcher.recent", []);
        var all = Apps.apps;
        var out = [];
        for (var i = 0; i < all.length; i++) {
            var a = all[i];
            if (cat === "RECENT" && recent.indexOf(a.name) < 0)
                continue;
            if (cat !== "ALL" && cat !== "RECENT" && root.categoryOf(a) !== cat)
                continue;
            if (q !== "" && (a.name + " " + a.exec + " " + a.path).toLowerCase().indexOf(q) < 0)
                continue;
            out.push(a);
        }
        if (cat === "RECENT")
            out.sort(function (x, y) { return recent.indexOf(x.name) - recent.indexOf(y.name); });
        return out;
    }

    readonly property var shownApps: root.filtered
    readonly property var currentApp: root.shownApps.length > 0
        ? root.shownApps[Math.min(root.selected, root.shownApps.length - 1)] : null

    function clampSelection() {
        var n = root.shownApps.length;
        if (n === 0) {
            root.selected = 0;
            return;
        }
        root.selected = Math.max(0, Math.min(n - 1, root.selected));
    }

    onShownAppsChanged: root.clampSelection()
    onSelectedChanged: root.ensureVisible()
    onQueryChanged: root.selected = 0

    function ensureVisible() {
        if (!scroller)
            return;
        var row = Math.floor(root.selected / root.columns);
        var top = row * (Theme.px(96) + Theme.px(8));
        var bottom = top + Theme.px(96);
        if (top < scroller.contentY)
            scroller.contentY = top;
        else if (bottom > scroller.contentY + scroller.height)
            scroller.contentY = bottom - scroller.height;
    }

    function move(delta) {
        var n = root.shownApps.length;
        if (n === 0)
            return;
        var next = root.selected + delta;
        while (next < 0)
            next += n;
        while (next >= n)
            next -= n;
        root.selected = next;
    }

    function launchSelected() {
        if (root.currentApp)
            root.launch(root.currentApp);
    }

    function launch(app) {
        if (!app)
            return;
        var recent = Settings.get("launcher.recent", []).slice();
        var idx = recent.indexOf(app.name);
        if (idx >= 0)
            recent.splice(idx, 1);
        recent.unshift(app.name);
        Settings.set("launcher.recent", recent.slice(0, 12));
        Apps.launch(app);
        ShellState.close();
    }

    // ---------------------------------------------------------------- 背景
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.bg0, 0.62)
        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.close()
        }
    }

    ThemeSignature {
        anchors.fill: parent
        z: 0
        opacity: 0.55
    }

    // 左侧斜切金带
    Rectangle {
        x: -parent.width * 0.08
        y: 0
        width: parent.width * 0.28
        height: parent.height
        rotation: 9
        transformOrigin: Item.Center
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.alpha(Theme.accent, 0.028) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Image {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: Theme.px(360)
        height: Theme.px(360)
        source: Qt.resolvedUrl("../../assets/textures/halftone.png")
        fillMode: Image.Tile
        opacity: 0.5
    }

    // 右下巨大徽章水印
    Image {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: -Theme.px(40)
        width: Theme.px(420)
        height: Theme.px(420)
        source: Qt.resolvedUrl("../../assets/icons/emblem-accent.png")
        opacity: 0.05
        fillMode: Image.PreserveAspectFit
    }

    // ---------------------------------------------------------------- 面板
    GfFrame {
        id: panel
        anchors.centerIn: parent
        width: Math.min(Theme.px(1240), parent.width - Theme.px(96))
        height: Math.min(Theme.px(726), parent.height - Theme.px(84))
        fill: Theme.alpha(Theme.bg1, 0.96)
        borderColor: Theme.alpha(Theme.accent, 0.6)
        chamfer: Theme.px(10)
        padding: 0
        innerLine: true

        // 顶部金色饰条
        Rectangle {
            x: Theme.px(18)
            y: 0
            width: Theme.px(180)
            height: 2
            color: Theme.accent
        }

        Column {
            anchors.fill: parent
            anchors.margins: Theme.px(22)

            // ------------------------------------------------------ header
            Item {
                width: parent.width
                height: Theme.px(62)

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.px(14)

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: Qt.resolvedUrl("../../assets/icons/emblem-accent.png")
                        width: Theme.px(36)
                        height: Theme.px(36)
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: -Theme.px(4)

                        GfText {
                            text: Theme.arknights ? "RHODES DEPLOYMENT"
                                : (Theme.bf4 ? "DEPLOYMENT OVERVIEW"
                                : (Theme.bf1 ? "FIELD DEPLOYMENT" : "DEPLOYMENT"))
                            role: "display"
                            size: Theme.sizeDisplay
                            tracking: 7
                            bold: true
                            color: Theme.text
                        }

                        Row {
                            spacing: Theme.px(10)

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: Theme.px(26)
                                height: 1
                                color: Theme.accent
                            }
                            GfText {
                                text: I18n.t("launcher.subtitle")
                                role: "ui"
                                size: Theme.sizeSmall
                                tone: "faint"
                                tracking: 3
                            }
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 1
                                height: Theme.px(10)
                                color: Theme.alpha(Theme.accent, 0.4)
                            }
                            GfText {
                                text: "GRIFFIN & KRYUGER  /  S09 COMMAND"
                                role: "mono"
                                size: Theme.sizeTiny - 1
                                color: Theme.alpha(Theme.accent, 0.75)
                                tracking: 1
                            }
                        }
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.px(12)

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: -2
                        GfText {
                            text: Theme.hoi4 ? "HEAD OF STATE"
                                : (Theme.battle ? "COMMANDER" : (Theme.arknights ? "DOCTOR" : "OPERATOR"))
                            role: "mono"
                            size: Theme.sizeTiny - 2
                            tone: "faint"
                            tracking: 1.4
                            horizontalAlignment: Text.AlignRight
                        }
                        GfText {
                            text: (Compositor.backend === "hyprland" ? "HYPRLAND" : (Compositor.backend === "niri" ? "NIRI" : "UNKNOWN")) + " SESSION"
                            role: "mono"
                            size: Theme.sizeTiny - 1
                            color: Theme.accent2
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Rectangle {
                        width: 1
                        height: Theme.px(30)
                        color: Theme.alpha(Theme.accent, 0.35)
                    }

                    Rectangle {
                        width: Theme.px(66)
                        height: Theme.px(22)
                        color: "transparent"
                        border.width: 1
                        border.color: Theme.lineColor(Theme.alpha(Theme.accent, 0.6))

                        GfText {
                            anchors.centerIn: parent
                            text: Util.opNumber("deployment")
                            role: "mono"
                            size: Theme.sizeTiny - 1
                            color: Theme.accent
                        }
                    }

                    GfIconButton {
                        icon: "close"
                        glyphSize: Theme.px(16)
                        buttonSize: Theme.px(24)
                        danger: true
                        onClicked: ShellState.close()
                    }
                }
            }

            GfDivider {
                width: parent.width
                color: Theme.alpha(Theme.accent, 0.45)
            }

            // ------------------------------------------------------- search
            Item {
                width: parent.width
                height: Theme.px(54)

                GfTextField {
                    id: field
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - Theme.px(230)
                    height: Theme.px(36)
                    placeholder: I18n.t("launcher.placeholder")

                    onAccepted: root.launchSelected()
                    onDismissed: ShellState.close()
                    onCleared: root.selected = 0
                    onNavigate: (dx, dy) => {
                        if (dy !== 0)
                            root.move(dy * root.columns);
                        else
                            root.move(dx);
                    }

                    Component.onCompleted: if (root.open) forceFocus()
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.px(6)

                    GfKeyCap { label: "ENTER" }
                    GfText { text: I18n.t("launcher.deploy"); role: "mono"; size: Theme.sizeTiny - 1; color: Theme.alpha(Theme.accent, 0.8) }
                    GfKeyCap { label: "ESC" }
                    GfText { text: I18n.t("launcher.abort"); role: "mono"; size: Theme.sizeTiny - 1; tone: "faint" }
                }
            }

            // --------------------------------------------------------- body
            Item {
                width: parent.width
                height: parent.height - Theme.px(62) - Theme.px(54) - Theme.px(34) - Theme.px(8)

                // 左：分类（斜切大页签）
                Column {
                    id: rail
                    width: Theme.px(196)
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    spacing: Theme.px(2)

                    GfText {
                        text: "UNIT CLASS"
                        role: "mono"
                        size: Theme.sizeTiny - 1
                        tone: "faint"
                        tracking: 2
                        height: Theme.px(20)
                    }

                    component RailTab: Item {
                        id: rt
                        property string label: ""
                        property string itemKey: ""
                        property string number: ""
                        property bool checked: false
                        signal clicked()

                        width: rail.width
                        height: Theme.px(38)

                        Rectangle {
                            visible: Theme.bf1
                            anchors.fill: parent
                            radius: Theme.px(Theme.bf1Radius)
                            color: rt.checked ? Theme.accent
                                : (rt.containsMouse ? Theme.alpha(Theme.accent, 0.14) : Theme.alpha(Theme.bg0, 0.55))
                            border.width: 1
                            border.color: Theme.lineColor(rt.checked ? Theme.accentHi : Theme.alpha(Theme.accent, rt.containsMouse ? 0.8 : 0.3))
                        }

                        Shape {
                            visible: !Theme.bf1
                            anchors.fill: parent
                            preferredRendererType: Shape.CurveRenderer
                            ShapePath {
                                strokeWidth: 1
                                strokeColor: Theme.lineColor(rt.checked ? Theme.accentHi : Theme.alpha(Theme.accent, rt.containsMouse ? 0.8 : 0.3))
                                fillColor: rt.checked ? Theme.accent
                                    : (rt.containsMouse ? Theme.alpha(Theme.accent, 0.14) : Theme.alpha(Theme.bg0, 0.55))
                                PathPolyline {
                                    path: [
                                        Qt.point(0, 0),
                                        Qt.point(rt.width - Theme.px(12), 0),
                                        Qt.point(rt.width, rt.height),
                                        Qt.point(Theme.px(12), rt.height)
                                    ]
                                }
                            }
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.px(20)
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.px(9)

                            GfText {
                                text: rt.number
                                role: "mono"
                                size: Theme.sizeTiny - 1
                                color: rt.checked ? Theme.alpha(Theme.ink, 0.7) : Theme.textGhost
                            }
                            GfText {
                                text: rt.label
                                role: "display"
                                size: Theme.sizeMedium
                                tracking: 2
                                bold: true
                                color: rt.checked ? Theme.ink : Theme.textDim
                            }
                            GfText {
                                visible: I18n.locale !== "en"
                                text: I18n.t("launcher." + rt.itemKey)
                                role: "ui"
                                size: Theme.sizeTiny - 1
                                color: rt.checked ? Theme.alpha(Theme.ink, 0.55) : Theme.textFaint
                            }
                        }

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: rt.clicked()
                        }
                        readonly property bool containsMouse: hoverArea.containsMouse
                    }

                    Repeater {
                        model: root.categories

                        delegate: RailTab {
                            required property var modelData
                            required property int index

                            label: modelData.label
                            itemKey: modelData.key.toLowerCase()
                            number: "0" + (index + 1)
                            checked: root.category === modelData.key
                            onClicked: {
                                root.category = modelData.key;
                                root.selected = 0;
                            }
                        }
                    }

                    Item { width: 1; height: Theme.px(10) }

                    GfDivider {
                        width: parent.width
                        color: Theme.alpha(Theme.accent, 0.3)
                    }

                    Item { width: 1; height: Theme.px(8) }

                    Column {
                        width: parent.width
                        spacing: Theme.px(4)

                        GfText {
                            text: I18n.t("launcher.linkStable")
                            role: "mono"
                            size: Theme.sizeTiny - 1
                            color: Theme.alpha(Theme.accent2, 0.85)
                            tracking: 1
                        }
                        GfText {
                            text: I18n.t("launcher.registry") + "  " + Util.pad3(Apps.apps.length)
                            role: "mono"
                            size: Theme.sizeTiny - 1
                            tone: "faint"
                        }
                        GfText {
                            text: "SECTOR 09 // HQ"
                            role: "mono"
                            size: Theme.sizeTiny - 2
                            tone: "faint"
                        }
                    }
                }

                // 中：单位卡网格
                Item {
                    id: gridHost
                    anchors.left: rail.right
                    anchors.leftMargin: Theme.px(18)
                    anchors.right: detail.left
                    anchors.rightMargin: Theme.px(18)
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    GfText {
                        id: listHint
                        text: root.filtered.length + " " + I18n.t("launcher.unitsMatch")
                            + (root.query !== "" ? "   /   " + I18n.t("launcher.query") + ": " + root.query.toUpperCase() : "")
                        role: "mono"
                        size: Theme.sizeTiny - 1
                        color: Theme.alpha(Theme.accent, 0.8)
                        tracking: 1.2
                        height: Theme.px(22)
                    }

                    Flickable {
                        id: scroller
                        anchors.top: listHint.bottom
                        anchors.topMargin: Theme.px(6)
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        clip: true
                        contentWidth: width
                        contentHeight: Math.max(grid.implicitHeight, height + 1)
                        boundsBehavior: Flickable.StopAtBounds

                        WheelHandler {
                            onWheel: wheel => {
                                var dy = (wheel.angleDelta.y / 120) * Theme.px(78);
                                scroller.contentY = Math.max(0, Math.min(scroller.contentHeight - scroller.height, scroller.contentY - dy));
                                wheel.accepted = true;
                            }
                        }

                        Grid {
                            id: grid
                            width: scroller.width
                            columns: root.columns
                            rowSpacing: Theme.px(8)
                            columnSpacing: Theme.px(8)

                            Repeater {
                            model: root.shownApps

                            delegate: Item {
                                id: cardHost
                                required property var modelData
                                required property int index

                                readonly property bool active: root.selected === index

                                width: Math.floor((grid.width - (root.columns - 1) * grid.columnSpacing) / root.columns)
                                height: Theme.px(96)

                                GfFrame {
                                id: card
                                anchors.fill: parent
                                chamfer: Theme.px(4)
                                cutTopLeft: false
                                cutTopRight: true
                                cutBottomLeft: true
                                cutBottomRight: false
                                innerLine: false
                                padding: 0
                                strokeWidth: cardHost.active ? 2 : 1
                                fill: cardHost.active ? Theme.alpha(Theme.accent, 0.12) : Theme.alpha(Theme.panel, 0.92)
                                borderColor: cardHost.active ? Theme.accentHi : Theme.alpha(Theme.accent, cardMouse.containsMouse ? 0.75 : 0.28)

                                // 名条
                                Rectangle {
                                    x: 0
                                    y: 0
                                    width: parent.width
                                    height: Theme.px(19)
                                    color: Theme.alpha(Theme.bg0, 0.9)

                                    Rectangle {
                                        x: 0
                                        y: 0
                                        width: Theme.px(17)
                                        height: parent.height
                                        color: cardHost.active ? Theme.accent : Theme.alpha(Theme.accent, 0.75)

                                        GfText {
                                            anchors.centerIn: parent
                                            text: ("0" + (cardHost.index + 1)).slice(-2)
                                            role: "mono"
                                            size: Theme.sizeTiny - 3
                                            color: Theme.ink
                                        }
                                    }

                                    GfText {
                                        anchors.left: parent.left
                                        anchors.leftMargin: Theme.px(22)
                                        anchors.right: parent.right
                                        anchors.rightMargin: Theme.px(4)
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: cardHost.modelData.name
                                        role: "ui"
                                        size: Theme.sizeTiny
                                        color: Theme.text
                                        elide: Text.ElideRight
                                    }
                                }

                                Image {
                                    id: appIcon
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: Theme.px(28)
                                    width: Theme.px(32)
                                    height: Theme.px(32)
                                    source: cardHost.modelData.icon !== "" ? Quickshell.iconPath(cardHost.modelData.icon, "") : ""
                                    sourceSize.width: Theme.px(64)
                                    sourceSize.height: Theme.px(64)
                                    smooth: true
                                    visible: status === Image.Ready
                                }

                                GfIcon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: Theme.px(31)
                                    visible: appIcon.status !== Image.Ready
                                    name: "apps"
                                    iconSize: Theme.px(26)
                                    color: cardHost.active ? Theme.accent : Theme.textFaint
                                }

                                GfText {
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.px(6)
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: Theme.px(4)
                                    text: root.categoryOf(cardHost.modelData)
                                    role: "mono"
                                    size: Theme.sizeTiny - 3
                                    color: cardHost.active ? Theme.alpha(Theme.accent, 0.9) : Theme.textFaint
                                }

                                MouseArea {
                                    id: cardMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.selected = cardHost.index;
                                        root.launch(cardHost.modelData);
                                    }
                                }
                                }
                            }
                        }
                    }

                    Column {
                        visible: root.shownApps.length === 0
                        anchors.centerIn: parent
                        spacing: Theme.px(10)

                        GfIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "radar"
                            iconSize: Theme.px(36)
                            color: Theme.alpha(Theme.accent, 0.4)
                        }
                        GfText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: I18n.t("launcher.noResults")
                            role: "display"
                            size: Theme.sizeMedium
                            tracking: 2
                            tone: "faint"
                        }
                        GfText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: I18n.t("launcher.adjust")
                            role: "mono"
                            size: Theme.sizeTiny - 1
                            tone: "faint"
                        }
                    }
                    }
                }

                // 右：单位档案
                GfFrame {
                    id: detail
                    width: Theme.px(302)
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    padding: Theme.px(14)
                    fill: Theme.alpha(Theme.bg0, 0.7)
                    borderColor: Theme.alpha(Theme.accent, 0.5)
                    chamfer: Theme.px(6)
                    cutTopLeft: true
                    cutBottomRight: true
                    cutTopRight: false
                    cutBottomLeft: false

                    Column {
                        id: detailColumn
                        width: parent.width
                        spacing: Theme.px(8)

                        Row {
                            width: parent.width
                            GfText {
                                text: I18n.t("launcher.dossier")
                                role: "mono"
                                size: Theme.sizeTiny
                                color: Theme.accent
                                tracking: 2
                            }
                            Item { width: parent.width - 110; height: 1 }
                            GfText {
                                text: "S09"
                                role: "mono"
                                size: Theme.sizeTiny - 1
                                tone: "faint"
                            }
                        }

                        // 立绘框
                        Item {
                            width: parent.width
                            height: Theme.px(124)

                            Rectangle {
                                anchors.fill: parent
                                color: Theme.alpha(Theme.panel, 0.9)
                                border.width: 1
                                border.color: Theme.lineColor(Theme.alpha(Theme.accent, 0.55))
                            }

                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                source: Qt.resolvedUrl("../../assets/textures/hatch.png")
                                fillMode: Image.Tile
                                opacity: 0.55
                            }

                            // 斜切金角
                            Rectangle {
                                x: 0
                                y: 0
                                width: Theme.px(26)
                                height: Theme.px(3)
                                color: Theme.accent
                            }
                            Rectangle {
                                x: 0
                                y: 0
                                width: Theme.px(3)
                                height: Theme.px(26)
                                color: Theme.accent
                            }

                            Image {
                                id: detailIcon
                                anchors.centerIn: parent
                                width: Theme.px(58)
                                height: Theme.px(58)
                                source: root.currentApp && root.currentApp.icon !== ""
                                    ? Quickshell.iconPath(root.currentApp.icon, "") : ""
                                sourceSize.width: Theme.px(116)
                                sourceSize.height: Theme.px(116)
                                smooth: true
                                visible: status === Image.Ready
                            }

                            GfIcon {
                                anchors.centerIn: parent
                                visible: detailIcon.status !== Image.Ready
                                name: "apps"
                                iconSize: Theme.px(44)
                                color: Theme.textFaint
                            }

                            GfText {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: Theme.px(5)
                                text: root.currentApp ? root.categoryOf(root.currentApp) : "—"
                                role: "mono"
                                size: Theme.sizeTiny - 2
                                color: Theme.accent
                            }
                        }

                        GfText {
                            width: parent.width
                            text: root.currentApp ? root.currentApp.name : "—"
                            role: "display"
                            size: Theme.sizeLarge + 1
                            tracking: 1.4
                            bold: true
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        GfDivider {
                            width: parent.width
                            color: Theme.alpha(Theme.accent, 0.35)
                        }

                        // 战斗力
                        Row {
                            width: parent.width
                            spacing: Theme.px(10)

                            Column {
                                spacing: -Theme.px(2)
                                GfText {
                                    text: I18n.t("launcher.combatPower")
                                    role: "mono"
                                    size: Theme.sizeTiny - 2
                                    color: Theme.alpha(Theme.red, 0.85)
                                    tracking: 1.4
                                }
                                GfText {
                                    text: root.combatText(root.currentApp)
                                    role: "display"
                                    size: Theme.sizeTitle
                                    tracking: 1
                                    bold: true
                                    color: Theme.red
                                }
                            }

                            Column {
                                anchors.bottom: parent.bottom
                                spacing: 2
                                Row {
                                    spacing: 2
                                    Repeater {
                                        model: 5
                                        Rectangle {
                                            width: Theme.px(9)
                                            height: Theme.px(5)
                                            color: index < 4 ? Theme.alpha(Theme.accent, 0.85) : Theme.alpha(Theme.text, 0.15)
                                        }
                                    }
                                }
                                GfText {
                                    text: "ARMS / ARMOR"
                                    role: "mono"
                                    size: Theme.sizeTiny - 3
                                    tone: "faint"
                                }
                            }
                        }

                        // 属性行
                        Column {
                            width: parent.width
                            spacing: Theme.px(4)

                            Repeater {
                                model: [
                                    { k: "CLASS", v: root.currentApp ? root.categoryOf(root.currentApp) : "—" },
                                    { k: "STATUS", v: "READY" },
                                    { k: "SOURCE", v: root.currentApp ? Util.basename(root.currentApp.path) : "—" }
                                ]

                                delegate: Row {
                                    required property var modelData
                                    width: parent.width
                                    height: Theme.px(16)

                                    GfText {
                                        text: modelData.k
                                        role: "mono"
                                        size: Theme.sizeTiny - 1
                                        color: Theme.alpha(Theme.accent, 0.7)
                                        width: Theme.px(56)
                                    }
                                    GfText {
                                        width: parent.width - Theme.px(56)
                                        text: modelData.v
                                        role: "mono"
                                        size: Theme.sizeTiny - 1
                                        color: Theme.textDim
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }

                        GfText {
                            width: parent.width
                            text: root.currentApp ? root.currentApp.exec : ""
                            role: "mono"
                            size: Theme.sizeTiny - 2
                            tone: "faint"
                            wrapMode: Text.WrapAnywhere
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        // 特性
                        GfText {
                            text: I18n.t("launcher.traits")
                            role: "mono"
                            size: Theme.sizeTiny - 1
                            color: Theme.alpha(Theme.accent, 0.7)
                            tracking: 1.4
                        }

                        Repeater {
                            model: {
                                var h = root.hashOf(root.currentApp ? root.currentApp.name : "");
                                return [
                                    { label: "COMPAT", value: 0.55 + (h % 40) / 100 },
                                    { label: "STABILITY", value: 0.6 + (h % 30) / 100 },
                                    { label: "RESPONSE", value: 0.5 + (h % 45) / 100 }
                                ];
                            }

                            delegate: Item {
                                required property var modelData
                                width: detailColumn.width
                                height: Theme.px(14)

                                GfText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.label
                                    role: "mono"
                                    size: Theme.sizeTiny - 2
                                    color: Theme.textFaint
                                    width: Theme.px(64)
                                }
                                GfMeter {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: Theme.px(66)
                                    width: parent.width - Theme.px(112)
                                    height: Theme.px(4)
                                    value: modelData.value
                                    segments: 12
                                    segmentGap: 1
                                    color: Theme.accent
                                }
                                GfText {
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.px(2)
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: Math.round(modelData.value * 100)
                                    role: "mono"
                                    size: Theme.sizeTiny - 3
                                    tone: "faint"
                                }
                            }
                        }

                        Item { width: 1; height: Theme.px(1) }

                        GfButton {
                            width: parent.width
                            height: Theme.px(34)
                            text: I18n.t("launcher.deploy")
                            icon: "rocket_launch"
                            checked: true
                            onClicked: root.launch(root.currentApp)
                        }

                        Item { width: 1; height: Theme.px(2) }

                        GfText {
                            width: parent.width
                            text: I18n.t("launcher.clearance")
                            role: "mono"
                            size: Theme.sizeTiny - 3
                            color: Theme.alpha(Theme.accent, 0.45)
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            // ------------------------------------------------------- footer
            Item {
                width: parent.width
                height: Theme.px(34)

                GfDivider {
                    anchors.top: parent.top
                    width: parent.width
                    color: Theme.alpha(Theme.accent, 0.3)
                }

                Row {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    spacing: Theme.px(8)

                    GfKeyCap { label: "↑↓←→" }
                    GfText { text: I18n.t("launcher.navigate"); role: "mono"; size: Theme.sizeTiny - 1; tone: "faint" }
                    GfKeyCap { label: "TAB" }
                    GfText { text: I18n.t("launcher.next"); role: "mono"; size: Theme.sizeTiny - 1; tone: "faint" }
                    GfKeyCap { label: "ENTER" }
                    GfText { text: I18n.t("launcher.deploy"); role: "mono"; size: Theme.sizeTiny - 1; tone: "faint" }
                }

                GfText {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    text: root.filtered.length + " / " + Apps.apps.length + " " + I18n.t("launcher.registered") + "   ·   SECTOR 09"
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    tone: "faint"
                }
            }
        }
    }

    onOpenChanged: {
        if (root.open) {
            root.selected = 0;
            field.text = "";
            focusTimer.restart();
        }
    }

    Timer {
        id: focusTimer
        interval: 60
        onTriggered: field.forceFocus()
    }
}
