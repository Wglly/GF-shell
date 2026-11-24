import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// TerminalBlock — launches the GF-shell branded GF Terminal.
GfIconButton {
    id: root

    icon: "terminal"
    glyphSize: Theme.px(16)
    onClicked: Terminal.launch()
}
