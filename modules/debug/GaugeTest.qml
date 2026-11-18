import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

PanelWindow {
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#0b0f13"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    Row {
        anchors.centerIn: parent
        spacing: 40
        Repeater {
            model: [0.1, 0.4, 0.86, 1.0]
            Item {
                width: 120; height: 160
                required property real modelData
                GfGauge {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 90; height: 90
                    value: parent.modelData
                    segments: 26
                    thickness: 3
                    segmentLength: 10
                    color: "#f0a43c"
                }
                GfText {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "V=" + modelData + " CPU=" + Stats.cpu.toFixed(2) + " MEM=" + Stats.mem.toFixed(2)
                    role: "mono"; size: 12
                }
            }
        }
    }
}
