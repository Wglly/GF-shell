//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
//@ pragma Env QT_LOGGING_RULES=qt.text.font.db.info=false

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.wallpaper
import qs.modules.bar
import qs.modules.launcher
import qs.modules.control
import qs.modules.overview
import qs.modules.dashboard
import qs.modules.command
import qs.modules.power
import qs.modules.osd
import qs.modules.notifications
import qs.modules.dock
import qs.modules.widgets
import qs.modules.settings
import qs.modules.sidebars
import qs.services

// GF-shell — 少女前线风格的 Quickshell 桌面外壳（Hyprland / niri）。
ShellRoot {
    id: shell

    // ------------------------------------------------------------- 字体注册
    // 随附字体保证任何机器上渲染一致；失败则回退到系统同名字体。
    FontLoader { id: fontChakra; source: Qt.resolvedUrl("assets/fonts/ChakraPetch-Regular.ttf") }
    FontLoader { id: fontChakraMedium; source: Qt.resolvedUrl("assets/fonts/ChakraPetch-Medium.ttf") }
    FontLoader { id: fontChakraSemi; source: Qt.resolvedUrl("assets/fonts/ChakraPetch-SemiBold.ttf") }
    FontLoader { id: fontChakraBold; source: Qt.resolvedUrl("assets/fonts/ChakraPetch-Bold.ttf") }
    FontLoader { id: fontSaira; source: Qt.resolvedUrl("assets/fonts/SairaCondensed-SemiBold.ttf") }
    FontLoader { id: fontSairaBold; source: Qt.resolvedUrl("assets/fonts/SairaCondensed-Bold.ttf") }
    FontLoader { id: fontMono; source: Qt.resolvedUrl("assets/fonts/ShareTechMono-Regular.ttf") }
    FontLoader { id: fontRajdhani; source: Qt.resolvedUrl("assets/fonts/Rajdhani-Medium.ttf") }
    FontLoader { id: fontRajdhaniBold; source: Qt.resolvedUrl("assets/fonts/Rajdhani-Bold.ttf") }
    FontLoader { id: fontIcons; source: Qt.resolvedUrl("assets/fonts/GFTacticalIcons.ttf") }

    // --------------------------------------------------------- 主题令牌绑定
    Binding { target: Theme; property: "preset"; value: Settings.get("theme.preset", "gfl") }
    Binding { target: Theme; property: "fontUI"; value: Settings.get("fonts.ui", "") !== "" ? Settings.get("fonts.ui", "") : "Chakra Petch" }
    Binding { target: Theme; property: "fontDisplay"; value: Settings.get("fonts.display", "") !== "" ? Settings.get("fonts.display", "") : "Saira Condensed" }
    Binding { target: Theme; property: "fontMono"; value: Settings.get("fonts.mono", "") !== "" ? Settings.get("fonts.mono", "") : "Share Tech Mono" }
    Binding { target: Theme; property: "fontLabel"; value: Settings.get("fonts.label", "") !== "" ? Settings.get("fonts.label", "") : "Rajdhani" }
    Binding { target: Theme; property: "light"; value: Settings.get("theme.mode", "dark") === "light" }
    Binding { target: Theme; property: "bf1Radius"; value: Settings.get("theme.bf1Radius", 12) }
    Binding { target: Theme; property: "accent"; value: Settings.get("theme.accent", "#d8aa4b") }
    Binding { target: Theme; property: "accent2"; value: Settings.get("theme.accent2", "#87a0b2") }
    Binding { target: Theme; property: "scanlines"; value: Settings.get("theme.scanlines", true) }
    Binding { target: Theme; property: "brackets"; value: Settings.get("theme.brackets", true) }
    Binding { target: Theme; property: "panelOpacity"; value: Settings.get("theme.panelOpacity", 0.94) }
    Binding { target: Theme; property: "uiScale"; value: Settings.get("theme.scale", 1.0) }
    Binding { target: Theme; property: "fontScale"; value: Settings.get("theme.fontScale", 1.0) }
    Binding { target: Theme; property: "animations"; value: Settings.get("theme.animations", true) }
    Binding { target: Theme; property: "animSpeed"; value: Settings.get("theme.animSpeed", 1.0) }
    Binding { target: Theme; property: "lineOpacity"; value: Settings.get("theme.lineOpacity", 1.0) }

    // 主题预设写入的完整色板
    Binding { target: Theme; property: "bg0"; value: Settings.get("theme.bg0", "#151513") }
    Binding { target: Theme; property: "bg1"; value: Settings.get("theme.bg1", "#1d1d1a") }
    Binding { target: Theme; property: "bg"; value: Settings.get("theme.bg", "#191917") }
    Binding { target: Theme; property: "textFaint"; value: Settings.get("theme.textFaint", "#857f73") }
    Binding { target: Theme; property: "textGhost"; value: Settings.get("theme.textGhost", "#514d45") }
    Binding { target: Theme; property: "ink"; value: Settings.get("theme.ink", "#181611") }
    Binding { target: Theme; property: "accentHi"; value: Settings.get("theme.accentHi", "#f0cf7a") }
    Binding { target: Theme; property: "accentDim"; value: Settings.get("theme.accentDim", "#7a6127") }
    Binding { target: Theme; property: "panel"; value: Settings.get("theme.panel", "#242421") }
    Binding { target: Theme; property: "panelAlt"; value: Settings.get("theme.panelAlt", "#2d2d29") }
    Binding { target: Theme; property: "panelHi"; value: Settings.get("theme.panelHi", "#3a3a34") }
    Binding { target: Theme; property: "line"; value: Settings.get("theme.line", "#46443c") }
    Binding { target: Theme; property: "lineBright"; value: Settings.get("theme.lineBright", "#c8a24c") }
    Binding { target: Theme; property: "text"; value: Settings.get("theme.text", "#f2efe6") }
    Binding { target: Theme; property: "textDim"; value: Settings.get("theme.textDim", "#bcb5a8") }

    // --------------------------------------------------------------- 快捷键
    GlobalShortcut {
        appid: "gf-shell"
        name: "launcher"
        description: "GF-shell: 部署终端 (launcher)"
        onPressedChanged: if (pressed) ShellState.toggle("launcher")
    }

    GlobalShortcut {
        appid: "gf-shell"
        name: "overview"
        description: "GF-shell: 作战地图 (overview)"
        onPressedChanged: if (pressed) ShellState.toggle("overview")
    }

    GlobalShortcut {
        appid: "gf-shell"
        name: "control"
        description: "GF-shell: 战术控制中心"
        onPressedChanged: if (pressed) ShellState.toggle("control")
    }

    GlobalShortcut {
        appid: "gf-shell"
        name: "power"
        description: "GF-shell: 系统停机菜单"
        onPressedChanged: if (pressed) ShellState.toggle("power")
    }

    GlobalShortcut {
        appid: "gf-shell"
        name: "widgets"
        description: "GF-shell: 桌面组件布局编辑"
        onPressedChanged: if (pressed) ShellState.toggleWidgetsEditing()
    }

    GlobalShortcut {
        appid: "gf-shell"
        name: "screenshot"
        description: "GF-shell: 截图"
        onPressedChanged: if (pressed) Capture.screenshot()
    }

    // ------------------------------------------------------------- 每屏一份
    Variants {
        model: Quickshell.screens

        delegate: Wallpaper {}
    }

    Variants {
        model: Quickshell.screens

        delegate: Bar {}
    }

    Variants {
        model: Quickshell.screens

        delegate: DesktopHud {}
    }

    Variants {
        model: Quickshell.screens

        delegate: CommandRose {}
    }

    Variants {
        model: Quickshell.screens

        delegate: Dock {}
    }

    Variants {
        model: Quickshell.screens

        delegate: BarPopup {}
    }

    Variants {
        model: Quickshell.screens
        delegate: SidebarTrigger { side: "left" }
    }
    Variants {
        model: Quickshell.screens
        delegate: SidebarPanel { side: "left" }
    }
    Variants {
        model: Quickshell.screens
        delegate: SidebarTrigger { side: "right" }
    }
    Variants {
        model: Quickshell.screens
        delegate: SidebarPanel { side: "right" }
    }

    Launcher {}
    ControlCenter {}
    Overview {}
    Dashboard {}
    PowerMenu {}
    Osd {}
    Toasts {}
    SettingsWindow {}

    // 时钟下拉的日历（属于 bar，但需要独立窗口）
    Calendar {
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    }

    // 供合成器快捷键 / 脚本调用：qs -p ~/.config/quickshell/gf-shell ipc call shell open launcher
    IpcHandler {
        target: "shell"

        function open(overlay: string): void {
            ShellState.open(overlay);
        }

        function toggle(overlay: string): void {
            ShellState.toggle(overlay);
        }



        function close(): void {
            ShellState.close();
        }

































        function widgets(): void {
            ShellState.toggleWidgetsEditing();
        }




        function volume(v: real): void {
            Audio.setVolume(v);
        }

        function mute(): void {
            Audio.toggleMute();
        }


        function status(): string {
            return "overlay=" + ShellState.overlay + " popup=" + ShellState.popupKind
                + " backend=" + Compositor.backend
                + " workspaces=" + Compositor.workspaces.length;
        }
    }

    Loader {
        active: Quickshell.env("GF_DEBUG") === "gauge"
        source: "modules/debug/GaugeTest.qml"
    }

    Loader {
        active: Quickshell.env("GF_DEBUG") === "icons"
        source: "modules/debug/IconGrid.qml"
    }

    Component.onCompleted: {
        // 首次运行时把默认壁纸写进配置
        if (Settings.get("wallpaper.path", "") === "")
            Settings.set("wallpaper.path", Wallpapers.folder + Wallpapers.builtin[0].file);

        // 调试用：GF_OVERLAY=launcher qs -p ... 直接打开某个覆盖层
        var initial = Quickshell.env("GF_OVERLAY") || "";
        if (initial !== "")
            ShellState.open(initial);

        var tabEnv = Quickshell.env("GF_TAB") || "";
        if (tabEnv !== "")
            ShellState.settingsTab = parseInt(tabEnv) || 0;

        var dbg = Quickshell.env("GF_DEBUG") || "";
        if (dbg === "osd") {
            ShellState.osdKind = "volume";
            ShellState.osdValue = 0.62;
        }
        else if (dbg === "toast") {
            Notifs.items = Notifs.items.concat([{
                key: 9901,
                at: Date.now() + 100000,
                app: "G&K HQ",
                summary: "新的作戰指令",
                body: "梯隊 404 已就位，請至作戰地圖確認部署座標。",
                icon: "",
                node: null
            }]);
        }
        else if (dbg === "popup-user")
            ShellState.openPopup("user", 300, 38, "");
        else if (dbg === "popup-calendar")
            ShellState.openPopup("calendar", 960, 38, "");
        else if (dbg === "popup-media")
            ShellState.openPopup("media", 1500, 38, "");
        else if (dbg === "sidebar-left")
            ShellState.sidebarLeft = true;
        else if (dbg === "sidebar-right")
            ShellState.sidebarRight = true;
        else if (dbg === "light")
            Settings.applyPreset("light");
        else if (dbg === "dark")
            Settings.applyPreset("gfl");
        else if (dbg === "widgets")
            ShellState.widgetsEditing = true;
        else if (dbg === "osd-bright") {
            ShellState.osdKind = "brightness";
            ShellState.osdValue = 0.78;
        }
    }
}
