import QtQuick
import qs.modules.common
import qs.modules.common.widgets

// SetChoice — 分段选择器（设置里的枚举项）。
Row {
    id: root

    property var options: []          // [{ value, label }]
    property string value: ""
    signal picked(string value)

    spacing: Theme.fpx(2)

    Repeater {
        model: root.options

        delegate: GfButton {
            required property var modelData
            text: modelData.label
            compact: true
            checked: root.value === modelData.value
            onClicked: root.picked(modelData.value)
        }
    }
}
