import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// CalendarCard — 月历内容（状态列弹出、侧边栏、独立日历共用）。
Item {
    id: root

    property date today: new Date()
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()
    property bool showHeader: true
    property int cellHeight: Theme.fpx(26)

    implicitHeight: layout.implicitHeight

    readonly property var monthNames: ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
        "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
    readonly property var monthCN: ["一月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "十一月", "十二月"]
    readonly property var weekLabels: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    readonly property var days: {
        var first = new Date(root.viewYear, root.viewMonth, 1);
        var offset = (first.getDay() + 6) % 7;
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

    Column {
        id: layout
        width: root.width
        spacing: Theme.fpx(6)

        // 标题
        Item {
            visible: root.showHeader
            width: parent.width
            height: Theme.fpx(26)

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
                    visible: I18n.locale !== "en"
                    text: I18n.t("calendar.schedule")
                    role: "ui"
                    size: Theme.sizeTiny - 2
                    tone: "faint"
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.fpx(2)

                GfIconButton {
                    icon: "chevron_left"
                    glyphSize: Theme.fpx(13)
                    buttonSize: Theme.fpx(20)
                    onClicked: root.shiftMonth(-1)
                }
                GfIconButton {
                    icon: "chevron_right"
                    glyphSize: Theme.fpx(13)
                    buttonSize: Theme.fpx(20)
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

            Item { width: parent.width - 190; height: 1 }

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
                }
            }
        }

        Grid {
            width: parent.width
            columns: 7
            rowSpacing: Theme.fpx(1)

            Repeater {
                model: root.days

                delegate: Item {
                    required property var modelData
                    required property int index

                    readonly property bool isToday: index === root.todayIndex
                    readonly property bool weekend: (index % 7) >= 5

                    width: parent.width / 7
                    height: root.cellHeight

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
                text: I18n.t("calendar.week") + " " + Util.pad2(root.weekNumber(root.today))
                role: "mono"
                size: Theme.sizeTiny - 1
                color: Theme.accent
                tracking: 1
            }

            Item { width: parent.width - 210; height: 1 }

            GfText {
                text: Util.clockText(root.today, true, true)
                role: "mono"
                size: Theme.sizeTiny - 1
                tone: "faint"
            }
        }
    }
}
