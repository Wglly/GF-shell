import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// SidebarPanel — 左/右侧边栏：组件可自由分配到左/右，高度与垂直对齐可调。
PanelWindow {
    id: root

    required property var modelData
    property string side: "left"

    screen: modelData
    readonly property var cfg: Settings.get("sidebar." + root.side, ({}))
    readonly property int panelWidth: Theme.px(root.cfg.width !== undefined ? root.cfg.width : 356)
    readonly property real ratio: root.cfg.height !== undefined ? root.cfg.height : 0.92
    readonly property string align: root.cfg.align !== undefined ? root.cfg.align : "top"
    readonly property int screenH: root.modelData.height
    readonly property int panelH: Math.max(Theme.px(320), Math.round(root.screenH * Math.max(0.4, Math.min(1.0, root.ratio))))
    readonly property int barThickness: Theme.px(Settings.get("bar.thickness", 38))
    readonly property bool barAtTop: Settings.get("bar.position", "top") !== "bottom"
    readonly property bool barVisible: Settings.get("bar.visible", true)
    readonly property int topOffset: {
        if (root.align === "center")
            return Math.max(0, Math.round((root.screenH - root.panelH) / 2));
        if (root.align === "bottom")
            return Math.max(0, root.screenH - root.panelH - (root.barVisible && !root.barAtTop ? root.barThickness + 6 : 6));
        return root.barVisible && root.barAtTop ? root.barThickness + 6 : 6;
    }
    readonly property bool open: root.side === "left" ? ShellState.sidebarLeft : ShellState.sidebarRight

    anchors.top: true
    anchors.left: root.side === "left"
    anchors.right: root.side === "right"
    margins.top: root.topOffset
    implicitWidth: root.panelWidth
    implicitHeight: root.panelH
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "gf-shell-sidebar-" + root.side
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    visible: root.open

    readonly property var order: ["user", "clock", "calendar", "weather", "roster", "actions",
        "stats", "mission", "media", "visualizer", "comms", "wallpaper"]

    readonly property var componentIds: {
        var out = [];
        for (var i = 0; i < root.order.length; i++) {
            var id = root.order[i];
            if (Settings.get("sidebar.assign." + id, "off") === root.side)
                out.push(id);
        }
        return out;
    }

    function componentFile(id) {
        switch (id) {
        case "user": return "CompUser";
        case "calendar": return "CompCalendar";
        case "roster": return "CompRoster";
        case "actions": return "CompActions";
        case "stats": return "CompStats";
        case "weather": return "CompWeather";
        case "clock": return "CompClock";
        case "media": return "CompMedia";
        case "visualizer": return "CompVisualizer";
        case "comms": return "CompComms";
        case "mission": return "CompMission";
        case "wallpaper": return "CompWallpaper";
        default: return "";
        }
    }

    function close() {
        if (root.side === "left")
            ShellState.sidebarLeft = false;
        else
            ShellState.sidebarRight = false;
    }

    HoverHandler {
        onHoveredChanged: {
            if (hovered)
                closeTimer.stop();
            else if (root.open)
                closeTimer.restart();
        }
    }

    Timer {
        id: closeTimer
        interval: root.cfg.delay !== undefined ? root.cfg.delay : 650
        onTriggered: root.close()
    }

    Item {
        id: slider
        anchors.fill: parent
        x: root.open ? 0 : (root.side === "left" ? -width : width)
        Behavior on x {
            enabled: Theme.animations
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        GfFrame {
            anchors.fill: parent
            fill: Theme.alpha(Theme.bg0, 0.0)
            borderColor: Theme.alpha(Theme.accent, 0.55)
            chamfer: 0
            padding: 0
            innerLine: true
            cutTopLeft: false
            cutTopRight: false
            cutBottomLeft: false
            cutBottomRight: false

            GlassBackdrop {
                anchors.fill: parent
                anchors.margins: 3
                source: Wallpapers.source
                blur: root.cfg.blur !== undefined ? root.cfg.blur : 0
                gray: root.cfg.gray !== undefined ? root.cfg.gray : 0
                strength: 0.55
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                color: Theme.alpha(Theme.bg1, root.cfg.opacity !== undefined ? root.cfg.opacity : 0.94)
            }

            Rectangle {
                x: root.side === "left" ? 0 : parent.width - Theme.px(3)
                y: 0
                width: Theme.px(3)
                height: parent.height
                color: Theme.accent
            }
            Rectangle {
                x: 0; y: 0
                width: parent.width; height: 1
                color: Theme.alpha(Theme.accent, 0.5)
            }

            Image {
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/textures/halftone.png")
                fillMode: Image.Tile
                opacity: 0.25
            }

            // 头部
            Item {
                id: header
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.px(16)
                height: Theme.px(34)

                Rectangle {
                    x: 0; y: 0
                    width: Theme.px(4); height: Theme.px(30)
                    color: Theme.accent
                }

                Column {
                    x: Theme.px(12)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: -3
                    GfText {
                        text: root.side === "left" ? I18n.t("sidebar.squad") : I18n.t("sidebar.comms")
                        role: "display"; size: Theme.sizeMedium + 1
                        tracking: 2.4; bold: true
                    }
                    GfText {
                        text: root.side === "left" ? I18n.t("sidebar.squadSub") : I18n.t("sidebar.commsSub")
                        role: "ui"; size: Theme.sizeTiny - 1; tone: "faint"
                    }
                }

                GfIconButton {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "close"
                    glyphSize: Theme.px(14)
                    buttonSize: Theme.px(24)
                    danger: true
                    onClicked: root.close()
                }
            }

            GfDivider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: header.bottom
                anchors.leftMargin: Theme.px(16)
                anchors.rightMargin: Theme.px(16)
                anchors.topMargin: Theme.px(4)
                color: Theme.alpha(Theme.accent, 0.35)
            }

            // 可滚动组件区
            Flickable {
                id: flick
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: header.bottom
                anchors.bottom: footer.top
                anchors.leftMargin: Theme.px(16)
                anchors.rightMargin: Theme.px(16)
                anchors.topMargin: Theme.px(18)
                anchors.bottomMargin: Theme.px(8)
                clip: true
                contentWidth: width
                contentHeight: compColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: compColumn
                    width: flick.width
                    spacing: Theme.px(12)

                    Repeater {
                        model: root.componentIds

                        delegate: Loader {
                            required property var modelData
                            width: compColumn.width
                            source: Qt.resolvedUrl("components/" + root.componentFile(modelData) + ".qml")
                        }
                    }
                }

            }

            // 固定滚动条（不随内容滚动）
            Rectangle {
                visible: flick.contentHeight > flick.height
                x: flick.x + flick.width - 2
                y: flick.y + flick.visibleArea.yPosition * flick.height
                width: 2
                height: Math.max(18, flick.visibleArea.heightRatio * flick.height)
                color: Theme.alpha(Theme.accent, 0.55)
            }

            // 组件全关时的提示
            GfText {
                anchors.centerIn: parent
                visible: root.componentIds.length === 0
                text: I18n.t("sidebar.noComponents")
                role: "mono"; size: Theme.sizeTiny; tone: "faint"
            }

            // 底部
            Item {
                id: footer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Theme.px(16)
                height: Theme.px(18)

                GfText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.side === "left" ? I18n.t("sidebar.sector") : I18n.t("sidebar.array")
                    role: "mono"; size: Theme.sizeTiny - 3
                    color: Theme.alpha(Theme.accent, 0.45)
                }
                GfText {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(root.ratio * 100) + "%"
                    role: "mono"; size: Theme.sizeTiny - 3
                    color: Theme.alpha(Theme.accent, 0.35)
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        focus: root.open
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.close();
                event.accepted = true;
            }
        }
    }
}
