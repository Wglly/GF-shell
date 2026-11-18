pragma Singleton
import QtQuick

// ShellState.qml — 全局界面状态机：同一时间只有一个覆盖层可见。
QtObject {
    id: state

    // "none" | "launcher" | "control" | "overview" | "power" | "settings" | "calendar" | "media"
    property string overlay: "none"
    // 覆盖层是否为全屏接管（隐藏 bar 的焦点提示）
    readonly property bool modal: overlay !== "none"

    signal opened(string name)
    signal closed(string name)

    function open(name) {
        if (state.overlay === name)
            return;
        state.popupKind = "";
        state.sidebarLeft = false;
        state.sidebarRight = false;
        var prev = state.overlay;
        state.overlay = name;
        if (prev !== "none")
            state.closed(prev);
        if (name !== "none")
            state.opened(name);
    }

    function close() {
        state.open("none");
    }

    function toggle(name) {
        state.open(state.overlay === name ? "none" : name);
    }

    // 设置窗口的一级分页（见 SettingsWindow.tabs）
    property int settingsTab: 0

    // 搜索框的初始文本（快捷键触发时带上当前选中的窗口标题等）
    property string searchSeed: ""

    // 桌面小工具是否可见
    property bool widgetsVisible: true

    // 相册/壁纸选择器
    property string wallpaperScope: "local"

    // 覆盖层关闭动画结束后再卸载，避免闪烁
    property bool overlayBusy: false

    // 电源菜单里被选中的动作
    property int powerIndex: 0

    // OSD 的临时状态："volume" | "brightness" | ""
    property string osdKind: ""
    property real osdValue: 0
    property string osdLabel: ""
    property Timer osdTimer: Timer {
        interval: 1600
        onTriggered: {
            state.osdKind = "";
        }
    }

    function flashOsd(kind, value, label) {
        state.osdKind = kind;
        state.osdValue = value;
        state.osdLabel = label || "";
        state.osdTimer.restart();
    }

    // 状态列弹出：跟随点击位置
    property string popupKind: ""       // "" | "user" | "calendar" | "media"
    property real popupAnchorX: 0
    property real popupAnchorY: 0
    property string popupScreen: ""

    function openPopup(kind, x, y, screenName) {
        state.popupScreen = screenName || state.popupScreen;
        state.popupAnchorX = x;
        state.popupAnchorY = y;
        state.popupKind = kind;
        state.sidebarLeft = false;
        state.sidebarRight = false;
    }

    function closePopup() {
        state.popupKind = "";
    }

    function togglePopup(kind, x, y, screenName) {
        if (state.popupKind === kind) {
            state.closePopup();
            return;
        }
        state.openPopup(kind, x, y, screenName);
    }

    // 左右侧边栏
    property bool sidebarLeft: false
    property bool sidebarRight: false

    function toggleSidebar(side) {
        state.closePopup();
        if (side === "left")
            state.sidebarLeft = !state.sidebarLeft;
        else
            state.sidebarRight = !state.sidebarRight;
    }

    function closeSidebars() {
        state.sidebarLeft = false;
        state.sidebarRight = false;
    }

    // 通知中心里当前选中的通知键
    property int notifFocus: 0
}
