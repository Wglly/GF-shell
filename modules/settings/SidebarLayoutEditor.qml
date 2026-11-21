import QtQuick
import qs.modules.common
import qs.services

// SidebarLayoutEditor — same end-4pc drag board as the bar, for sidebar blocks.
Item {
    id: root

    property var entries: []
    readonly property var leftItems: SidebarLayout.items("left")
    readonly property var rightItems: SidebarLayout.items("right")
    readonly property var offItems: {
        var out = [];
        for (var i = 0; i < root.entries.length; i++) {
            var key = root.entries[i].key;
            if (root.leftItems.indexOf(key) < 0 && root.rightItems.indexOf(key) < 0)
                out.push(key);
        }
        return out;
    }

    property string dragKind: ""
    property bool dragging: false
    property point dragStart: Qt.point(0, 0)
    property point dragPos: Qt.point(0, 0)
    property string hoverSection: ""
    property string selectedKind: ""
    property bool suppressClick: false

    implicitHeight: Theme.fpx(330)

    function itemsFor(section) {
        if (section === "left") return root.leftItems;
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
        if (section === "right") return rightZone;
        return offZone;
    }

    function sectionAt(x, y) {
        var zones = [
            { section: "left", item: leftZone },
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
        SidebarLayout.move(key, section, index);
    }

    function moveSelected(section) {
        if (root.selectedKind === "")
            return;
        root.move(root.selectedKind, section, itemsFor(section).length);
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
        root.suppressClick = root.dragging;
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
        readonly property bool selected: root.selectedKind === chip.kind

        width: Math.max(Theme.fpx(82), labelItem.implicitWidth + Theme.fpx(20))
        height: Theme.fpx(28)
        opacity: root.dragging && root.dragKind === chip.kind ? 0.5 : 1

        Rectangle {
            anchors.fill: parent
            color: chip.selected ? Theme.sgAccent : (chip.hovered ? Theme.mix(Theme.sgAccent, Theme.sgGray, 0.35) : Theme.sgGray)
            border.width: chip.selected ? 2 : 1
            border.color: chip.selected ? Theme.sgInk : Theme.lineColor(Theme.sgInk)
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
            color: chip.selected || chip.hovered ? Theme.sgOnAccent : Theme.sgOnGray
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
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
            onClicked: {
                if (root.suppressClick) {
                    root.suppressClick = false;
                    return;
                }
                root.selectedKind = root.selectedKind === chip.kind ? "" : chip.kind;
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
                ? Theme.alpha(Theme.sgAccent, 0.14) : Theme.alpha(Theme.sgInk, 0.035)
            border.width: 1
            border.color: root.dragging && root.hoverSection === zone.section
                ? Theme.sgAccent : Theme.alpha(Theme.sgInk, 0.18)
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
                color: Theme.sgMute
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
            text: I18n.t("set.sidebarDragHint")
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(9)
            color: Theme.sgInk
            opacity: 0.72
        }

        Row {
            width: parent.width
            spacing: Theme.fpx(4)
            Text {
                width: Theme.fpx(220)
                anchors.verticalCenter: parent.verticalCenter
                text: root.selectedKind !== ""
                    ? I18n.t("set.barSelected") + " " + root.labelFor(root.selectedKind)
                    : I18n.t("set.barSelectHint")
                font.family: Theme.fontMono
                font.pixelSize: Theme.fs(8)
                color: Theme.sgInk
                elide: Text.ElideRight
            }
            SgButton {
                text: I18n.t("set.barZoneLeft")
                enabled: root.selectedKind !== ""
                onClicked: root.moveSelected("left")
            }
            SgButton {
                text: I18n.t("set.barZoneRight")
                enabled: root.selectedKind !== ""
                onClicked: root.moveSelected("right")
            }
            SgButton {
                text: "OFF"
                enabled: root.selectedKind !== ""
                onClicked: root.moveSelected("off")
            }
        }

        Row {
            width: parent.width
            spacing: Theme.fpx(6)
            Zone { id: leftZone; width: (parent.width - Theme.fpx(6)) / 2; section: "left"; title: I18n.t("set.barZoneLeft") }
            Zone { id: rightZone; width: (parent.width - Theme.fpx(6)) / 2; section: "right"; title: I18n.t("set.barZoneRight") }
        }

        Item {
            id: offZone
            width: parent.width
            height: Theme.fpx(86)
            Rectangle {
                anchors.fill: parent
                color: root.dragging && root.hoverSection === "off"
                    ? Theme.alpha(Theme.sgAccent, 0.12) : Theme.alpha(Theme.sgInk, 0.035)
                border.width: 1
                border.color: root.dragging && root.hoverSection === "off"
                    ? Theme.sgAccent : Theme.alpha(Theme.sgInk, 0.18)
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
                    color: Theme.sgMute
                }
                Flow {
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
        color: Theme.alpha(Theme.sgAccent, 0.95)
        border.width: 1
        border.color: Theme.sgInk
        radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
        Text {
            anchors.centerIn: parent
            text: root.labelFor(root.dragKind)
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(9)
            color: Theme.sgOnAccent
        }
    }
}
