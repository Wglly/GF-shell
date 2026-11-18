import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// OverviewBlock — 打开作战地图。
GfIconButton {
    id: root

    icon: "map"
    glyphSize: Theme.px(16)
    checked: ShellState.overlay === "overview"
    onClicked: ShellState.toggle("overview")
}
