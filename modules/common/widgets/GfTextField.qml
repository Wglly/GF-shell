import QtQuick
import qs.modules.common

// GfTextField — 少前式输入框：黑底金框、左侧图标、聚焦时金色底线。
Item {
    id: root

    property alias text: input.text
    property alias cursorPosition: input.cursorPosition
    property string placeholder: ""
    property string icon: "search"
    property bool showClear: true
    property int echoMode: TextInput.Normal
    property color accentColor: Theme.accent

    signal accepted()
    signal cleared()
    signal dismissed()
    signal navigate(int dx, int dy)

    readonly property bool focused: input.activeFocus

    implicitHeight: Theme.px(34)
    implicitWidth: Theme.px(300)

    function forceFocus() {
        input.forceActiveFocus();
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.alpha(Theme.bg0, 0.75)
        radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
        border.width: 1
        border.color: Theme.lineColor(root.focused ? Theme.alpha(root.accentColor, 0.85) : Theme.alpha(root.accentColor, 0.35))
        Behavior on border.color {
            enabled: Theme.animations
            ColorAnimation { duration: Theme.durFast }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: root.focused ? parent.width : Theme.px(40)
        height: 1
        color: Theme.lineColor(root.accentColor)
        Behavior on width {
            enabled: Theme.animations
            NumberAnimation { duration: Theme.durNormal; easing.type: Easing.OutCubic }
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.px(10)
        anchors.rightMargin: Theme.px(8)
        spacing: Theme.px(8)

        GfIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            iconSize: Theme.px(15)
            color: root.focused ? root.accentColor : Theme.textFaint
        }

        TextInput {
            echoMode: root.echoMode
            id: input
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.px(24)
            clip: true
            color: Theme.text
            selectionColor: Theme.alpha(root.accentColor, 0.45)
            selectedTextColor: Theme.text
            font.family: Theme.fontUI
            font.pixelSize: Theme.sizeNormal
            font.letterSpacing: 0.4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: input.text === ""
                text: root.placeholder
                color: Theme.textFaint
                font.family: Theme.fontUI
                font.pixelSize: Theme.sizeNormal
                font.letterSpacing: 0.4
            }

            onAccepted: root.accepted()

            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_Escape:
                    root.dismissed();
                    event.accepted = true;
                    break;
                case Qt.Key_Down:
                    root.navigate(0, 1);
                    event.accepted = true;
                    break;
                case Qt.Key_Up:
                    root.navigate(0, -1);
                    event.accepted = true;
                    break;
                case Qt.Key_Left:
                    root.navigate(-1, 0);
                    event.accepted = true;
                    break;
                case Qt.Key_Right:
                    root.navigate(1, 0);
                    event.accepted = true;
                    break;
                case Qt.Key_Tab:
                    root.navigate(1, 0);
                    event.accepted = true;
                    break;
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    root.accepted();
                    event.accepted = true;
                    break;
                }
            }
        }

        GfIcon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showClear && input.text !== ""
            name: "close"
            iconSize: Theme.px(13)
            color: clearArea.containsMouse ? Theme.accent : Theme.textFaint

            MouseArea {
                id: clearArea
                anchors.fill: parent
                anchors.margins: -Theme.px(3)
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    input.text = "";
                    root.cleared();
                    input.forceActiveFocus();
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: input.forceActiveFocus()
    }
}
