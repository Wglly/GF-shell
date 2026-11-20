import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// Dashboard — 仪表盘 / macOS-Launchpad-like 全屏单位总览。
// 主题决定标题、配色、卡片轮廓与背景签名，非当前主题不渲染。
PanelWindow {
    id: root

    readonly property bool open: ShellState.overlay === "dashboard"
    visible: root.open
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "gf-shell-dashboard"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property date now: new Date()
    property string query: ""
    property int columns: Math.max(4, Math.min(8, Math.floor((width - Theme.px(96)) / Theme.px(158))))

    readonly property bool arknights: Theme.arknights
    readonly property bool bf4: Theme.bf4
    readonly property bool bf1: Theme.bf1

    readonly property var filtered: {
        var q = root.query.toLowerCase().trim();
        var out = [];
        for (var i = 0; i < Apps.apps.length; i++) {
            var a = Apps.apps[i];
            if (q === "" || a.search.indexOf(q) >= 0)
                out.push(a);
        }
        return out;
    }

    function close() {
        ShellState.close();
        root.query = "";
    }

    Timer {
        interval: 1000; repeat: true; running: root.open; triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    onOpenChanged: {
        if (root.open) {
            root.query = "";
            focusScope.forceActiveFocus();
        }
    }

    // 点击空白关闭
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.close()
    }

    Item {
        id: focusScope
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.close();
                event.accepted = true;
            }
        }

        GfFrame {
            anchors.fill: parent
            anchors.margins: Theme.px(28)
            z: 2
            fill: root.bf1 ? "transparent" : Theme.alpha(Theme.bg0, 0.88)
            borderColor: root.bf1 ? "transparent"
                : (root.arknights ? Theme.alpha(Theme.text, 0.7)
                : (root.bf4 ? Theme.alpha(Theme.accent2, 0.75) : Theme.alpha(Theme.accent, 0.55)))
            chamfer: root.bf1 ? 0 : (root.arknights || root.bf4 ? Theme.px(2) : Theme.px(6))
            innerLine: !root.bf1
            padding: 0

            // BF1：旧纸圆角面板
            Rectangle {
                visible: root.bf1
                anchors.fill: parent
                anchors.margins: Theme.px(1)
                radius: Theme.bf1Radius > 0 ? Theme.px(Theme.bf1Radius + 4) : 0
                color: Theme.alpha(Theme.bg0, 0.97)
                border.width: 2
                border.color: Theme.alpha(Theme.accent, 0.5)
            }

            GlassBackdrop {
                visible: !root.bf1
                anchors.fill: parent
                anchors.margins: 2
                source: Wallpapers.source
                blur: 0.7
                gray: root.bf1 ? 0.75 : 0.35
                strength: 0.35
            }
            Rectangle {
                visible: !root.bf1
                anchors.fill: parent
                anchors.margins: 2
                color: Theme.alpha(Theme.bg0, 0.6)
            }

            Column {
                anchors.fill: parent
                anchors.leftMargin: Theme.px(38)
                anchors.rightMargin: Theme.px(38)
                anchors.topMargin: Theme.px(28)
                anchors.bottomMargin: Theme.px(22)
                spacing: Theme.px(12)

                // ---------------------------------------------------- header
                Item {
                    width: parent.width
                    height: Theme.px(64)

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.px(16)

                        Rectangle {
                            width: Theme.px(5); height: Theme.px(48)
                            color: root.arknights ? Theme.accent
                                : (root.bf4 ? Theme.accent2 : Theme.accent)
                        }
                        Column {
                            spacing: Theme.px(1)
                            Text {
                                text: Theme.dashboardTitle
                                font.family: root.bf1 ? Theme.fontDisplay : Theme.fontDisplay
                                font.pixelSize: Theme.fs(30)
                                font.letterSpacing: Theme.px(2)
                                color: root.bf1 ? Theme.accentHi : Theme.text
                            }
                            Text {
                                text: root.arknights ? "RHODES ISLAND  ·  DEPLOYMENT OVERVIEW"
                                    : (root.bf4 ? "US // COMBINED ARMS  ·  COMMANDER UPLINK"
                                    : (root.bf1 ? "WESTERN FRONT  ·  FIELD COMMAND"
                                    : "G&K  ·  OPERATOR DASHBOARD"))
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fs(9)
                                font.letterSpacing: 1.6
                                color: Theme.accent
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.px(18)
                        Column {
                            spacing: 0
                            Text {
                                text: Qt.formatTime(root.now, "HH:mm")
                                font.family: Theme.fontDisplay
                                font.pixelSize: Theme.fs(25)
                                color: Theme.text
                                horizontalAlignment: Text.AlignRight
                            }
                            Text {
                                text: Qt.formatDate(root.now, "dddd  ·  dd MMM yyyy").toUpperCase()
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fs(8)
                                color: Theme.textDim
                            }
                        }
                        GfButton {
                            compact: true
                            height: Theme.px(30)
                            text: "CLOSE"
                            onClicked: root.close()
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Theme.alpha(Theme.accent, 0.38) }

                // ---------------------------------------------------- widgets
                Row {
                    width: parent.width
                    spacing: Theme.px(8)
                    height: Theme.px(112)

                    Repeater {
                        model: [
                            { key: "system", label: "SYSTEM", value: Math.round(Stats.cpu * 100) + "%", sub: "MEM " + Math.round(Stats.mem * 100) + "%" },
                            { key: "battery", label: "POWER", value: Battery.percent + "%", sub: Battery.charging ? "CHARGING" : "DISCHARGE" },
                            { key: "network", label: "LINK", value: Net.online ? "ONLINE" : "OFFLINE", sub: Net.ssid !== "" ? Net.ssid : "NO UPLINK" },
                            { key: "media", label: "MEDIA", value: Media.title !== "" ? Media.title : "NO SIGNAL", sub: Media.artist !== "" ? Media.artist : "STANDBY" }
                        ]

                        delegate: GfFrame {
                            required property var modelData
                            width: (parent.width - Theme.px(24)) / 4
                            height: parent.height
                            fill: root.bf1 ? "transparent" : Theme.alpha(Theme.panel, 0.55)
                            borderColor: root.bf1 ? "transparent" : Theme.alpha(Theme.accent, 0.28)
                            chamfer: root.bf1 ? 0 : (root.arknights || root.bf4 ? 2 : Theme.px(4))
                            innerLine: false
                            padding: Theme.px(10)

                            Rectangle {
                                visible: root.bf1
                                anchors.fill: parent
                                radius: Theme.px(Theme.bf1Radius)
                                color: Theme.alpha(Theme.panel, 0.94)
                                border.width: 1
                                border.color: Theme.alpha(Theme.accent, 0.32)
                            }

                            Column {
                                width: parent.width
                                spacing: Theme.px(3)
                                Text {
                                    text: modelData.label
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fs(8)
                                    font.letterSpacing: 1.5
                                    color: Theme.accent
                                }
                                Text {
                                    width: parent.width
                                    text: modelData.value
                                    font.family: Theme.fontDisplay
                                    font.pixelSize: modelData.key === "media" ? Theme.fs(13) : Theme.fs(20)
                                    color: Theme.text
                                    elide: Text.ElideRight
                                }
                                Text {
                                    width: parent.width
                                    text: modelData.sub
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fs(8)
                                    color: Theme.textDim
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                // ---------------------------------------------------- search
                Item {
                    width: parent.width
                    height: Theme.px(42)

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.alpha(Theme.bg1, 0.8)
                        border.width: 1
                        border.color: Theme.alpha(Theme.accent, 0.3)
                    }
                    TextInput {
                        id: search
                        anchors.fill: parent
                        anchors.leftMargin: Theme.px(16)
                        anchors.rightMargin: Theme.px(16)
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.text
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fs(13)
                        selectByMouse: true
                        clip: true
                        onTextChanged: root.query = text
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: search.text === ""
                            text: root.arknights ? "SEARCH OPERATORS / APPLICATIONS"
                                : (root.bf4 ? "SEARCH ASSETS / APPLICATIONS"
                                : (root.bf1 ? "SEARCH FIELD UNITS / APPLICATIONS" : "SEARCH UNITS / APPLICATIONS"))
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fs(10)
                            color: Theme.textFaint
                        }
                    }
                }

                // ---------------------------------------------------- app grid
                Flickable {
                    id: scroller
                    width: parent.width
                    height: parent.height - Theme.px(64) - Theme.px(112) - Theme.px(42) - Theme.px(72)
                    clip: true
                    contentWidth: width
                    contentHeight: grid.height
                    boundsBehavior: Flickable.StopAtBounds

                    WheelHandler {
                        onWheel: wheel => {
                            var dy = (wheel.angleDelta.y / 120) * Theme.px(96);
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
                            model: root.filtered
                            delegate: Item {
                                required property var modelData
                                readonly property bool hovered: cellMouse.containsMouse
                                width: (grid.width - Theme.px(8) * (root.columns - 1)) / root.columns
                                height: Theme.px(112)

                                Rectangle {
                                    anchors.fill: parent
                                    radius: root.bf1 && Theme.bf1Radius > 0 ? Theme.px(Math.max(2, Theme.bf1Radius - 2)) : 0
                                    color: cellMouse.containsMouse ? Theme.alpha(Theme.accent, 0.16)
                                        : Theme.alpha(Theme.panel, root.bf1 ? 0.9 : 0.35)
                                    border.width: 1
                                    border.color: cellMouse.containsMouse ? Theme.accent : Theme.alpha(Theme.accent, 0.18)
                                }
                                Image {
                                    id: dashIcon
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: Theme.px(18)
                                    width: Theme.px(38); height: Theme.px(38)
                                    source: modelData.icon !== "" ? Quickshell.iconPath(modelData.icon, "") : ""
                                    sourceSize.width: Theme.px(76); sourceSize.height: Theme.px(76)
                                    smooth: true
                                    visible: status === Image.Ready
                                }
                                GfIcon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: Theme.px(20)
                                    visible: dashIcon.status !== Image.Ready
                                    name: "apps"; iconSize: Theme.px(28)
                                    color: Theme.accent
                                }
                                Text {
                                    anchors.left: parent.left; anchors.leftMargin: Theme.px(8)
                                    anchors.right: parent.right; anchors.rightMargin: Theme.px(8)
                                    anchors.bottom: parent.bottom; anchors.bottomMargin: Theme.px(8)
                                    text: modelData.name
                                    font.family: Theme.fontUI
                                    font.pixelSize: Theme.fs(9)
                                    color: cellMouse.containsMouse ? Theme.accent : Theme.textDim
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                MouseArea {
                                    id: cellMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Apps.launch(modelData);
                                    }
                                }
                            }
                        }
                    }
                }

                // ---------------------------------------------------- footer
                Item {
                    width: parent.width
                    height: Theme.px(42)

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.filtered.length + " UNITS  ·  " + Theme.themeTitle
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fs(9)
                        color: Theme.textFaint
                    }
                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.px(6)
                        GfButton { compact: true; height: Theme.px(28); text: "SETTINGS"; onClicked: ShellState.open("settings") }
                        GfButton { compact: true; height: Theme.px(28); text: "CONTROL"; onClicked: ShellState.open("control") }
                        GfButton { compact: true; height: Theme.px(28); text: "MAP"; onClicked: ShellState.open("overview") }
                        GfButton { compact: true; height: Theme.px(28); text: "LAUNCHER"; onClicked: ShellState.open("launcher") }
                    }
                }
            }
        }
    }
}
