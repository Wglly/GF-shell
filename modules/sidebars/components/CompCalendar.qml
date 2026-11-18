import QtQuick
import qs.modules.common
import qs.services
import qs.modules.common.widgets

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: Theme.px(4)

    GfText {
        id: title
        text: I18n.t("calendar.schedule")
        role: "mono"; size: Theme.sizeTiny - 1
        color: Theme.accent; tracking: 1.4
    }
    CalendarCard {
        id: cal
        width: parent.width
        cellHeight: Theme.px(23)
        showHeader: false
    }
}
