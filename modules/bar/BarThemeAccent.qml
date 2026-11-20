import QtQuick
import qs.modules.common

// 仅非 GFL 主题的 Bar 细节：不同游戏的识别线/扫描线/旧纸边。
Item {
    id: root
    anchors.fill: parent
    visible: Theme.arknights || Theme.bf4 || Theme.bf1

    // Arknights：上下青线 + 右侧斜切块
    Item {
        anchors.fill: parent
        visible: Theme.arknights
        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.alpha(Theme.accent, 0.5)
        }
        Rectangle {
            anchors.right: parent.right; anchors.rightMargin: Theme.px(8)
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(5); height: Theme.px(13)
            color: Theme.accent
            opacity: 0.8
        }
        Repeater {
            model: 7
            Rectangle {
                required property int index
                x: root.width * 0.62 + index * Theme.px(18)
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.px(1); height: root.height
                rotation: 22
                color: Theme.alpha(Theme.text, 0.06)
            }
        }
    }

    // BF4：橙色分段线 + 蓝色扫描线
    Item {
        anchors.fill: parent
        visible: Theme.bf4
        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right
            anchors.top: parent.top
            height: 2
            color: Theme.alpha(Theme.accent2, 0.85)
        }
        Repeater {
            model: 10
            Rectangle {
                required property int index
                anchors.top: parent.top
                x: root.width * 0.55 + index * Theme.px(26)
                width: Theme.px(14); height: 2
                color: index % 2 === 0 ? Theme.accent2 : "transparent"
            }
        }
        Rectangle {
            anchors.right: parent.right; anchors.rightMargin: Theme.px(10)
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(30); height: 1
            color: Theme.alpha(Theme.accent, 0.65)
        }
    }

    // BF1：黄铜双线 + 旧纸颗粒
    Item {
        anchors.fill: parent
        visible: Theme.bf1
        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.alpha(Theme.accent, 0.55)
        }
        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right
            anchors.bottom: parent.bottom; anchors.bottomMargin: 3
            height: 1
            color: Theme.alpha(Theme.accent, 0.22)
        }
        Rectangle {
            anchors.left: parent.left; anchors.leftMargin: Theme.px(18)
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.px(2); height: Theme.px(20)
            color: Theme.alpha(Theme.accent2, 0.6)
        }
    }
}
