import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// Calendar — 从时钟下拉的日程面板。
PanelWindow {
    id: root

    readonly property bool open: ShellState.overlay === "calendar"
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
    WlrLayershell.namespace: "gf-shell-calendar"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    function focusedScreen() {
        var name = Compositor.outputName;
        var list = Quickshell.screens;
        for (var i = 0; i < list.length; i++) {
            if (list[i].name === name)
                return list[i];
        }
        return list.length > 0 ? list[0] : null;
    }
    screen: focusedScreen()

    property date today: new Date()
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()

    readonly property var monthNames: ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
        "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
    readonly property var monthCN: ["一月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "十一月", "十二月"]
    readonly property var weekLabels: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    readonly property var days: {
        var first = new Date(root.viewYear, root.viewMonth, 1);
        var offset = (first.getDay() + 6) % 7;      // Monday-first
        var count = new Date(root.viewYear, root.viewMonth + 1, 0).getDate();
        var out = [];
        for (var i = 0; i < offset; i++)
            out.push({ day: 0, other: true });
        for (var d = 1; d <= count; d++)
            out.push({ day: d, other: false });
        while (out.length % 7 !== 0)
            out.push({ day: 0, other: true });
        while (out.length < 42)
            out.push({ day: 0, other: true });
        return out;
    }

    readonly property int todayIndex: {
        if (root.viewMonth !== root.today.getMonth() || root.viewYear !== root.today.getFullYear())
            return -1;
        var offset = (new Date(root.viewYear, root.viewMonth, 1).getDay() + 6) % 7;
        return offset + root.today.getDate() - 1;
    }

    function shiftMonth(delta) {
        var d = new Date(root.viewYear, root.viewMonth + delta, 1);
        root.viewYear = d.getFullYear();
        root.viewMonth = d.getMonth();
    }

    function weekNumber(date) {
        var t = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        var day = (t.getDay() + 6) % 7;
        t.setDate(t.getDate() - day + 3);
        var firstThursday = new Date(t.getFullYear(), 0, 4);
        var fday = (firstThursday.getDay() + 6) % 7;
        firstThursday.setDate(firstThursday.getDate() - fday + 3);
        return 1 + Math.round((t - firstThursday) / (7 * 86400000));
    }

    Item {
        anchors.fill: parent
        focus: root.open
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                ShellState.close();
                event.accepted = true;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.close()
        }
    }

    GfFrame {
        id: panel
        anchors.top: parent.top
        anchors.topMargin: Theme.barHeight + Theme.px(6)
        x: Math.max(Theme.px(8), (parent.width - width) / 2)
        width: Theme.px(320)
        height: content.implicitHeight + Theme.px(26)
        fill: Theme.alpha(Theme.panel, 0.98)
        borderColor: Theme.alpha(Theme.lineBright, 0.7)
        chamfer: Theme.px(10)
        padding: 0

        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: content
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.px(14)
            height: implicitHeight
            spacing: Theme.px(6)

            Item {
                width: parent.width
                height: Theme.px(28)

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: -2

                    GfText {
                        text: "SCHEDULE"
                        role: "display"
                        size: Theme.sizeMedium
                        tracking: 2.4
                        bold: true
                    }
                    GfText {
                        text: "行程"
                        role: "ui"
                        size: Theme.sizeTiny - 2
                        tone: "faint"
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.px(2)

                    GfIconButton {
                        icon: "chevron_left"
                        glyphSize: Theme.px(14)
                        buttonSize: Theme.px(20)
                        onClicked: root.shiftMonth(-1)
                    }
                    GfIconButton {
                        icon: "chevron_right"
                        glyphSize: Theme.px(14)
                        buttonSize: Theme.px(20)
                        onClicked: root.shiftMonth(1)
                    }
                }
            }

            Row {
                width: parent.width

                GfText {
                    text: root.monthNames[root.viewMonth] + " " + root.viewYear
                    role: "display"
                    size: Theme.sizeLarge
                    tracking: 2
                    bold: true
                    color: Theme.accentHi
                }

                Item { width: parent.width - 200; height: 1 }

                GfText {
                    anchors.baseline: parent.bottom
                    text: root.monthCN[root.viewMonth]
                    role: "ui"
                    size: Theme.sizeTiny
                    tone: "faint"
                }
            }

            GfDivider {
                width: parent.width
                color: Theme.alpha(Theme.lineBright, 0.35)
            }

            // 星期
            Row {
                width: parent.width
                Repeater {
                    model: root.weekLabels
                    delegate: GfText {
                        width: parent.width / 7
                        text: modelData
                        role: "mono"
                        size: Theme.sizeTiny - 2
                        color: index >= 5 ? Theme.alpha(Theme.red, 0.8) : Theme.textFaint
                        horizontalAlignment: Text.AlignHCenter
                        tracking: 0.5
                    }
                }
            }

            // 日期格
            Grid {
                width: parent.width
                columns: 7
                rowSpacing: Theme.px(1)
                columnSpacing: 0

                Repeater {
                    model: root.days

                    delegate: Item {
                        required property var modelData
                        required property int index

                        readonly property bool isToday: index === root.todayIndex
                        readonly property bool weekend: (index % 7) >= 5

                        width: parent.width / 7
                        height: Theme.px(24)

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1
                            color: parent.isToday ? Theme.alpha(Theme.accent, 0.22)
                                : (dayMouse.containsMouse && !modelData.other ? Theme.alpha(Theme.panelHi, 0.8) : "transparent")
                            border.width: parent.isToday ? 1 : 0
                            border.color: Theme.accent
                        }

                        GfText {
                            anchors.centerIn: parent
                            text: modelData.day === 0 ? "" : ("" + modelData.day)
                            role: "mono"
                            size: Theme.sizeTiny
                            color: parent.isToday ? Theme.accentHi
                                : (parent.weekend ? Theme.alpha(Theme.red, 0.75) : Theme.textDim)
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            hoverEnabled: !modelData.other
                        }
                    }
                }
            }

            GfDivider {
                width: parent.width
                color: Theme.alpha(Theme.lineBright, 0.25)
            }

            Row {
                width: parent.width

                GfText {
                    text: "WEEK " + Util.pad2(root.weekNumber(root.today))
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    color: Theme.accent
                    tracking: 1
                }

                Item { width: parent.width - 220; height: 1 }

                GfText {
                    text: Util.clockText(root.today, true, true) + "  ·  " + Util.weekday(root.today, false)
                    role: "mono"
                    size: Theme.sizeTiny - 1
                    tone: "faint"
                }
            }
        }
    }
}
