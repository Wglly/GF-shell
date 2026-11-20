import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// Wallpaper — 每屏一张：暖炭底 + 金色细框 + 半调网点 + 角落读数。
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: Theme.bg0
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "gf-shell-wallpaper"

    Image {
        id: paper
        anchors.fill: parent
        source: Wallpapers.source
        fillMode: Settings.get("wallpaper.fillMode", "fill") === "fit" ? Image.PreserveAspectFit
            : (Settings.get("wallpaper.fillMode", "fill") === "stretch" ? Image.Stretch : Image.PreserveAspectCrop)
        asynchronous: true
        cache: true
        smooth: true
        opacity: Settings.get("wallpaper.enabled", true) ? 1 : 0

        Behavior on opacity {
            enabled: Theme.animations
            NumberAnimation { duration: Theme.durSlow }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Settings.get("wallpaper.color", Theme.bg0)
        opacity: Settings.get("wallpaper.enabled", true) ? 0 : 1
    }

    readonly property bool darkSurfaces: (Theme.bg0.r * 0.299 + Theme.bg0.g * 0.587 + Theme.bg0.b * 0.114) <= 0.55

    // 压暗（暖黑；亮色主题不染色）
    Rectangle {
        anchors.fill: parent
        visible: root.darkSurfaces
        color: Theme.alpha(Theme.bg0, Settings.get("wallpaper.dim", 0.06))
    }

    // 顶部渐隐：给 bar 一个稳定底色
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: root.darkSurfaces
        height: Theme.px(120)
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.alpha(Theme.bg0, 0.82) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // 底部渐隐：给 dock 一个稳定底色
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        visible: root.darkSurfaces
        height: Theme.px(150)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.alpha(Theme.bg0, 0.7) }
        }
    }

    // 半调网点（很淡，补齐壁纸没有覆盖到的区域）
    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../../assets/textures/halftone.png")
        fillMode: Image.Tile
        opacity: 0.25
    }

    // 噪点
    Image {
        anchors.fill: parent
        visible: Theme.grain
        source: Qt.resolvedUrl("../../assets/textures/noise.png")
        fillMode: Image.Tile
        opacity: 0.22
    }

    // 左上：编号
    GfText {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: Theme.px(30)
        text: "G&K  //  SECTOR 09"
        role: "mono"
        size: Theme.sizeTiny
        color: Theme.alpha(Theme.accent, 0.5)
        tracking: 2
    }

    // 右下：屏幕与壁纸名
    GfText {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.px(30)
        text: (root.modelData ? root.modelData.name : "") + "   ·   " + Wallpapers.currentName
        role: "mono"
        size: Theme.sizeTiny
        color: Theme.alpha(Theme.text, 0.25)
        tracking: 1.4
    }
}
