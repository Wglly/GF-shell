import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// PowerBlock — 系统停机菜单。
GfIconButton {
    id: root

    icon: "power_settings_new"
    glyphSize: Theme.px(16)
    danger: true
    checked: ShellState.overlay === "power"
    onClicked: ShellState.toggle("power")
}
