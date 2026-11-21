import QtQuick
import "SgStyle.js" as Sg
import qs.modules.common
import qs.services

// BarLayoutEditor — end-4pc style bar module board:
// drag chips between LEFT / CENTER / RIGHT, or into OFF to hide.
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

    implicitHeight: Theme.fpx(236)
    clip: false

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

    function move(key, section, index) {
        if (!key)
            return;
        var list = ["left", "center", "right"];
        var current = {};
        for (var i = 0; i < list.length; i++)
            current[list[i]] = (Settings.get("bar." + list[i], []) || []).slice();
        for (var s = 0; s < list.length; s++) {
            var arr = current[list[s]];
            var pos = arr.indexOf(key);
            if (pos >= 0)
                arr.splice(pos, 1);
        }
        if (section !== "off") {
            var target = current[section];
            var at = Math.max(0, Math.min(target.length, index === undefined ? target.length : index));
            target.splice(at, 0, key);
        }
        for (var k = 0; k < list.length; k++)
            Settings.set("bar." + list[k], current[list[k]]);
    }


    component Chip: Item {
        id: chip
        property string kind: ""
        property string section: "off"
        readonly property string label: root.labelFor(chip.kind)
        readonly property bool hovered: mouse.containsMouse

        width: Math.max(Theme.fpx(74), labelItem.implicitWidth + Theme.fpx(20))
        height: Theme.fpx(28)
        opacity: mouse.drag.active ? 0.55 : 1

        Rectangle {
            anchors.fill: parent
            color: chip.hovered ? Sg.yellow : Sg.gray
            border.width: 1
            border.color: Sg.ink
            radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
        }
        Text {
            id: labelItem
            anchors.centerIn: parent
            text: chip.label
            font.family: Theme.fontUI
            font.pixelSize: Theme.fs(9)
            font.bold: true
            color: chip.hovered ? Sg.ink : Sg.paper
            elide: Text.ElideRight
            width: parent.width - Theme.fpx(10)
            horizontalAlignment: Text.AlignHCenter
        }

        Item { id: dragProxy; width: 1; height: 1; visible: false }

        Drag.active: mouse.drag.active
        Drag.hotSpot.x: Theme.fpx(12)
        Drag.hotSpot.y: Theme.fpx(12)
        Drag.keys: ["text/plain"]
        Drag.mimeData: ({ "text/plain": chip.kind })

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeAllCursor
            drag.target: dragProxy
            drag.threshold: Theme.fpx(6)
        }
    }

    component Zone: Item {
        id: zone
        property string section: "left"
        property string title: ""
        height: Theme.fpx(82)
        readonly property var zoneItems: root.itemsFor(zone.section)

        function indexAt(x) {
            var localX = x - zoneRow.x;
            var idx = 0;
            for (var i = 0; i < zoneRow.children.length; i++) {
                var child = zoneRow.children[i];
                if (child.width <= 0)
                    continue;
                if (localX > child.x + child.width / 2)
                    idx++;
            }
            return idx;
        }

        Column {
            anchors.fill: parent
            spacing: Theme.fpx(4)
            Text {
                text: zone.title
                font.family: Theme.fontMono
                font.pixelSize: Theme.fs(8)
                font.letterSpacing: 1.2
                color: Sg.mute
            }
            Item {
                width: parent.width
                height: Theme.fpx(38)
                Rectangle {
                    anchors.fill: parent
                    color: drop.containsDrag ? Theme.alpha(Sg.yellow, 0.16) : "transparent"
                    border.width: 1
                    border.color: drop.containsDrag ? Sg.yellow : Theme.alpha(Sg.ink, 0.18)
                    radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
                }
                Row {
                    id: zoneRow
                    x: Theme.fpx(5)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.fpx(4)
                    Repeater {
                        model: zone.zoneItems
                        delegate: Chip {
                            required property string modelData
                            kind: modelData
                            section: zone.section
                        }
                    }
                }
                DropArea {
                    id: drop
                    anchors.fill: parent
                    keys: ["text/plain"]
                    onDropped: d => {
                        var key = d.getData("text/plain");
                        if (!key) key = d.text;
                        root.move(key, zone.section, zone.indexAt(d.x));
                        d.acceptProposedAction();
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
            opacity: 0.7
        }

        Row {
            width: parent.width
            spacing: Theme.fpx(6)
            Zone {
                width: (parent.width - Theme.fpx(12)) / 3
                section: "left"; title: I18n.t("set.barZoneLeft")
            }
            Zone {
                width: (parent.width - Theme.fpx(12)) / 3
                section: "center"; title: I18n.t("set.barZoneCenter")
            }
            Zone {
                width: (parent.width - Theme.fpx(12)) / 3
                section: "right"; title: I18n.t("set.barZoneRight")
            }
        }

        Item {
            width: parent.width
            height: Theme.fpx(66)
            Rectangle {
                anchors.fill: parent
                color: offDrop.containsDrag ? Theme.alpha(Sg.yellow, 0.12) : Theme.alpha(Sg.ink, 0.04)
                border.width: 1
                border.color: Theme.alpha(Sg.ink, 0.18)
                radius: Theme.bf1 ? Theme.px(Theme.bf1Radius) : 0
            }
            Column {
                x: Theme.fpx(6); width: parent.width - Theme.fpx(12)
                spacing: Theme.fpx(3)
                Text {
                    text: I18n.t("set.barZoneOff")
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fs(8)
                    color: Sg.mute
                }
                Flow {
                    width: parent.width
                    spacing: Theme.fpx(4)
                    Repeater {
                        model: root.offItems
                        delegate: Chip {
                            required property string modelData
                            kind: modelData
                            section: "off"
                        }
                    }
                }
            }
            DropArea {
                id: offDrop
                anchors.fill: parent
                keys: ["text/plain"]
                onDropped: d => {
                    var key = d.getData("text/plain");
                    if (!key) key = d.text;
                    root.move(key, "off", 0);
                    d.acceptProposedAction();
                }
            }
        }
    }
}
