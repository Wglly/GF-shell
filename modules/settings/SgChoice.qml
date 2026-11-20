import QtQuick
import "SgStyle.js" as Sg
import qs.modules.common

// SgChoice — 黑灰分段选择，选中变黄。
Row {
    id: root

    property var options: []          // [{ value, label }]
    property var current: ""
    signal selected(var value)

    spacing: Theme.fpx(4)

    Repeater {
        model: root.options

        delegate: Item {
            required property var modelData
            readonly property bool active: root.current === modelData.value

            width: Math.max(Theme.fpx(44), textItem.implicitWidth + Theme.fpx(18))
            height: Theme.fpx(26)

            Rectangle {
                anchors.fill: parent
                color: parent.active || mouse.containsMouse ? Sg.yellow : Sg.gray
                border.width: 1
                border.color: Theme.lineColor(parent.active ? Sg.ink : Sg.ink)
                radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
            }

            Text {
                id: textItem
                anchors.centerIn: parent
                text: modelData.label
                font.family: Theme.fontUI
                font.pixelSize: Theme.fs(10)
                font.letterSpacing: Theme.fpx(1)
                font.bold: true
                color: parent.active || mouse.containsMouse ? Sg.ink : "#f4f1e8"
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selected(modelData.value)
            }
        }
    }
}
