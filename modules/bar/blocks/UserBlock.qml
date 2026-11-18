import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// UserBlock — 状态列操作员入口，点击展开用户档案。
Item {
    id: root

    readonly property bool hovered: mouse.containsMouse
    implicitWidth: Theme.px(104)
    implicitHeight: Theme.barHeight

    Rectangle {
        anchors.fill: parent
        color: root.hovered || ShellState.popupKind === "user"
            ? Theme.alpha(Theme.accent, 0.16) : "transparent"
    }

    Row {
        anchors.centerIn: parent
        spacing: Theme.px(6)

        Image {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(18)
            height: Theme.px(18)
            source: User.avatar
            fillMode: Image.PreserveAspectFit
            opacity: root.hovered ? 1 : 0.85
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: -2

            GfText {
                text: "OPERATOR"
                role: "mono"
                size: Theme.sizeTiny - 3
                color: Theme.alpha(Theme.accent, 0.65)
            }
            GfText {
                text: User.displayName
                role: "mono"
                size: Theme.sizeTiny - 1
                color: root.hovered ? Theme.accentHi : Theme.text
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.accent
        visible: root.hovered || ShellState.popupKind === "user"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var p = root.mapToItem(null, root.width / 2, root.height);
            ShellState.togglePopup("user", p.x, p.y, "");
        }
    }
}
