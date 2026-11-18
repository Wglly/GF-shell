import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// ControlBlock — 战术控制中心。
GfIconButton {
    id: root

    icon: "tune"
    glyphSize: Theme.px(16)
    checked: ShellState.overlay === "control"
    badge: Notifs.items.length > 0 ? ("" + Notifs.items.length) : ""
    onClicked: ShellState.toggle("control")
}
