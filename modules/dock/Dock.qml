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
    readonly property bool autoHide: Settings.get("dock.autoHide", true)
    readonly property bool avoid: Settings.get("dock.avoid", true)
    readonly property int iconSize: Math.round(Settings.get("dock.iconSize", 42) * Theme.uiScale)
    readonly property int maxItems: Settings.get("dock.maxItems", 9)
    readonly property bool atTop: Settings.get("dock.position", "bottom") === "top"
    readonly property bool hasWindows: Compositor.windows.length > 0
    readonly property bool shouldHide: (root.avoid && root.hasWindows) || root.autoHide
    property bool hovered: false
    readonly property bool revealed: !root.shouldHide || root.hovered

    visible: root.enabled && entries.length > 0
    color: "transparent"
    anchors.bottom: !root.atTop
    anchors.top: root.atTop
    anchors.left: true
    anchors.right: true
    implicitHeight: root.revealed ? Theme.px(76) : Theme.px(6)
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: root.visible ? root.implicitHeight : 0
    Behavior on implicitHeight {
        enabled: Theme.animations
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "gf-shell-dock"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // ---------------------------------------------------------------- 应用列表
    readonly property var pinnedIds: Settings.get("dock.pinned", [])

    function resolvePinned() {
        var out = [];
        var ids = root.pinnedIds;
        for (var i = 0; i < ids.length; i++) {
            var app = null;
            for (var j = 0; j < Apps.apps.length; j++) {
                if (Apps.apps[j].path.split("/").pop() === ids[i]) {
                    app = Apps.apps[j];
                    break;
                }
            }
            if (app)
                out.push({ name: app.name, icon: app.icon, exec: app.exec, path: app.path, app: app, pinned: true });
        }
        return out;
    }

    function resolveRunning() {
        var out = [];
        var seen = {};
        var list = Compositor.windows;
        for (var i = 0; i < list.length; i++) {
            var cls = list[i].appId;
            if (!cls)
                continue;
            var key = ("" + cls).toLowerCase();
            if (seen[key])
                continue;
            seen[key] = true;
            var app = Apps.findByClass(cls);
            out.push({
                name: app ? app.name : cls,
                icon: app ? app.icon : "",
                exec: app ? app.exec : "",
                path: app ? app.path : "",
                app: app,
                pinned: false
            });
        }
        return out;
    }

    readonly property var entries: {
        var pinned = root.resolvePinned();
        var running = root.resolveRunning();
        var out = pinned.slice();
        var names = {};
        for (var i = 0; i < out.length; i++)
            names[("" + out[i].name).toLowerCase()] = true;
        for (var j = 0; j < running.length; j++) {
            if (!names[("" + running[j].name).toLowerCase()])
                out.push(running[j]);
        }
        return out.slice(0, root.maxItems);
    }

    function windowFor(entry) {
        var list = Compositor.windows;
        var key = ("" + entry.name).toLowerCase();
        for (var i = 0; i < list.length; i++) {
            var cls = ("" + list[i].appId).toLowerCase();
            if (cls === key)
                return list[i];
            var app = Apps.findByClass(list[i].appId);
            if (app && ("" + app.name).toLowerCase() === key)
                return list[i];
        }
        return null;
    }

    function activate(entry) {
        var win = root.windowFor(entry);
        if (win) {
            Compositor.focusWindow(win.id);
            return;
        }
        if (entry.app)
            Apps.launch(entry.app);
    }

    // 避让：有窗口时收起；进入底部热区展开并把窗口推开（exclusive zone）
    HoverHandler {
        id: hover
        onHoveredChanged: root.hovered = hovered
    }

    // ---------------------------------------------------------------- 底板
    // 收起时露出的金色细线
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        y: root.atTop ? 0 : parent.height - 2
        height: 2
        color: Theme.alpha(Theme.accent, 0.6)
    }

    GfFrame {
        id: dock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: !root.atTop ? parent.bottom : undefined
        anchors.top: root.atTop ? parent.top : undefined
        anchors.bottomMargin: Settings.get("bar.position", "top") === "bottom" ? Settings.get("bar.thickness", 38) + Theme.px(6) : Theme.px(6)
        anchors.topMargin: Settings.get("bar.position", "bottom") === "bottom" ? Settings.get("bar.thickness", 38) + Theme.px(6) : Theme.px(6)
        width: contentRow.implicitWidth + Theme.px(26)
        height: Theme.px(58)
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

                    readonly property bool isRunning: root.windowFor(modelData) !== null
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
                        visible: slot.hovered
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
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.MiddleButton && slot.modelData.app) {
                                Quickshell.execDetached(["/bin/sh", "-c", slot.modelData.exec]);
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
