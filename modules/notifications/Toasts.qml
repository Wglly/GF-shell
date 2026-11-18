import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// Toasts — 右上角的通讯弹窗（通知）。
PanelWindow {
    id: root

    readonly property bool open: Notifs.items.length > 0 && Settings.get("notifications.toasts", true)
    visible: root.open
    color: "transparent"
    anchors.top: true
    anchors.right: true
    margins.top: Theme.barHeight + Theme.px(8)
    margins.right: Theme.px(8)
    implicitWidth: Theme.px(360)
    implicitHeight: Math.max(1, column.implicitHeight)
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "gf-shell-toasts"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    function focusedScreen() {
        var name = Compositor.outputName;
        var list = Quickshell.screens;
        for (var i = 0; i < list.length; i++) {
            if (list[i].name === name)
                return list[i];
        }
        return list.length > 0 ? list[0] : null;
    }
    screen: focusedScreen()

    Column {
        id: column
        width: parent.width
        spacing: Theme.px(6)

        Repeater {
            model: Notifs.items.slice(-Math.max(1, Settings.get("notifications.maxToasts", 4)))

            delegate: GfFrame {
                id: toast
                required property var modelData

                width: column.width
                height: Math.max(Theme.px(56), bodyColumn.implicitHeight + Theme.px(20))
                fill: Theme.alpha(Theme.panel, 0.97)
                borderColor: Theme.alpha(Theme.accent, 0.55)
                chamfer: Theme.px(8)
                padding: 0
                accentLeft: true

                property real revealed: 0

                Component.onCompleted: revealAnim.start()

                NumberAnimation on revealed {
                    id: revealAnim
                    from: 0
                    to: 1
                    duration: Theme.durNormal
                    easing.type: Easing.OutCubic
                }

                opacity: toast.revealed
                transform: Translate {
                    x: (1 - toast.revealed) * Theme.px(24)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifs.dismiss(toast.modelData.key)
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.px(10)
                    spacing: Theme.px(9)

                    Rectangle {
                        width: Theme.px(30)
                        height: Theme.px(30)
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.alpha(Theme.panelHi, 0.8)
                        border.width: 1
                        border.color: Theme.alpha(Theme.line, 0.9)

                        Image {
                            anchors.fill: parent
                            visible: toast.modelData.icon !== "" && toast.modelData.icon !== undefined
                            source: toast.modelData.icon !== "" ? Quickshell.iconPath(toast.modelData.icon, "") : ""
                            fillMode: Image.PreserveAspectFit
                            sourceSize.width: Theme.px(48)
                            sourceSize.height: Theme.px(48)
                            smooth: true
                        }

                        GfIcon {
                            anchors.centerIn: parent
                            visible: toast.modelData.icon === "" || toast.modelData.icon === undefined
                            name: "notifications"
                            iconSize: Theme.px(15)
                            color: Theme.accent
                        }
                    }

                    Column {
                        id: bodyColumn
                        width: parent.width - Theme.px(42)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        GfText {
                            width: parent.width
                            text: ("" + toast.modelData.app).toUpperCase() + "  //  INCOMING"
                            role: "mono"
                            size: Theme.sizeTiny - 2
                            color: Theme.accent
                            tracking: 1
                        }

                        GfText {
                            width: parent.width
                            text: toast.modelData.summary
                            role: "ui"
                            size: Theme.sizeSmall
                            color: Theme.text
                            elide: Text.ElideRight
                        }

                        GfText {
                            visible: toast.modelData.body !== ""
                            width: parent.width
                            text: toast.modelData.body
                            role: "ui"
                            size: Theme.sizeTiny
                            tone: "faint"
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                // 底部强调线
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    height: 1
                    width: parent.width * 0.4
                    color: Theme.alpha(Theme.accent, 0.45)
                }
            }
        }
    }
}
