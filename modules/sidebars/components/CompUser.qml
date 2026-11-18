import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Column {
    id: root
    width: parent ? parent.width : Theme.px(320)
    spacing: Theme.px(6)
    UserCard { id: userCard; width: parent.width; compact: true; showActions: true }
}
