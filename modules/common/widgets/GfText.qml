import QtQuick
import qs.modules.common

// GfText — 统一字体的文本原语。
//
// role: "ui" | "display" | "mono" | "label"；tone 决定颜色。
Text {
    id: root

    property string role: "ui"
    property string tone: "normal"       // normal | dim | faint | accent | accent2 | danger | ok | ink | cream
    property bool upper: false
    property bool bold: false
    property real tracking: 0
    property real size: Theme.sizeNormal
    property bool fitWidth: false

    textFormat: Text.PlainText
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
    font.family: role === "display" ? Theme.fontDisplay
        : (role === "mono" ? Theme.fontMono : (role === "label" ? Theme.fontLabel : Theme.fontUI))
    font.pixelSize: Math.round(root.size)
    font.weight: root.bold ? Font.Bold : (role === "display" ? Font.DemiBold : Font.Normal)
    font.letterSpacing: root.tracking
    font.hintingPreference: Font.PreferNoHinting
    color: {
        switch (root.tone) {
        case "dim": return Theme.textDim;
        case "faint": return Theme.textFaint;
        case "ghost": return Theme.textGhost;
        case "accent": return Theme.accent;
        case "gold": return Theme.accent;
        case "goldHi": return Theme.accentHi;
        case "steel": return Theme.accent2;
        case "accent2": return Theme.accent2;
        case "danger": return Theme.red;
        case "ok": return Theme.ok;
        case "ink": return Theme.ink;
        case "cream": return Theme.text;
        default: return Theme.text;
        }
    }
    opacity: root.enabled ? 1 : 0.4
    wrapMode: Text.NoWrap
}
