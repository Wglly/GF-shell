import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.modules.themes

// Overview — 作战地图。每个工作区是一张「战区卡」：
// 金色扇区缎带 + 单位列表；背景是暖炭底 + 半调网点 + 大地图水印。
PanelWindow {
    id: root

    readonly property bool open: ShellState.overlay === "overview"
    visible: root.open
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "gf-shell-overview"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property date now: new Date()
    property var moveId: null
    property var sectorCards: []
    property var draggableId: null
    property var dragEntry: null
    property bool dragging: false
    property bool dragJustFinished: false
    property point dragStart: Qt.point(0, 0)
    property point dragPoint: Qt.point(0, 0)
    property int hoverCard: -1

    readonly property bool compact: root.width < Theme.px(1000)
    readonly property int columns: root.compact ? 2
        : Math.max(2, Math.min(5, Settings.get("overview.columns", 4)))
    readonly property int sectors: Math.max(Compositor.workspaces.length,
        Math.min(root.compact ? 6 : 12, Settings.get("overview.desktops", 8)))
    readonly property real backdrop: Settings.get("overview.backdrop", 0.78)

    function windowsFor(id) {
        var out = [];
        var list = Compositor.windows;
        for (var i = 0; i < list.length; i++) {
            if (list[i].workspaceId === id)
                out.push(list[i]);
        }
        return out;
    }

    function updateHoverCard(x, y) {
        root.hoverCard = -1;
        for (var i = 0; i < root.sectorCards.length; i++) {
            var card = root.sectorCards[i];
            var p = card.mapFromItem(null, x, y);
            if (p.x >= 0 && p.y >= 0 && p.x <= card.width && p.y <= card.height) {
                root.hoverCard = card.wsId;
                return;
            }
        }
    }

    function finishDrag(x, y) {
        for (var i = 0; i < root.sectorCards.length; i++) {
            var card = root.sectorCards[i];
            var p = card.mapFromItem(null, x, y);
            if (p.x >= 0 && p.y >= 0 && p.x <= card.width && p.y <= card.height) {
                Compositor.moveWindow(root.draggableId, card.wsId);
                return;
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.open
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    // ---------------------------------------------------------------- 背景
    Rectangle {
        anchors.fill: parent
        color: Theme.bg1
    }

    ThemeMapBackground { anchors.fill: parent }

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../../assets/textures/halftone.png")
        fillMode: Image.Tile
        opacity: 0.35
    }

    Image {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: -Theme.px(80)
        width: Theme.px(620)
        height: Theme.px(620)
        source: Qt.resolvedUrl("../../assets/icons/emblem-accent.png")
        opacity: 0.045
        fillMode: Image.PreserveAspectFit
    }

    Item {
        id: shell
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                ShellState.close();
                event.accepted = true;
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: Theme.px(48)
            spacing: Theme.px(14)

            // ---------------------------------------------------------- header
            Item {
                width: parent.width
                height: Theme.px(62)

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: -Theme.px(2)

                    Row {
                        spacing: Theme.px(12)

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: Theme.px(5)
                            height: Theme.px(32)
                            color: Theme.accent
                        }

                        GfText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "OPERATION MAP"
                            role: "display"
                            size: Theme.sizeDisplay
                            tracking: 7
                            bold: true
                        }

                        GfText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.bottomMargin: -Theme.px(6)
                            text: I18n.t("overview.subtitle")
                            role: "ui"
                            size: Theme.sizeSmall
                            tone: "faint"
                            tracking: 4
                        }
                    }

                    GfText {
                        x: Theme.px(18)
                        text: "ALL UNITS   " + Compositor.windows.length + " ACTIVE   ·   "
                            + Compositor.backend.toUpperCase() + "   ·   SECTOR 09"
                        role: "mono"
                        size: Theme.sizeTiny
                        color: Theme.alpha(Theme.accent, 0.85)
                        tracking: 1.4
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.px(16)

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: -2
                        GfText {
                            text: Util.clockText(root.now, true, true)
                            role: "display"
                            size: Theme.sizeLarge
                            tracking: 2
                            bold: true
                            horizontalAlignment: Text.AlignRight
                        }
                        GfText {
                            text: Util.dateText(root.now, false)
                            role: "mono"
                            size: Theme.sizeTiny - 1
                            tone: "faint"
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    Rectangle {
                        width: 1
                        height: Theme.px(30)
                        color: Theme.alpha(Theme.accent, 0.4)
                    }

                    GfIconButton {
                        icon: "close"
                        glyphSize: Theme.px(18)
                        buttonSize: Theme.px(28)
                        danger: true
                        onClicked: ShellState.close()
                    }
                }
            }

            GfDivider {
                width: parent.width
                color: Theme.alpha(Theme.accent, 0.55)
            }

            // ------------------------------------------------------------ 网格
            Grid {
                id: grid
                width: parent.width
                height: parent.height - Theme.px(62) - Theme.px(14) - Theme.px(30) - Theme.px(14)
                columns: root.columns
                rowSpacing: Theme.px(10)
                columnSpacing: Theme.px(10)

                Repeater {
                    model: root.sectors

                    delegate: SectorCard {
                        required property int index
                        sectorIndex: index
                        width: (grid.width - (root.columns - 1) * grid.columnSpacing) / root.columns
                        height: (grid.height - (Math.ceil(root.sectors / root.columns) - 1) * grid.rowSpacing)
                            / Math.max(1, Math.ceil(root.sectors / root.columns))
                    }
                }
            }

            // ------------------------------------------------------------ 底部
            Row {
                width: parent.width
                spacing: Theme.px(14)

                GfKeyCap { label: "ESC" }
                GfText { visible: !root.compact; text: "CLOSE MAP"; role: "mono"; size: Theme.sizeTiny - 1; tone: "faint" }
                GfKeyCap { visible: !root.compact; label: "SUPER+ALT+TAB" }
                GfText { visible: !root.compact; text: "TOGGLE"; role: "mono"; size: Theme.sizeTiny - 1; tone: "faint" }
                GfKeyCap { label: "CLICK"; visible: !root.compact }
                GfText {
                    visible: !root.compact
                    text: root.moveId !== null
                        ? "MOVE MODE   ·   CLICK A SECTOR TO MOVE   ·   ESC CANCEL"
                        : "SECTOR → WORKSPACE   ·   UNIT → FOCUS   ·   DRAG / RIGHT-CLICK UNIT TO MOVE"
                    role: "mono"; size: Theme.sizeTiny - 1; tone: "faint"
                }

                Item { width: parent.width - 640; height: 1; visible: !root.compact }

                GfText {
                    visible: !root.compact
                    text: Util.opNumber("overview")
                    role: "mono"
                    size: Theme.sizeTiny
                    color: Theme.alpha(Theme.accent, 0.85)
                }
            }
        }
    }

    // 战区卡
    component SectorCard: GfFrame {
        id: card
        property int sectorIndex: 0

        readonly property var ws: Compositor.workspaces[sectorIndex] !== undefined
            ? Compositor.workspaces[sectorIndex] : null
        readonly property bool active: card.ws !== null && card.ws.active === true
        readonly property int wsId: card.ws !== null ? card.ws.id : (sectorIndex + 1)
        readonly property int sectorNumber: sectorIndex + 1
        readonly property var wins: root.windowsFor(card.wsId)

        Component.onCompleted: root.sectorCards.push(card)
        Component.onDestruction: {
            var i = root.sectorCards.indexOf(card);
            if (i >= 0)
                root.sectorCards.splice(i, 1);
        }

        fill: Theme.alpha(Theme.bg1, 0.92)
        borderColor: root.hoverCard === card.wsId ? Theme.accentHi
            : (card.active ? Theme.accentHi : Theme.alpha(Theme.accent, 0.32))
        strokeWidth: card.active ? 2 : 1
        chamfer: Theme.px(6)
        cutTopLeft: false
        cutTopRight: true
        cutBottomLeft: true
        cutBottomRight: false
        innerLine: true
        padding: 0
        hovered: sectorMouse.containsMouse

        MouseArea {
            id: sectorMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.moveId !== null) {
                    Compositor.moveWindow(root.moveId, card.wsId);
                    root.moveId = null;
                    return;
                }
                Compositor.focusWorkspace(card.ws !== null ? card.ws.id : card.sectorNumber);
                ShellState.close();
            }
        }

        // 顶部扇区带
        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: Theme.px(34)
            color: Theme.alpha(Theme.bg0, 0.82)

            Rectangle {
                x: 0
                y: 0
                width: card.active ? Theme.px(6) : Theme.px(3)
                height: parent.height
                color: Theme.accent
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.px(12)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.px(8)

                GfText {
                    text: "SECTOR " + Util.pad2(card.sectorNumber)
                    role: "display"
                    size: root.compact ? Theme.sizeSmall + 1 : Theme.sizeMedium + 2
                    tracking: 2.4
                    bold: true
                    color: card.active ? Theme.accentHi : Theme.text
                }

                Rectangle {
                    width: Theme.px(4)
                    height: Theme.px(4)
                    rotation: 45
                    anchors.verticalCenter: parent.verticalCenter
                    color: card.active ? Theme.accent : Theme.alpha(Theme.text, 0.3)
                }
            }

            GfText {
                anchors.right: parent.right
                anchors.rightMargin: Theme.px(10)
                anchors.verticalCenter: parent.verticalCenter
                text: card.active ? "CURRENT" : (card.wins.length > 0 ? card.wins.length + " UNITS" : "CLEAR")
                role: "mono"
                size: Theme.sizeTiny - 1
                color: card.active ? Theme.accent : Theme.textFaint
            }
        }

        Rectangle {
            x: 0
            y: Theme.px(34)
            width: parent.width
            height: 1
            color: Theme.alpha(Theme.accent, card.active ? 0.8 : 0.3)
        }

        // 单位列表
        Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.px(10)
            anchors.right: parent.right
            anchors.rightMargin: Theme.px(10)
            anchors.top: parent.top
            anchors.topMargin: Theme.px(42)
            spacing: Theme.px(3)

            Repeater {
                model: card.wins.slice(0, 5)

                delegate: Item {
                    id: winRow
                    required property var modelData
                    width: parent.width
                    height: Theme.px(28)
                    z: 10

                    Rectangle {
                        anchors.fill: parent
                        color: root.moveId === modelData.id ? Theme.alpha(Theme.accentHi, 0.22)
                            : (winMouse.containsMouse ? Theme.alpha(Theme.accent, 0.15) : "transparent")
                    }
                    Rectangle {
                        x: 0
                        y: Theme.px(6)
                        width: 2
                        height: parent.height - Theme.px(12)
                        color: Theme.alpha(Theme.accent2, 0.85)
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.px(8)
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.px(6)

                        GfText {
                            text: modelData.appId !== "" ? modelData.appId.toUpperCase() : "UNIT"
                            role: "mono"
                            size: Theme.sizeTiny - 2
                            color: Theme.alpha(Theme.accent, 0.75)
                            width: Theme.px(72)
                            elide: Text.ElideRight
                        }
                        GfText {
                            width: parent.width - Theme.px(80)
                            text: modelData.title
                            role: "ui"
                            size: Theme.sizeTiny
                            color: Theme.textDim
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: winMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.SizeAllCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onPressed: mouse => {
                            if (mouse.button !== Qt.LeftButton)
                                return;
                            var p = winRow.mapToItem(null, mouse.x, mouse.y);
                            root.dragStart = p;
                            root.dragPoint = p;
                            root.draggableId = modelData.id;
                            root.dragEntry = modelData;
                            root.dragging = false;
                        }
                        onPositionChanged: mouse => {
                            if (!pressed || root.draggableId !== modelData.id)
                                return;
                            var p = winRow.mapToItem(null, mouse.x, mouse.y);
                            if (!root.dragging) {
                                var dx = p.x - root.dragStart.x;
                                var dy = p.y - root.dragStart.y;
                                if (Math.sqrt(dx * dx + dy * dy) < 8)
                                    return;
                                root.dragging = true;
                            }
                            root.dragPoint = p;
                            root.updateHoverCard(p.x, p.y);
                        }
                        onReleased: mouse => {
                            if (root.dragging) {
                                var p = winRow.mapToItem(null, mouse.x, mouse.y);
                                root.finishDrag(p.x, p.y);
                                root.dragJustFinished = true;
                                dragGuard.restart();
                            }
                            root.dragging = false;
                            root.draggableId = null;
                            root.dragEntry = null;
                            root.hoverCard = -1;
                        }
                        onClicked: mouse => {
                            if (root.dragJustFinished)
                                return;
                            if (mouse.button === Qt.RightButton) {
                                root.moveId = modelData.id;
                                return;
                            }
                            Compositor.focusWindow(modelData.id);
                            ShellState.close();
                        }
                    }
                }
            }

            GfText {
                visible: card.wins.length > 5
                text: "+" + (card.wins.length - 5) + " MORE UNITS"
                role: "mono"
                size: Theme.sizeTiny - 2
                tone: "faint"
            }
        }

        // 空扇区状态（独立于列表，避免小尺寸时溢出）
        Item {
            visible: card.wins.length === 0
            anchors.fill: parent
            anchors.topMargin: Theme.px(40)
            anchors.bottomMargin: Theme.px(24)

            Column {
                anchors.centerIn: parent
                spacing: Theme.px(4)

                GfIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    name: "radar"
                    iconSize: Theme.px(22)
                    color: Theme.alpha(Theme.accent, 0.25)
                }
                GfText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SECTOR CLEAR"
                    role: "mono"
                    size: Theme.sizeTiny
                    color: Theme.textFaint
                    tracking: 1.4
                }
            }
        }

        // 底部坐标
        Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.px(10)
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.px(8)
            spacing: Theme.px(6)

            GfText {
                text: "GRID " + Util.pad2(card.sectorNumber) + "-" + Util.pad2(card.wins.length)
                role: "mono"
                size: Theme.sizeTiny - 3
                color: Theme.alpha(Theme.accent, 0.5)
            }
            GfText {
                text: "G&K"
                role: "mono"
                size: Theme.sizeTiny - 3
                tone: "faint"
            }
        }
    }

    Timer {
        id: dragGuard
        interval: 120
        onTriggered: root.dragJustFinished = false
    }

    GfFrame {
        visible: root.dragging && root.dragEntry !== null
        x: Math.min(root.width - width - Theme.px(8), root.dragPoint.x + Theme.px(12))
        y: Math.min(root.height - height - Theme.px(8), root.dragPoint.y + Theme.px(12))
        width: Theme.px(190)
        height: Theme.px(34)
        z: 200
        fill: Theme.alpha(Theme.bg0, 0.96)
        borderColor: Theme.accentHi
        chamfer: Theme.px(4)
        padding: 0

        GfText {
            anchors.centerIn: parent
            text: root.dragEntry ? root.dragEntry.title : ""
            role: "ui"; size: Theme.sizeTiny
            color: Theme.accentHi
            elide: Text.ElideRight
            width: parent.width - Theme.px(12)
            horizontalAlignment: Text.AlignHCenter
        }
    }

    onOpenChanged: {
        if (root.open)
            shell.forceActiveFocus();
    }
}
