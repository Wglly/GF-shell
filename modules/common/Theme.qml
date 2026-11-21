pragma Singleton
import QtQuick

// Theme.qml — GF-shell 的唯一视觉真理来源。
//
// 设计语言取自《少女前线》的战术界面（参考游戏内编成/基地/作战界面）：
// 近黑的暖炭底、哑光金作为选中与边框主色、纸白正文、钢蓝数据、红色警戒数字；
// 45° 小切角、1px 金线 + 内侧细白线的双层框、斜切标签缎带。
QtObject {
    id: theme

    // ------------------------------------------------------------------ 字体
    property string fontUI: "Chakra Petch"          // 常规界面文字
    property string fontDisplay: "Saira Condensed"  // 大标题 / 数字（窄体）
    property string fontMono: "Share Tech Mono"     // 数据、编号
    property string fontLabel: "Rajdhani"           // 小号大写标签
    property string fontCJK: "Noto Sans CJK SC"

    // ------------------------------------------------------------------ 缩放
    property real uiScale: 1.0
    property real fontScale: 1.0
    property real widgetScale: 1.0

    function px(v) {
        return Math.max(1, Math.round(v * theme.uiScale));
    }
    // Layout metrics that follow the font scale (for popups / cards).
    function fpx(v) {
        return Math.max(1, Math.round(v * theme.uiScale * theme.fontScale));
    }

    function fs(v) {
        return Math.max(6, Math.round(v * theme.uiScale * theme.fontScale * 10) / 10);
    }

    property int sizeTiny: fs(9)
    property int sizeSmall: fs(10)
    property int sizeNormal: fs(12)
    property int sizeMedium: fs(14)
    property int sizeLarge: fs(17)
    property int sizeTitle: fs(22)
    property int sizeDisplay: fs(34)
    property real track: 1.4        // 标签字距
    property real trackWide: 2.6    // 大标题字距

    // ------------------------------------------------------------------ 色板
    // 底色：暖炭黑，不是冷蓝黑 —— 少前界面在暖色美术上叠黑色 UI。
    property color bg0: "#070708"
    property color bg1: "#0d0d0f"
    property color bg: "#0a0a0c"
    property color panel: "#141416"
    property color panelAlt: "#1a1a1d"
    property color panelHi: "#24242a"
    property color line: "#403a2e"          // 暖灰棕
    property color lineSoft: "#252420"
    property color lineBright: "#c9a24a"    // 金线

    // 金色是主强调色；钢蓝色是「基地/数据」类界面的副色。
    property color accent: "#e8bd4f"
    property color accentHi: "#ffd977"
    property color accentDim: "#7d6428"
    property color accent2: "#6f9bc4"       // steel blue
    property color red: "#d34a34"
    property color warn: "#e0a33a"
    property color ok: "#8fc08a"
    property color ink: "#12100c"           // 铺在金色上的文字

    property color text: "#f2eee3"          // 纸白
    property color textDim: "#b9b1a1"
    property color textFaint: "#7d7668"
    property color textGhost: "#4a463d"

    // 便捷别名（GFL 语义）
    readonly property color gold: accent
    readonly property color goldHi: accentHi
    readonly property color goldDim: accentDim
    readonly property color steel: accent2
    readonly property color paper: text
    readonly property color borderGold: Qt.rgba(accent.r, accent.g, accent.b, 0.55)
    readonly property color borderWhite: "#33f2eee3"

    // 面板透明度
    property real panelOpacity: 0.95
    property real overlayDim: 0.62

    // ------------------------------------------------------------------ 几何
    property int barHeight: px(38)
    property int chamfer: px(6)             // 小切角
    property int chamferSmall: px(3)
    property int notch: px(10)              // 缎带/标签的斜切
    property int border: 1
    property int gap: px(8)
    property int pad: px(12)
    property int radius: 0
    property int iconSize: px(16)

    // ------------------------------------------------------------------ 特效
    property string preset: "gfl"
    property bool light: false
    property int bf1Radius: 12
    readonly property bool arknights: preset === "arknights"
    readonly property bool bf4: preset === "bf4"
    readonly property bool bf1: preset === "bf1"
    readonly property bool hoi4: preset === "hoi4"
    readonly property bool battle: bf4 || bf1
    readonly property string themeTitle: arknights ? "RHODES ISLAND"
        : (bf4 ? "BATTLEFIELD 4" : (bf1 ? "BATTLEFIELD 1"
        : (hoi4 ? "HEARTS OF IRON IV" : "GRIFFIN & KRYUGER")))
    readonly property string dashboardTitle: arknights ? "RHODES DASHBOARD"
        : (bf4 ? "COMMANDER DASHBOARD" : (bf1 ? "FIELD DASHBOARD"
        : (hoi4 ? "NATIONAL SITUATION REPORT" : "TACTICAL DASHBOARD")))
    property bool scanlines: false          // 少前没有 CRT 扫描线，默认关
    property bool grain: true
    property bool brackets: true
    property bool animations: true
    property real animSpeed: 1.0
    property real lineOpacity: 1.0

    function dur(ms) {
        return Math.max(1, Math.round(ms / Math.max(0.1, theme.animSpeed)));
    }

    readonly property int durFast: dur(100)
    readonly property int durNormal: dur(170)
    readonly property int durSlow: dur(300)

    // ------------------------------------------------------------- 调色助手
    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function lineColor(c, scale) {
        var k = scale === undefined ? 1.0 : scale;
        return Qt.rgba(c.r, c.g, c.b, c.a * theme.lineOpacity * k);
    }

    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t,
                       a.g + (b.g - a.g) * t,
                       a.b + (b.b - a.b) * t,
                       a.a + (b.a - a.a) * t);
    }

    function shade(c, f) {
        return f < 0 ? theme.mix(c, Qt.rgba(0, 0, 0, c.a), -f)
                     : theme.mix(c, Qt.rgba(1, 1, 1, c.a), f);
    }

    function ticks(n) {
        var out = [];
        for (var i = 0; i < n; i++)
            out.push(i);
        return out;
    }
}
