import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// WorkspacesBlock — 斜切页签式梯队/工作区编号。
Item {
    id: root

    readonly property var list: Compositor.workspaces
    readonly property int focused: Compositor.focusedId

    implicitWidth: row.implicitWidth + Theme.px(8)
    implicitHeight: Theme.barHeight

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.px(1)

        Repeater {
            model: root.list

            delegate: GfTab {
                id: tab
                required property var modelData
                required property int index

                readonly property bool active: modelData.active === true

                width: Theme.px(40)
                height: Theme.px(24)
                skew: Theme.px(7)
                checked: tab.active
                readonly property int slotNo: tab.modelData.idx !== undefined ? tab.modelData.idx
                    : (tab.modelData.id !== undefined ? tab.modelData.id : (index + 1))
                number: Theme.hoi4
                    ? (["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"][tab.slotNo - 1] || ("" + tab.slotNo))
                    : ("0" + tab.slotNo).slice(-2)

                // 占用指示
                Rectangle {
                    visible: tab.modelData.occupied === true
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.px(3)
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Theme.px(3)
                    height: Theme.px(3)
                    rotation: 45
                    color: tab.active ? Theme.ink : Theme.alpha(Theme.accent, 0.75)
                }

                onClicked: Compositor.focusWorkspace(tab.modelData.id)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => Compositor.step(wheel.angleDelta.y > 0 ? -1 : 1)
    }
}
