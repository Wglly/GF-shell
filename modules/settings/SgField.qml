import QtQuick
import "SgStyle.js" as Sg
import qs.modules.common

// SgField — 纸白输入框，黑框；聚焦变黄。
Item {
    id: root

    property string text: ""
    property string placeholder: ""
    signal accepted(string value)

    implicitHeight: Theme.fpx(28)
    implicitWidth: Theme.fpx(240)
    readonly property bool focused: input.activeFocus

    Rectangle {
        anchors.fill: parent
        color: Sg.paper
        border.width: 1
        border.color: root.focused ? Sg.yellow : Sg.ink
        radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: Theme.fpx(8)
        anchors.rightMargin: Theme.fpx(8)
        text: root.text
        color: Sg.ink
        font.family: Theme.fontMono
        font.pixelSize: Theme.fs(10)
        verticalAlignment: TextInput.AlignVCenter
        selectByMouse: true
        clip: true
        onTextEdited: root.text = text
        onAccepted: root.accepted(text)
        Keys.onEscapePressed: input.focus = false

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: input.text === ""
            text: root.placeholder
            color: Sg.mute
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(10)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: input.forceActiveFocus()
    }
}
