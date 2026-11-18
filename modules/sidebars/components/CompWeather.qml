import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: Theme.px(4)

    GfText {
        text: I18n.t("hud.weather")
        role: "mono"; size: Theme.sizeTiny - 1
        color: Theme.accent; tracking: 1.4
    }

    Row {
        width: parent.width
        spacing: Theme.px(8)

        WeatherIcon {
            anchors.verticalCenter: parent.verticalCenter
            kind: Weather.iconName
            color: Theme.accent
            implicitWidth: Theme.px(38)
        }
        Column {
            spacing: -3
            GfText {
                text: Weather.ok ? Math.round(Weather.tempC) + "°" : "--°"
                role: "display"; size: Theme.sizeTitle; bold: true
            }
            GfText {
                text: Weather.ok
                    ? I18n.t("hud." + (Weather.iconName === "sun" ? "clear"
                        : (Weather.iconName === "cloud" ? "cloudy" : Weather.iconName)))
                    : I18n.t("hud.noData")
                role: "mono"; size: Theme.sizeTiny - 1
                color: Theme.alpha(Theme.accent, 0.85)
            }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            GfText {
                text: Weather.ok ? "H " + Weather.maxC + "°  L " + Weather.minC + "°" : ""
                role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
            }
            GfText {
                text: Weather.ok ? "HUM " + Weather.humidity + "%  WIND " + Weather.windKmph : ""
                role: "mono"; size: Theme.sizeTiny - 2; tone: "faint"
            }
        }
    }
    GfText {
        text: Weather.ok && Weather.location !== "" ? Weather.location.toUpperCase() : ""
        role: "mono"; size: Theme.sizeTiny - 3
        color: Theme.alpha(Theme.accent, 0.5)
    }
}
