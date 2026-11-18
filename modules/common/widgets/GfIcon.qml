import QtQuick
import qs.modules.common

// GfIcon — Material Symbols 字形图标（已随附子集字体，约 31 KB）。
Item {
    id: root

    property string name: ""
    property color color: Theme.text
    property real iconSize: Theme.iconSize
    property real fill: 0        // Material Symbols "FILL" 轴（0/1）
    property bool dim: false

    implicitWidth: iconSize
    implicitHeight: iconSize

    Text {
        anchors.centerIn: parent
        text: root.name
        color: root.dim ? Theme.textDim : root.color
        font.family: "GF Tactical Icons"
        font.pixelSize: Math.round(root.iconSize)
        font.hintingPreference: Font.PreferNoHinting
        renderType: Text.NativeRendering
        opacity: root.enabled ? 1 : 0.45
    }
}
