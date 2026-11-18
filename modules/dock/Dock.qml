import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// Dock — 屏幕底部的梯隊条：固定的单位 + 正在运行的单位。
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property bool enabled: Settings.get("dock.enabled", true)
    readonly property bool autoHide: Settings.get("dock.autoHide", false)
    readonly property bool avoid: Settings.get("dock.avoid", true)
    readonly property int iconSize: Math.round(Settings.get("dock.iconSize", 42) * Theme.uiScale)
    readonly property int maxItems: Settings.get("dock.maxItems", 9)
    readonly property bool atTop: Settings.get("dock.position", "bottom") === "top"
    readonly property bool hasWindows: Compositor.windows.length > 0
    // `avoid` 是总开关：关闭避让后 Dock 始终完整显示（autoHide 不再单独隐藏）
    readonly property bool shouldHide: root.avoid && (root.autoHide || root.hasWindows)
    property bool hovered: false
    readonly property bool revealed: !root.shouldHide || root.hovered || root.hoverLatch
    // 收起时露出的热区高度（用户可调）
    readonly property int trigger: Theme.px(Settings.get("dock.trigger", 24))
    readonly property bool barOnSameEdge: Settings.get("bar.visible", true)
        && ((root.atTop && Settings.get("bar.position", "top") === "top")
            || (!root.atTop && Settings.get("bar.position", "top") === "bottom"))
    readonly property int barInset: root.barOnSameEdge ? Theme.px(Settings.get("bar.thickness", 38)) : 0
    property bool hoverLatch: false

    visible: root.enabled && entries.length > 0
    color: "transparent"
    anchors.bottom: !root.atTop
    anchors.top: root.atTop
    anchors.left: true
    anchors.right: true
    // 负 margin 让热区真正贴到屏幕边缘（状态栏上）；内容再用 barInset 让出状态栏
    margins.top: root.atTop ? -root.barInset : 0
    margins.bottom: !root.atTop ? -root.barInset : 0
    implicitHeight: root.revealed ? root.barInset + Theme.px(76) : root.trigger
    exclusionMode: ExclusionMode.Normal
    // 收起时不占位；展开时只保留 Dock 本身的高度
    exclusiveZone: root.visible && root.revealed ? Theme.px(76) : 0
    Behavior on implicitHeight {
        enabled: Theme.animations
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "gf-shell-dock"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // ---------------------------------------------------------------- 应用列表
    readonly property var pinnedIds: Settings.get("dock.pinned", [])
    property string menuKey: ""
    readonly property var menuTarget: root.menuKey === "" ? null : root.entryByKey(root.menuKey)

    function appById(id) {
        var want = ("" + id).toLowerCase();
        for (var i = 0; i < Apps.apps.length; i++) {
            var base = Apps.apps[i].path.split("/").pop().toLowerCase();
            if (base === want)
                return Apps.apps[i];
        }
        return null;
    }

    function appDesktopId(app) {
        return app ? app.path.split("/").pop() : "";
    }

    function windowApp(w) {
        return w && w.appId ? Apps.findByClass(w.appId) : null;
    }

    function classBase(cls) {
        return ("" + cls).toLowerCase().replace(/\s+/g, "");
    }

    function windowDesktopId(w) {
        var app = root.windowApp(w);
        return app ? root.appDesktopId(app) : "";
    }

    function windowsForPinned(app, id) {
        var out = [];
        var want = ("" + id).replace(/\.desktop$/, "").toLowerCase();
        for (var i = 0; i < Compositor.windows.length; i++) {
            var w = Compositor.windows[i];
            var wa = root.windowApp(w);
            if (app && wa && wa.path === app.path) {
                out.push(w);
            } else if (!wa && want !== "" && root.classBase(w.appId) === want) {
                out.push(w);
            }
        }
        return out;
    }

    function resolvePinned() {
        var out = [];
        var ids = root.pinnedIds || [];
        for (var i = 0; i < ids.length; i++) {
            var id = "" + ids[i];
            var app = root.appById(id);
            if (!app)
                continue;
            var wins = root.windowsForPinned(app, id);
            out.push({
                key: "pin:" + id,
                desktopId: id,
                className: id.replace(/\.desktop$/, ""),
                name: app.name,
                icon: app.icon,
                exec: app.exec,
                app: app,
                pinned: true,
                windows: wins,
                running: wins.length > 0
            });
        }
        return out;
    }

    function resolveRunning() {
        var claimed = {};
        var pinned = root.resolvePinned();
        for (var i = 0; i < pinned.length; i++) {
            for (var j = 0; j < pinned[i].windows.length; j++)
                claimed["" + pinned[i].windows[j].id] = true;
        }
        var map = {};
        var order = [];
        for (var k = 0; k < Compositor.windows.length; k++) {
            var w = Compositor.windows[k];
            if (claimed["" + w.id])
                continue;
            var did = root.windowDesktopId(w);
            var cls = root.classBase(w.appId);
            if (cls === "")
                continue;
            var key = did !== "" ? "run:" + did.toLowerCase() : "run:class:" + cls;
            var app = root.windowApp(w);
            if (!map[key]) {
                map[key] = {
                    key: key,
                    desktopId: did,
                    className: "" + w.appId,
                    name: app ? app.name : ("" + w.appId || "UNIT"),
                    icon: app ? app.icon : ("" + w.appId),
                    exec: app ? app.exec : "",
                    app: app,
                    pinned: false,
                    windows: [],
                    running: true
                };
                order.push(map[key]);
            }
            map[key].windows.push(w);
        }
        return order;
    }

    readonly property var entries: {
        var all = root.resolvePinned().concat(root.resolveRunning());
        return all.slice(0, root.maxItems);
    }

    function entryByKey(key) {
        for (var i = 0; i < root.entries.length; i++) {
            if (root.entries[i].key === key)
                return root.entries[i];
        }
        return null;
    }

    function primaryWindow(entry) {
        return entry && entry.windows && entry.windows.length > 0 ? entry.windows[0] : null;
    }

    function activate(entry) {
        root.menuKey = "";
        var win = root.primaryWindow(entry);
        if (win) {
            Compositor.focusWindow(win.id);
            return;
        }
        if (entry.app)
            Apps.launch(entry.app);
    }

    function canPin(entry) {
        if (!entry)
            return false;
        return entry.pinned || entry.desktopId !== "" || entry.app !== null;
    }

    function togglePin(entry) {
        if (!entry || !root.canPin(entry))
            return;
        var id = entry.desktopId || (entry.app ? root.appDesktopId(entry.app) : "");
        if (id === "")
            return;
        var ids = (Settings.get("dock.pinned", []) || []).slice();
        var found = -1;
        for (var i = 0; i < ids.length; i++) {
            if (("" + ids[i]).toLowerCase() === id.toLowerCase()) {
                found = i;
                break;
            }
        }
        if (found >= 0)
            ids.splice(found, 1);
        else
            ids.push(id);
        Settings.set("dock.pinned", ids);
        root.menuKey = "";
    }

    function newWindow(entry) {
        if (entry && entry.app)
            Apps.launch(entry.app);
    }

    function closeEntry(entry) {
        if (!entry)
            return;
        for (var i = 0; i < entry.windows.length; i++)
            Compositor.closeWindow(entry.windows[i].id);
        root.menuKey = "";
    }

    // 避让：有窗口时收起；进入底部热区展开并把窗口推开（exclusive zone）
    HoverHandler {
        id: hover
        onHoveredChanged: {
            root.hovered = hovered;
            if (hovered) {
                root.hoverLatch = true;
                hideTimer.stop();
            } else {
                hideTimer.restart();
                root.menuKey = "";
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 280
        onTriggered: root.hoverLatch = false
    }

    // 只让 Dock 本体和屏幕边缘热区接收输入；中间的状态栏区域保持可点
    mask: Region {
        Region { item: root.revealed ? dock : null }
        Region { item: root.shouldHide ? triggerArea : null }
    }

    // ---------------------------------------------------------------- 底板
    // 屏幕边缘热区：位于状态栏之上，收起时只显示一条细线
    Item {
        id: triggerArea
        // 与状态列同边时只占中间一段，避免挡住整条状态列的点击
        width: root.barOnSameEdge ? Theme.px(96) : parent.width
        anchors.horizontalCenter: root.barOnSameEdge ? parent.horizontalCenter : undefined
        anchors.left: !root.barOnSameEdge ? parent.left : undefined
        anchors.right: !root.barOnSameEdge ? parent.right : undefined
        anchors.top: root.atTop ? parent.top : undefined
        anchors.bottom: !root.atTop ? parent.bottom : undefined
        height: root.trigger

        Rectangle {
            visible: !root.revealed
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: root.atTop ? parent.top : undefined
            anchors.bottom: !root.atTop ? parent.bottom : undefined
            height: 2
            color: Theme.alpha(Theme.accent, 0.22)
        }
        Rectangle {
            visible: !root.revealed
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: root.atTop ? parent.top : undefined
            anchors.bottom: !root.atTop ? parent.bottom : undefined
            width: Theme.px(56)
            height: 3
            color: Theme.alpha(Theme.accent, 0.8)
        }
    }

    GfFrame {
        id: dock
        visible: root.revealed
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: !root.atTop ? parent.bottom : undefined
        anchors.top: root.atTop ? parent.top : undefined
        anchors.bottomMargin: root.barInset + (root.barOnSameEdge ? 0 : Theme.px(6))
        anchors.topMargin: root.barInset + (root.barOnSameEdge ? 0 : Theme.px(6))
        width: Math.max(contentRow.implicitWidth + Theme.px(26),
            root.menuTarget !== null ? Theme.px(430) : 0)
        height: Theme.px(58)
        Behavior on width {
            enabled: Theme.animations
            NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
        }
        fill: Theme.alpha(Theme.bg0, 0.0)
        borderColor: Theme.alpha(Theme.accent, 0.55)
        chamfer: Theme.px(8)
        innerLine: true
        padding: 0
        cutBottomLeft: true
        cutBottomRight: true
        cutTopLeft: false
        cutTopRight: false
        accentTop: true

        GlassBackdrop {
            anchors.fill: parent
            anchors.margins: 2
            source: Wallpapers.source
            blur: Settings.get("dock.blur", 0)
            gray: Settings.get("dock.gray", 0)
            strength: 0.5
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            color: Theme.alpha(Theme.bg0, Settings.get("dock.opacity", 0.94))
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: Theme.px(4)

            Repeater {
                model: root.entries

                delegate: Item {
                    id: slot
                    required property var modelData
                    required property int index

                    readonly property bool isRunning: modelData.running === true
                    readonly property bool hovered: slotMouse.containsMouse
                    readonly property bool showSeparator: index > 0 && modelData.pinned === false
                        && root.entries[index - 1].pinned === true

                    width: Theme.px(46) + (showSeparator ? Theme.px(8) : 0)
                    height: Theme.px(52)

                    // 固定/运行之间的分隔
                    Rectangle {
                        visible: slot.showSeparator
                        x: 0
                        y: Theme.px(12)
                        width: 1
                        height: Theme.px(26)
                        color: Theme.alpha(Theme.accent, 0.35)
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: Theme.px(42)
                        height: Theme.px(42)
                        color: slot.hovered ? Theme.alpha(Theme.accent, 0.16) : Theme.alpha(Theme.bg0, 0.55)
                        border.width: (slot.hovered || slot.isRunning) ? 1 : 0
                        border.color: Theme.alpha(Theme.accent, slot.hovered ? 0.9 : 0.5)

                        Behavior on color {
                            enabled: Theme.animations
                            ColorAnimation { duration: Theme.durFast }
                        }

                        Image {
                            id: icon
                            anchors.centerIn: parent
                            width: root.iconSize
                            height: root.iconSize
                            source: slot.modelData.icon !== "" ? Quickshell.iconPath(slot.modelData.icon, "") : ""
                            sourceSize.width: root.iconSize * 2
                            sourceSize.height: root.iconSize * 2
                            smooth: true
                            visible: status === Image.Ready

                            scale: slot.hovered ? 1.12 : 1.0
                            Behavior on scale {
                                enabled: Theme.animations
                                NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
                            }
                        }

                        GfIcon {
                            anchors.centerIn: parent
                            visible: icon.status !== Image.Ready
                            name: "apps"
                            iconSize: Theme.px(22)
                            color: slot.hovered ? Theme.accentHi : Theme.textDim
                        }
                    }

                    // 运行指示
                    Rectangle {
                        visible: slot.isRunning
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Theme.px(2)
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: slot.hovered ? Theme.px(14) : Theme.px(6)
                        height: 2
                        color: Theme.accent
                        Behavior on width {
                            enabled: Theme.animations
                            NumberAnimation { duration: Theme.durFast }
                        }
                    }

                    // 名称提示
                    GfFrame {
                        visible: slot.hovered && root.menuKey === ""
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.top
                        anchors.bottomMargin: Theme.px(4)
                        width: Math.max(Theme.px(56), tip.implicitWidth + Theme.px(14))
                        height: Theme.px(20)
                        fill: Theme.alpha(Theme.bg0, 0.97)
                        innerLine: false
                        borderColor: Theme.alpha(Theme.accent, 0.6)
                        chamfer: Theme.px(4)
                        padding: 0
                        brackets: false

                        GfText {
                            id: tip
                            anchors.centerIn: parent
                            text: slot.modelData.name.toUpperCase()
                            role: "mono"
                            size: Theme.sizeTiny - 1
                            tracking: 0.6
                            color: Theme.accent
                        }
                    }

                    MouseArea {
                        id: slotMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                root.menuKey = slot.modelData.key;
                                return;
                            }
                            if (mouse.button === Qt.MiddleButton) {
                                root.newWindow(slot.modelData);
                                return;
                            }
                            root.activate(slot.modelData);
                        }
                    }
                }
            }

            // 部署按钮
            Item {
                width: Theme.px(48)
                height: Theme.px(52)

                Rectangle {
                    anchors.centerIn: parent
                    width: Theme.px(40)
                    height: Theme.px(40)
                    color: deployMouse.containsMouse ? Theme.accent : Theme.alpha(Theme.bg0, 0.6)
                    border.width: 1
                    border.color: Theme.alpha(Theme.accent, 0.8)

                    GfIcon {
                        anchors.centerIn: parent
                        name: "rocket_launch"
                        iconSize: Theme.px(18)
                        color: deployMouse.containsMouse ? Theme.ink : Theme.accent
                    }
                }

                MouseArea {
                    id: deployMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ShellState.toggle("launcher")
                }
            }
        }

        // 右键菜单：固定/取消固定、开新窗口、关闭
        Item {
            id: contextBar
            anchors.fill: parent
            z: 30
            visible: root.menuTarget !== null

            Rectangle {
                anchors.fill: parent
                color: Theme.alpha(Theme.bg0, 0.97)
                border.width: 1
                border.color: Theme.alpha(Theme.accent, 0.5)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.menuKey = ""
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.px(10)
                anchors.rightMargin: Theme.px(10)
                spacing: Theme.px(6)

                GfText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.px(110)
                    text: root.menuTarget ? root.menuTarget.name.toUpperCase() : ""
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    color: Theme.accent
                    elide: Text.ElideRight
                }
                GfButton {
                    anchors.verticalCenter: parent.verticalCenter
                    height: Theme.px(28)
                    compact: true
                    text: root.menuTarget && root.menuTarget.pinned ? I18n.t("dock.unpin") : I18n.t("dock.pin")
                    enabled: root.canPin(root.menuTarget)
                    onClicked: root.togglePin(root.menuTarget)
                }
                GfButton {
                    anchors.verticalCenter: parent.verticalCenter
                    height: Theme.px(28)
                    compact: true
                    visible: root.menuTarget && root.menuTarget.app
                    text: I18n.t("dock.newWindow")
                    onClicked: root.newWindow(root.menuTarget)
                }
                GfButton {
                    anchors.verticalCenter: parent.verticalCenter
                    height: Theme.px(28)
                    compact: true
                    visible: root.menuTarget && root.menuTarget.windows.length > 0
                    danger: true
                    text: I18n.t("dock.closeWindow")
                    onClicked: root.closeEntry(root.menuTarget)
                }
                GfButton {
                    anchors.verticalCenter: parent.verticalCenter
                    height: Theme.px(28)
                    compact: true
                    square: true
                    text: "X"
                    onClicked: root.menuKey = ""
                }
            }
        }

        // 左端编号
        GfText {
            anchors.left: parent.left
            anchors.leftMargin: -Theme.px(26)
            anchors.verticalCenter: parent.verticalCenter
            text: "ECH-09"
            role: "mono"
            size: Theme.sizeTiny - 2
            color: Theme.accent
            rotation: -90
        }
    }
}
