import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

// WallpaperCard — built-in + imported directory wallpapers.
Item {
    id: root

    readonly property var list: Wallpapers.all

    implicitHeight: column.implicitHeight

    Component.onCompleted: Wallpapers.refresh()

    function thumbFor(w) {
        return w.path.indexOf("file://") === 0 ? w.path : "file://" + w.path;
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.fpx(8)

        Row {
            width: parent.width
            GfText {
                text: "WALLPAPER LIBRARY"
                role: "mono"; size: Theme.sizeTiny - 2
                color: Theme.accent; tracking: 1.4
            }
            Item { width: parent.width - Theme.fpx(190); height: 1 }
            GfText {
                text: root.list.length + " FILES"
                role: "mono"; size: Theme.sizeTiny - 3; tone: "faint"
            }
        }

        GfText {
            width: parent.width
            text: Wallpapers.directory !== "" ? Wallpapers.directory : "No directory imported — add one in Settings → Wallpapers"
            role: "mono"; size: Theme.sizeTiny - 2
            color: Theme.textFaint
            elide: Text.ElideMiddle
        }

        Flickable {
            id: scroller
            width: parent.width
            height: Theme.fpx(330)
            clip: true
            contentWidth: width
            contentHeight: grid.height
            boundsBehavior: Flickable.StopAtBounds

            WheelHandler {
                onWheel: wheel => {
                    var dy = (wheel.angleDelta.y / 120) * Theme.fpx(86);
                    scroller.contentY = Math.max(0, Math.min(scroller.contentHeight - scroller.height, scroller.contentY - dy));
                    wheel.accepted = true;
                }
            }

            Grid {
                id: grid
                width: scroller.width
                columns: 3
                spacing: Theme.fpx(6)

                Repeater {
                    model: root.list

                    delegate: Item {
                        required property var modelData
                        readonly property bool active: Wallpapers.selected === modelData.path
                        width: (grid.width - Theme.fpx(12)) / 3
                        height: Theme.fpx(74)

                        Rectangle {
                            anchors.fill: parent
                            color: active ? Theme.accent : Theme.alpha(Theme.accent, 0.3)
                        }
                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            source: root.thumbFor(modelData)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: Theme.fpx(16)
                            color: Theme.alpha(Theme.bg0, 0.82)
                        }
                        GfText {
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: Theme.fpx(3)
                            width: parent.width - 8
                            text: modelData.name
                            role: "mono"; size: Theme.sizeTiny - 4
                            color: active ? Theme.accentHi : Theme.text
                            elide: Text.ElideRight
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Wallpapers.choosePath(modelData.path)
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width
            spacing: Theme.fpx(6)
            GfButton {
                height: Theme.fpx(26); compact: true
                text: "RANDOM"
                onClicked: Wallpapers.randomise()
            }
            GfButton {
                height: Theme.fpx(26); compact: true
                text: "REFRESH"
                onClicked: Wallpapers.refresh()
            }
        }
    }
}
