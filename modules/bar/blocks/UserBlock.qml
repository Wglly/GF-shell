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

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(20)
            height: Theme.px(20)
            Rectangle {
                anchors.fill: parent
                visible: Theme.hoi4 || Theme.battle || Theme.arknights
                color: "transparent"
                border.width: 1
                border.color: Theme.hoi4 ? Theme.alpha(Theme.accent, 0.8)
                    : (Theme.battle ? Theme.alpha(Theme.accent2, 0.8) : Theme.alpha(Theme.accent, 0.65))
            }
            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: User.avatar
                fillMode: Image.PreserveAspectFit
                opacity: root.hovered ? 1 : 0.85
            }
            GfText {
                visible: Theme.hoi4
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: Theme.px(-6)
                text: "★"
                role: "mono"
                size: Theme.sizeTiny - 3
                color: Theme.accentHi
            }
            GfText {
                visible: Theme.battle
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.px(-5)
                text: Theme.bf4 ? "SGT" : "LT"
                role: "mono"
                size: Theme.sizeTiny - 4
                color: Theme.accent2
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: -2

            GfText {
                text: Theme.hoi4 ? "HEAD OF STATE"
                    : (Theme.arknights ? "DOCTOR" : (Theme.bf4 ? "COMMANDER"
                    : (Theme.bf1 ? "OFFICER" : "OPERATOR")))
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
