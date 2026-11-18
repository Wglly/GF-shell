import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: Theme.px(5)

    GfText {
        text: I18n.t("sidebar.incomingLog")
        role: "mono"; size: Theme.sizeTiny - 1
        color: Theme.accent; tracking: 1.4
    }

    Repeater {
        model: Notifs.items.slice(0, 4)
        delegate: Column {
            required property var modelData
            width: parent.width
            spacing: 0
            GfText {
                width: parent.width
                text: (modelData.app || "G&K HQ") + "  //  " + modelData.summary
                role: "ui"; size: Theme.sizeTiny; color: Theme.textDim
                elide: Text.ElideRight
            }
            GfText {
                width: parent.width
                text: modelData.body || ""
                role: "mono"; size: Theme.sizeTiny - 1; tone: "faint"
                elide: Text.ElideRight; maximumLineCount: 1
            }
        }
    }

    GfText {
        visible: Notifs.items.length === 0
        text: I18n.t("sidebar.noTransmissions")
        role: "mono"; size: Theme.sizeTiny - 1; tone: "faint"
    }
}
