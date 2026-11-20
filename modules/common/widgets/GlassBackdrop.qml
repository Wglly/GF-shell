import QtQuick
import qs.modules.common

// GlassBackdrop — 壁纸采样 + 高斯模糊 + 去饱和，用作半透明面板的质感层。
// 不依赖合成器 blur；在 niri / Hyprland 上表现一致。
Item {
    id: root
    visible: !Theme.light

    property string source: ""
    property real blur: 0          // 0..1
    property real gray: 0          // 0..1
    property real strength: 1.0    // 壁纸在面板中的可见度

    Image {
        id: img
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        visible: false
        asynchronous: true
        sourceSize.width: Math.max(1, Math.round(root.width))
        sourceSize.height: Math.max(1, Math.round(root.height))
    }

    ShaderEffectSource {
        id: sourceTex
        sourceItem: img
        hideSource: true
        live: true
        textureSize: Qt.size(Math.max(1, Math.round(root.width)), Math.max(1, Math.round(root.height)))
    }

    ShaderEffect {
        anchors.fill: parent
        visible: !Theme.light && (root.blur > 0.01 || root.gray > 0.01)
        property variant tex: sourceTex
        property real radius: root.blur * 20
        property real grayAmt: root.gray
        property real boost: root.strength
        fragmentShader: Qt.resolvedUrl("../../../assets/shaders/glass.frag.qsb")
        property vector2d texel: Qt.vector2d(1.0 / Math.max(1, width), 1.0 / Math.max(1, height))
    }
}
