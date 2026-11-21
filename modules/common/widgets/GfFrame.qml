import QtQuick
import QtQuick.Shapes
import qs.modules.common

// GfFrame — 少女前线风格面板：
// 暖炭底 + 1px 金线 + 内侧细白线（双层框）+ 45° 小切角 + 可选金色顶线/左侧强调。
Item {
    id: root

    property color fill: Theme.light
        ? Theme.panel : Theme.alpha(Theme.panel, Theme.panelOpacity)
    readonly property color effectiveFill: Theme.light && root.applyPanelOpacity
        ? Qt.rgba(root.fill.r, root.fill.g, root.fill.b,
            root.fill.a * Math.max(0.0, Math.min(1.0, Theme.panelOpacity)))
        : root.fill
    property color borderColor: Theme.borderGold
    property color innerBorderColor: Theme.alpha(Theme.text, 0.10)
    property color accentColor: Theme.accent
    property color glowColor: Theme.accentHi
    property real chamfer: Theme.chamfer
    property bool cutTopLeft: true
    property bool cutTopRight: false
    property bool cutBottomRight: true
    property bool cutBottomLeft: false
    property int strokeWidth: 1
    property bool innerLine: true
    property bool accentTop: false
    property bool accentLeft: false
    property bool brackets: false
    property bool scanlines: false
    property bool hatch: false
    property bool hovered: false
    property int padding: Theme.pad
    property int radius: 0
    property real lineAlpha: 1.0
    property bool applyPanelOpacity: true
    readonly property int cornerRadius: root.radius > 0
        ? root.radius : (Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0)

    default property alias content: contentItem.data

    implicitWidth: Theme.px(280)
    implicitHeight: Theme.px(180)

    function buildPoints(w, h, c, inset) {
        var x0 = inset, y0 = inset, x1 = Math.max(inset, w - inset), y1 = Math.max(inset, h - inset);
        var cw = Math.max(0, Math.min(c, Math.min(w, h) / 2 - inset));
        var tl = root.cutTopLeft ? cw : 0;
        var tr = root.cutTopRight ? cw : 0;
        var br = root.cutBottomRight ? cw : 0;
        var bl = root.cutBottomLeft ? cw : 0;
        return [
            Qt.point(x0 + tl, y0), Qt.point(x1 - tr, y0),
            Qt.point(x1, y0 + tr), Qt.point(x1, y1 - br),
            Qt.point(x1 - br, y1), Qt.point(x0 + bl, y1),
            Qt.point(x0, y1 - bl), Qt.point(x0, y0 + tl)
        ];
    }

    readonly property var points: root.buildPoints(root.width, root.height, root.chamfer, 0)
    readonly property var innerPoints: root.buildPoints(root.width, root.height, root.chamfer, Theme.px(4))

    // BF1（或显式 radius）使用圆角矩形替代斜切 Shape。
    Rectangle {
        visible: root.cornerRadius > 0
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.effectiveFill
        border.width: root.strokeWidth
        border.color: Theme.lineColor(root.hovered ? Theme.accentHi : root.borderColor, root.lineAlpha)
    }
    Rectangle {
        visible: root.cornerRadius > Theme.px(6) && root.innerLine
        anchors.fill: parent
        anchors.margins: Theme.px(4)
        radius: Math.max(0, root.cornerRadius - Theme.px(4))
        color: "transparent"
        border.width: 1
        border.color: Theme.lineColor(root.hovered ? Theme.alpha(root.accentColor, 0.24) : root.innerBorderColor, root.lineAlpha)
    }

    Shape {
        visible: root.cornerRadius <= 0
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: root.strokeWidth
            strokeColor: Theme.lineColor(root.hovered ? Theme.accentHi : root.borderColor, root.lineAlpha)
            fillColor: root.effectiveFill
            PathPolyline { path: root.points }
            Behavior on strokeColor { ColorAnimation { duration: Theme.durFast } }
        }
    }

    // 内侧细线：少前面板的「双框」质感
    Shape {
        anchors.fill: parent
        visible: root.cornerRadius <= 0 && root.innerLine
            && root.width > Theme.px(14) && root.height > Theme.px(14)
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: 1
            strokeColor: Theme.lineColor(root.hovered ? Theme.alpha(root.accentColor, 0.28) : root.innerBorderColor, root.lineAlpha)
            fillColor: "transparent"
            PathPolyline { path: root.innerPoints }
        }
    }

    // HoI4 staff-paper double rule and top/bottom brass plates.
    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.px(6)
        visible: Theme.hoi4 && root.cornerRadius <= 0
        color: "transparent"
        border.width: 1
        border.color: Theme.lineColor(Theme.alpha(root.accentColor, 0.26), root.lineAlpha)
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        visible: Theme.hoi4
        width: Theme.px(42)
        height: Theme.px(2)
        color: Theme.lineColor(Theme.alpha(root.accentColor, 0.85), root.lineAlpha)
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        visible: Theme.hoi4
        width: Theme.px(28)
        height: 1
        color: Theme.lineColor(Theme.alpha(root.accentColor, 0.45), root.lineAlpha)
    }

    Image {
        anchors.fill: parent
        anchors.margins: 1
        visible: root.scanlines && Theme.scanlines
        source: Qt.resolvedUrl("../../../assets/textures/scanlines.png")
        fillMode: Image.Tile
        opacity: 0.4
    }

    Image {
        anchors.fill: parent
        anchors.margins: 1
        visible: root.hatch
        source: Qt.resolvedUrl("../../../assets/textures/hatch.png")
        fillMode: Image.Tile
        opacity: 0.5
    }

    // 顶部金线
    Rectangle {
        visible: root.accentTop && root.cornerRadius <= 0
        x: root.cutTopLeft ? root.chamfer + 4 : 0
        y: 0
        width: Math.max(0, root.width - x - (root.cutTopRight ? root.chamfer + 4 : 0))
        height: 1
        color: Theme.lineColor(Theme.alpha(root.accentColor, 0.9), root.lineAlpha)
    }

    // 左侧金色刻度块
    Rectangle {
        visible: root.accentLeft && root.cornerRadius <= 0
        x: 0
        y: root.cutTopLeft ? root.chamfer + 4 : 0
        width: 2
        height: Math.max(0, root.height - y - (root.cutBottomLeft ? root.chamfer + 4 : 0))
        color: Theme.lineColor(root.accentColor, root.lineAlpha)
    }

    GfCorners {
        anchors.fill: parent
        visible: root.brackets && root.cornerRadius <= 0
        color: Theme.lineColor(Theme.alpha(root.accentColor, 0.7), root.lineAlpha)
        size: Theme.px(9)
    }

    Item {
        id: contentItem
        clip: true
        anchors.fill: parent
        anchors.leftMargin: root.padding + (root.accentLeft ? 3 : 0)
        anchors.rightMargin: root.padding
        anchors.topMargin: root.padding
        anchors.bottomMargin: root.padding
    }
}
