import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.modules.common
import qs.modules.common.widgets

// TrayBlock — 系统托盘的小图标。
Item {
    id: root

    readonly property var items: SystemTray.items.values

    implicitWidth: row.implicitWidth + (root.items.length > 0 ? Theme.px(8) : 0)
    implicitHeight: Theme.barHeight
    visible: root.items.length > 0

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(2)

        Repeater {
            model: root.items

            delegate: Item {
                required property var modelData

                width: Theme.px(20)
                height: Theme.px(20)

                readonly property string iconFile: {
                    if (!modelData.icon || modelData.icon === "")
                        return "";
                    var p = Quickshell.iconPath(modelData.icon, "");
                    if (!p || p.indexOf("qspixmap") >= 0 || p.indexOf("image://") === 0)
                        return "";
                    return p;
                }

                Image {
                    id: trayIcon
                    anchors.centerIn: parent
                    width: Theme.px(15)
                    height: Theme.px(15)
                    source: parent.iconFile
                    sourceSize.width: Theme.px(30)
                    sourceSize.height: Theme.px(30)
                    smooth: true
                    opacity: hover.containsMouse ? 1 : 0.8
                    visible: status === Image.Ready
                }

                GfIcon {
                    anchors.centerIn: parent
                    visible: trayIcon.status !== Image.Ready
                    name: "radio_button_checked"
                    iconSize: Theme.px(11)
                    color: hover.containsMouse ? Theme.accent : Theme.alpha(Theme.text, 0.45)
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton)
                            modelData.activate();
                    }
                }
            }
        }
    }
}
