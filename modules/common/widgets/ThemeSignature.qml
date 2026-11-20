import QtQuick
import qs.modules.common

// ThemeSignature — 只对非 GFL 主题生效的桌面签名层：
// Arknights 的工业网格/斜切，BF4 的蓝色部署网格，BF1 的旧纸/烟尘。
Item {
    id: root
    anchors.fill: parent
    visible: Theme.arknights || Theme.bf4 || Theme.bf1

    // ---------------------------------------------------------- Arknights
    Item {
        anchors.fill: parent
        visible: Theme.arknights
        opacity: 0.9

        Repeater {
            model: 24
            Rectangle {
                required property int index
                x: root.width * (index / 24) - root.height * 0.25
                y: -root.height * 0.25
                width: 1
                height: root.height * 1.5
                rotation: 28
                color: Theme.alpha(Theme.accent, index % 4 === 0 ? 0.16 : 0.055)
            }
        }
        Repeater {
            model: 10
            Rectangle {
                required property int index
                x: root.width * index / 10
                y: 0
                width: 1
                height: root.height
                color: Theme.alpha(Theme.text, 0.035)
            }
        }
        Repeater {
            model: 7
            Rectangle {
                required property int index
                x: 0
                y: root.height * index / 7
                width: root.width
                height: 1
                color: Theme.alpha(Theme.text, 0.028)
            }
        }

        // 四角工业框
        Repeater {
            model: 4
            Item {
                required property int index
                readonly property bool isLeft: index % 2 === 0
                readonly property bool isTop: index < 2
                x: isLeft ? Theme.px(26) : root.width - Theme.px(90)
                y: isTop ? Theme.px(64) : root.height - Theme.px(68)
                width: Theme.px(64)
                height: Theme.px(18)
                Rectangle { width: parent.width; height: 1; color: Theme.accent; opacity: 0.72 }
                Rectangle { width: 1; height: Theme.px(12); color: Theme.accent; opacity: 0.72 }
            }
        }

        // 中央菱形与准星
        Item {
            anchors.centerIn: parent
            width: Theme.px(320); height: Theme.px(320)
            opacity: 0.22
            Rectangle {
                anchors.centerIn: parent
                width: Theme.px(210); height: Theme.px(210)
                rotation: 45
                color: "transparent"
                border.width: 1
                border.color: Theme.accent
            }
            Rectangle {
                anchors.centerIn: parent
                width: Theme.px(160); height: 1
                color: Theme.accent
            }
            Rectangle {
                anchors.centerIn: parent
                width: 1; height: Theme.px(160)
                color: Theme.accent
            }
        }

        Text {
            x: Theme.px(42); y: Theme.px(36)
            text: "RHODES ISLAND  //  LOGISTICS DIVISION"
            font.family: Theme.fontMono
            font.pixelSize: Theme.fs(10)
            font.letterSpacing: 2
            color: Theme.accent
            opacity: 0.78
        }
        Text {
            x: Theme.px(42); y: Theme.px(52)
            text: "ORIGINIUM CONTAINMENT  ·  SECTOR 09  ·  LINK STABLE"
            font.family: Theme.fontMono
            font.pixelSize: Theme.fs(8)
            color: Theme.textDim
            opacity: 0.55
        }
        Text {
            anchors.right: parent.right; anchors.rightMargin: Theme.px(46)
            anchors.bottom: parent.bottom; anchors.bottomMargin: Theme.px(62)
            text: "//  KEEP MOVING FORWARD"
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fs(30)
            font.letterSpacing: 3
            color: Theme.text
            opacity: 0.11
        }
    }

    // ---------------------------------------------------------------- BF4
    Item {
        anchors.fill: parent
        visible: Theme.bf4

        Repeater {
            model: 26
            Rectangle {
                required property int index
                x: root.width * index / 26
                y: 0
                width: 1
                height: root.height
                color: Theme.alpha(Theme.accent, index % 5 === 0 ? 0.11 : 0.035)
            }
        }
        Repeater {
            model: 12
            Rectangle {
                required property int index
                x: 0
                y: root.height * index / 12
                width: root.width
                height: 1
                color: Theme.alpha(Theme.accent, index % 4 === 0 ? 0.12 : 0.035)
            }
        }
        Repeater {
            model: 7
            Rectangle {
                required property int index
                x: 0
                y: Theme.px(90) + index * Theme.px(110)
                width: root.width
                height: 1
                color: Theme.alpha(Theme.accent, 0.055)
            }
        }

        // 橙色的任务菱角与扫描弧
        Item {
            anchors.centerIn: parent
            width: Theme.px(520); height: Theme.px(520)
            opacity: 0.38
            Rectangle {
                anchors.centerIn: parent
                width: Theme.px(330); height: Theme.px(330)
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: Theme.alpha(Theme.accent, 0.42)
            }
            Rectangle {
                anchors.centerIn: parent
                width: Theme.px(230); height: Theme.px(230)
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: Theme.alpha(Theme.accent2, 0.42)
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height / 2 - height / 2
                width: Theme.px(300); height: 1
                color: Theme.alpha(Theme.accent2, 0.6)
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: parent.width / 2 - width / 2
                width: 1; height: Theme.px(300)
                color: Theme.alpha(Theme.accent2, 0.6)
            }
        }

        // 顶部行动信息
        Row {
            x: Theme.px(42); y: Theme.px(36)
            spacing: Theme.px(14)
            Rectangle { width: Theme.px(4); height: Theme.px(30); color: Theme.accent2 }
            Column {
                spacing: 1
                Text {
                    text: "US // COMBINED ARMS  ·  DEPLOYMENT UPLINK"
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fs(18)
                    font.letterSpacing: 2.4
                    color: Theme.text
                }
                Text {
                    text: "SECTOR 09   ·   SIEGE OF SHANGHAI   ·   CHANNEL 4"
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fs(8)
                    color: Theme.accent
                }
            }
        }
        Text {
            anchors.right: parent.right; anchors.rightMargin: Theme.px(44)
            anchors.top: parent.top; anchors.topMargin: Theme.px(38)
            text: "M-COM  //  A  B  C"
            font.family: Theme.fontMono
            font.pixelSize: Theme.fs(9)
            color: Theme.alpha(Theme.accent2, 0.8)
        }
        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: Theme.px(220)
            text: "SPAWN  BEACON  ACTIVE"
            font.family: Theme.fontMono
            font.pixelSize: Theme.fs(9)
            font.letterSpacing: 1.8
            color: Theme.alpha(Theme.accent, 0.45)
        }
    }

    // ---------------------------------------------------------------- BF1
    Item {
        anchors.fill: parent
        visible: Theme.bf1

        // 旧纸/烟尘：径向暖色叠层
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.alpha("#2a2014", 0.22) }
                GradientStop { position: 0.55; color: "transparent" }
                GradientStop { position: 1.0; color: Theme.alpha("#1b130b", 0.45) }
            }
        }
        Repeater {
            model: 6
            Rectangle {
                required property int index
                x: root.width * (0.08 + index * 0.17)
                y: root.height * (0.18 + (index % 3) * 0.22)
                width: root.width * (0.18 + (index % 2) * 0.09)
                height: width
                radius: width / 2
                color: Theme.alpha("#d8c39a", 0.025 + index * 0.004)
            }
        }
        Image {
            anchors.fill: parent
            source: Qt.resolvedUrl("../../../assets/textures/halftone.png")
            fillMode: Image.Tile
            opacity: 0.08
        }

        // 黄铜双线框
        Rectangle {
            anchors.fill: parent; anchors.margins: Theme.px(24)
            color: "transparent"
            border.width: 1
            border.color: Theme.alpha(Theme.accent, 0.24)
        }
        Rectangle {
            anchors.fill: parent; anchors.margins: Theme.px(30)
            color: "transparent"
            border.width: 1
            border.color: Theme.alpha(Theme.accent, 0.12)
        }

        Text {
            x: Theme.px(44); y: Theme.px(38)
            text: "THE GREAT WAR  //  1918"
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fs(23)
            font.letterSpacing: 4
            color: Theme.alpha(Theme.accentHi, 0.8)
        }
        Text {
            x: Theme.px(46); y: Theme.px(68)
            text: "FIELD ORDER  ·  WESTERN FRONT  ·  ARTILLERY SUPPORT"
            font.family: Theme.fontMono
            font.pixelSize: Theme.fs(8)
            color: Theme.textDim
            opacity: 0.55
        }
        Text {
            anchors.right: parent.right; anchors.rightMargin: Theme.px(46)
            anchors.bottom: parent.bottom; anchors.bottomMargin: Theme.px(48)
            text: "//  OVER THE TOP"
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fs(36)
            font.letterSpacing: 5
            color: Theme.alpha(Theme.accentHi, 0.1)
        }
    }
}
