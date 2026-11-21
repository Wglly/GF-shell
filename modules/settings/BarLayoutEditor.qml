import QtQuick
import "SgStyle.js" as Sg
import qs.modules.common
import qs.services

// BarLayoutEditor — end-4pc style bar module board.
// All existing bar kinds are chips; drag between LEFT/CENTER/RIGHT or OFF.
Item {
    id: root

    property var entries: []
    readonly property var leftItems: Settings.get("bar.left", [])
    readonly property var centerItems: Settings.get("bar.center", ["clock"])
    readonly property var rightItems: Settings.get("bar.right", [])
    readonly property var offItems: {
        var out = [];
        for (var i = 0; i < root.entries.length; i++) {
            var key = root.entries[i].key;
            if (root.leftItems.indexOf(key) < 0 && root.centerItems.indexOf(key) < 0
                    && root.rightItems.indexOf(key) < 0)
                out.push(key);
        }
        return out;
    }

    property string dragKind: ""
    property bool dragging: false
    property point dragStart: Qt.point(0, 0)
    property point dragPos: Qt.point(0, 0)
    property string hoverSection: ""

    implicitHeight: Theme.fpx(360)

    function itemsFor(section) {
        if (section === "left") return root.leftItems;
        if (section === "center") return root.centerItems;
        if (section === "right") return root.rightItems;
        return root.offItems;
    }

    function labelFor(key) {
        for (var i = 0; i < root.entries.length; i++)
            if (root.entries[i].key === key)
                return I18n.t(root.entries[i].labelKey);
        return key;
    }

    function zoneFor(section) {
        if (section === "left") return leftZone;
        if (section === "center") return centerZone;
        if (section === "right") return rightZone;
        return offZone;
    }

    function sectionAt(x, y) {
        var zones = [
            { section: "left", item: leftZone },
            { section: "center", item: centerZone },
            { section: "right", item: rightZone },
            { section: "off", item: offZone }
        ];
        for (var i = 0; i < zones.length; i++) {
            var p = zones[i].item.mapFromItem(null, x, y);
            if (p.x >= 0 && p.y >= 0 && p.x <= zones[i].item.width && p.y <= zones[i].item.height)
                return zones[i].section;
        }
        return "";
    }

    function dropIndex(section, x, y) {
        if (section === "off")
            return 0;
        var zone = zoneFor(section);
        var p = zone.row.mapFromItem(null, x, y);
        var children = zone.row.children;
        var idx = 0;
        for (var i = 0; i < children.length; i++) {
            var child = children[i];
            if (child.width <= 0)
                continue;
            if (p.y > child.y + child.height) {
                idx = i + 1;
            } else if (p.y >= child.y) {
                if (p.x > child.x + child.width / 2)
                    idx = i + 1;
                break;
            } else {
                break;
            }
        }
        return idx;
    }

    function move(key, section, index) {
        if (!key)
            return;
        var sections = ["left", "center", "right"];
        var current = {};
        for (var i = 0; i < sections.length; i++)
            current[sections[i]] = (Settings.get("bar." + sections[i], []) || []).slice();
        for (var s = 0; s < sections.length; s++) {
            var pos = current[sections[s]].indexOf(key);
            if (pos >= 0)
                current[sections[s]].splice(pos, 1);
        }
        if (section !== "off") {
            var target = current[section];
            var at = Math.max(0, Math.min(target.length, index === undefined ? target.length : index));
            target.splice(at, 0, key);
        }
        for (var k = 0; k < sections.length; k++)
            Settings.set("bar." + sections[k], current[sections[k]]);
    }

    function startDrag(kind, x, y) {
        root.dragKind = kind;
        root.dragging = false;
        root.dragStart = Qt.point(x, y);
        root.dragPos = Qt.point(x, y);
        root.hoverSection = "";
    }

    function updateDrag(x, y) {
        if (root.dragKind === "")
            return;
        if (!root.dragging) {
            var dx = x - root.dragStart.x;
            var dy = y - root.dragStart.y;
            if (Math.sqrt(dx * dx + dy * dy) < Theme.fpx(6))
                return;
            root.dragging = true;
        }
        root.dragPos = Qt.point(x, y);
        root.hoverSection = root.sectionAt(x, y);
    }

    function endDrag(x, y) {
        if (root.dragging) {
            var section = root.sectionAt(x, y);
            if (section !== "")
                root.move(root.dragKind, section, root.dropIndex(section, x, y));
        }
        root.dragKind = "";
        root.dragging = false;
        root.hoverSection = "";
    }

    component Chip: Item {
        id: chip
        property string kind: ""
        readonly property string label: root.labelFor(chip.kind)
        readonly property bool hovered: mouse.containsMouse

        width: Math.max(Theme.fpx(76), labelItem.implicitWidth + Theme.fpx(20))
        height: Theme.fpx(28)
        opacity: root.dragging && root.dragKind === chip.kind ? 0.5 : 1

        Rectangle {
            anchors.fill: parent
            color: chip.hovered ? Sg.yellow : Sg.gray
            border.width: 1
            border.color: Theme.lineColor(Sg.ink)
            radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
        }
        Text {
            id: labelItem
            anchors.centerIn: parent
            width: parent.width - Theme.fpx(10)
            text: chip.label
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(9)
            font.bold: true
            color: chip.hovered ? Sg.ink : Sg.paper
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeAllCursor
            onPressed: mouse => {
                var p = chip.mapToItem(null, mouse.x, mouse.y);
                root.startDrag(chip.kind, p.x, p.y);
            }
            onPositionChanged: mouse => {
                if (!pressed)
                    return;
                var p = chip.mapToItem(null, mouse.x, mouse.y);
                root.updateDrag(p.x, p.y);
            }
            onReleased: mouse => {
                var p = chip.mapToItem(null, mouse.x, mouse.y);
                root.endDrag(p.x, p.y);
            }
        }
    }

    component Zone: Item {
        id: zone
        property string section: "left"
        property string title: ""
        readonly property var zoneItems: root.itemsFor(zone.section)
        property alias row: zoneRow
        height: Theme.fpx(154)

        Rectangle {
            anchors.fill: parent
            color: root.dragging && root.hoverSection === zone.section
                ? Theme.alpha(Sg.yellow, 0.14) : Theme.alpha(Sg.ink, 0.035)
            border.width: 1
            border.color: root.dragging && root.hoverSection === zone.section
                ? Sg.yellow : Theme.alpha(Sg.ink, 0.18)
            radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
        }
        Column {
            anchors.fill: parent
            anchors.margins: Theme.fpx(6)
            spacing: Theme.fpx(4)
            Text {
                text: zone.title
                font.family: Theme.fontMono
                font.pixelSize: Theme.fs(8)
                font.letterSpacing: 1.1
                color: Sg.mute
            }
            Flow {
                id: zoneRow
                width: parent.width
                spacing: Theme.fpx(4)
                Repeater {
                    model: zone.zoneItems
                    delegate: Chip {
                        required property string modelData
                        kind: modelData
                    }
                }
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: Theme.fpx(7)

        Text {
            text: I18n.t("set.barDragHint")
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(9)
            color: Sg.ink
            opacity: 0.72
        }

        Row {
            width: parent.width
            spacing: Theme.fpx(6)
            Zone { id: leftZone; width: (parent.width - Theme.fpx(12)) / 3; section: "left"; title: I18n.t("set.barZoneLeft") }
            Zone { id: centerZone; width: (parent.width - Theme.fpx(12)) / 3; section: "center"; title: I18n.t("set.barZoneCenter") }
            Zone { id: rightZone; width: (parent.width - Theme.fpx(12)) / 3; section: "right"; title: I18n.t("set.barZoneRight") }
        }

        Item {
            id: offZone
            width: parent.width
            height: Theme.fpx(104)
            Rectangle {
                anchors.fill: parent
                color: root.dragging && root.hoverSection === "off"
                    ? Theme.alpha(Sg.yellow, 0.12) : Theme.alpha(Sg.ink, 0.035)
                border.width: 1
                border.color: root.dragging && root.hoverSection === "off"
                    ? Sg.yellow : Theme.alpha(Sg.ink, 0.18)
                radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
            }
            Column {
                anchors.fill: parent
                anchors.margins: Theme.fpx(6)
                spacing: Theme.fpx(4)
                Text {
                    text: I18n.t("set.barZoneOff")
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fs(8)
                    color: Sg.mute
                }
                Flow {
                    id: offRow
                    width: parent.width
                    spacing: Theme.fpx(4)
                    Repeater {
                        model: root.offItems
                        delegate: Chip {
                            required property string modelData
                            kind: modelData
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        visible: root.dragging
        z: 100
        x: Math.min(root.width - width - 4, root.dragPos.x + Theme.fpx(8))
        y: Math.min(root.height - height - 4, root.dragPos.y + Theme.fpx(8))
        width: Theme.fpx(110)
        height: Theme.fpx(28)
        color: Theme.alpha(Sg.yellow, 0.95)
        border.width: 1
        border.color: Sg.ink
        radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
        Text {
            anchors.centerIn: parent
            text: root.labelFor(root.dragKind)
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(9)
            color: Sg.ink
        }
    }
}
