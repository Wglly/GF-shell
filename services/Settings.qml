pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Settings.qml — GF-shell 的持久化配置。
//
// 存放于 ~/.config/gf-shell/config.json。组件读取 Settings.data.<group>.<key>，
// 写入用 Settings.set("group.key", value)（250ms 防抖保存）。
QtObject {
    id: root

    readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/gf-shell"
    property string path: ""
    property var data: root.defaults()
    property bool loaded: false
    property bool dirty: false

    function defaults() {
        return {
            version: 8,
            language: "auto",            // auto | zh_TW | zh_CN | en | ja
            bar: {
                position: "top",         // top | bottom
                visible: true,
                thickness: 38,
                autoHide: false,
                clock24h: true,
                showSeconds: false,
                titleMode: "window",     // window | mission
                opacity: 0.94,
                gray: 0.0,
                blur: 0.0,
                size: 1.0,
                left: ["launcher", "user", "workspaces", "title"],
                center: ["clock"],
                right: ["media", "wallpaper", "stats", "net", "bluetooth", "volume", "battery", "tray", "overview", "control", "power"]
            },
            dock: {
                enabled: true,
                position: "bottom",
                align: "center",          // center | left | right
                autoHide: false,
                iconSize: 44,
                opacity: 0.94,
                gray: 0.0,
                blur: 0.0,
                size: 1.0,
                avoid: true,
                trigger: 24,
                maxItems: 12,
                pinned: ["firefox.desktop", "kitty.desktop", "foot.desktop",
                         "org.gnome.Nautilus.desktop", "code.desktop", "steam.desktop"]
            },
            launcher: {
                columns: 6,
                showCategories: true,
                showDetail: true,
                width: 1040,
                height: 640
            },
            theme: {
                preset: "gfl",           // gfl | sangvis | neural | arctic | light
                mode: "dark",            // dark | light | custom
                bg0: "#070708",
                bg1: "#0d0d0f",
                bg: "#0a0a0c",
                textFaint: "#7d7668",
                textGhost: "#4a463d",
                ink: "#12100c",
                accentHi: "#ffd977",
                accentDim: "#7d6428",
                fontScale: 1.0,
                bf1Radius: 12,
                settingsOpacity: 0.9,
                settingsGray: 0.22,
                accent: "#e8bd4f",
                accent2: "#6f9bc4",
                panel: "#141416",
                panelAlt: "#1a1a1d",
                panelHi: "#24242a",
                line: "#403a2e",
                lineBright: "#c9a24a",
                text: "#f2eee3",
                textDim: "#b9b1a1",
                scanlines: false,
                brackets: true,
                panelOpacity: 0.95,
                scale: 1.0,
                animations: true
            },
            wallpaper: {
                enabled: true,
                path: "",                // 空 = 使用内置壁纸
                fillMode: "fill",        // fill | fit | stretch
                dim: 0.06,
                color: "#080b0e"
            },
            widgets: {
                grid: 48,
                clock: { enabled: true, x: 0.045, y: 0.10, showDate: true, showSeconds: true },
                stats: { enabled: true, x: 0.045, y: 0.42 },
                media: { enabled: true, x: 0.72, y: 0.10 },
                calendar: { enabled: false, x: 0.72, y: 0.42 },
                weather: { enabled: true, x: 0.045, y: 0.72 },
                visualizer: { enabled: false, x: 0.72, y: 0.42 },
                user: { enabled: true, x: 0.72, y: 0.60 },
                mission: { enabled: true, x: 0.72, y: 0.86 }
            },
            sidebar: {
                left: {
                    enabled: true, width: 356, height: 0.82, align: "top",
                    opacity: 0.94, gray: 0.0, blur: 0.0,
                    autoHide: true, delay: 650, trigger: 12, triggerWidth: 180, triggerPosition: "top"
                },
                right: {
                    enabled: true, width: 372, height: 0.88, align: "top",
                    opacity: 0.94, gray: 0.0, blur: 0.0,
                    autoHide: true, delay: 650, trigger: 12, triggerWidth: 180, triggerPosition: "top"
                },
                assign: {
                    user: "left", calendar: "left", roster: "left", actions: "left",
                    weather: "left", stats: "right", mission: "right",
                    media: "right", visualizer: "right", comms: "right", clock: "off", wallpaper: "right"
                }
            },
            osd: {
                enabled: true,
                position: "center"       // center | bottom
            },
            overview: {
                columns: 4,
                desktops: 8,
                backdrop: 0.78,
                showWindows: true
            },
            power: {
                confirm: true
            },
            terminal: {
                command: ""
            },
            notifications: {
                dnd: false,
                toasts: true,
                maxToasts: 4,
                position: "top-right"
            },
            hotkeys: {
                launcher: "SUPER+Space",
                overview: "SUPER+Tab",
                control: "SUPER+Shift+C"
            },
            shell: {
                keepAwake: false,
                dockPinnedInitialised: false
            }
        };
    }

    // FileView 的 text 在不同 Quickshell 版本里可能是方法也可能是属性。
    function readText() {
        var v = cfg.text;
        if (typeof v === "function")
            return v.call(cfg) || "";
        return v || "";
    }

    // ------------------------------------------------------------- 主题预设
    readonly property var presets: ({
        gfl: {
            name: "G&K STANDARD",
            accent: "#e8bd4f", accent2: "#6f9bc4",
            panel: "#141416", panelAlt: "#1a1a1d", panelHi: "#24242a",
            line: "#403a2e", lineBright: "#c9a24a",
            text: "#f2eee3", textDim: "#b9b1a1",
            scanlines: false, brackets: true
        },
        sangvis: {
            name: "SANGVIS FERRI",
            accent: "#d34a34", accent2: "#cfcabf",
            panel: "#171314", panelAlt: "#1e1819", panelHi: "#2a2021",
            line: "#4a332e", lineBright: "#8a4a3e",
            text: "#f3ece6", textDim: "#b8a9a1",
            scanlines: false, brackets: true
        },
        neural: {
            name: "NEURAL CLOUD",
            accent: "#7eb2d6", accent2: "#a98ce0",
            panel: "#10151a", panelAlt: "#151c23", panelHi: "#1e2831",
            line: "#2f4150", lineBright: "#4e7590",
            text: "#e9eef4", textDim: "#9fb0bf",
            scanlines: false, brackets: true
        },
        light: {
            name: "DAYLIGHT OPS",
            mode: "light",
            accent: "#b07d18", accent2: "#4f7fa3",
            accentHi: "#d9a62a", accentDim: "#7a5a12",
            bg0: "#f3f0e7", bg1: "#eae6db", bg: "#efebe2",
            panel: "#fbf9f3", panelAlt: "#f2efe7", panelHi: "#e4dfd2",
            line: "#c9c1af", lineBright: "#a8842f",
            text: "#1b1813", textDim: "#5c5648", textFaint: "#8b8373", textGhost: "#b2ab9c",
            ink: "#15120c",
            scanlines: false, brackets: true
        },
        arctic: {
            name: "ARCTIC OPS",
            accent: "#cbb98a", accent2: "#9cb6c8",
            panel: "#131517", panelAlt: "#191c1f", panelHi: "#23282c",
            line: "#3a3f45", lineBright: "#6e7d88",
            text: "#f0f2f4", textDim: "#aab4bc",
            scanlines: false, brackets: false
        },
        arknights: {
            name: "RHODES ISLAND",
            accent: "#3fd4e6", accentHi: "#a9f7ff", accentDim: "#1d6d78",
            accent2: "#e7e9e6",
            bg0: "#080b0c", bg1: "#101516", bg: "#0b1011",
            panel: "#11191b", panelAlt: "#172225", panelHi: "#223236",
            line: "#2c4146", lineBright: "#4b858e",
            text: "#f1f6f6", textDim: "#a7b8ba", textFaint: "#718486", textGhost: "#435354",
            ink: "#061012",
            scanlines: false, brackets: true
        },
        bf4: {
            name: "BATTLEFIELD 4",
            accent: "#2a8fb0", accentHi: "#73c9df", accentDim: "#145064",
            accent2: "#e06b1f",
            bg0: "#020509", bg1: "#071019", bg: "#04090e",
            panel: "#07131c", panelAlt: "#0b1e2b", panelHi: "#122c3d",
            line: "#173446", lineBright: "#2b6178",
            text: "#d9edf5", textDim: "#89a8b5", textFaint: "#5f7f8c", textGhost: "#354d58",
            ink: "#020c12",
            scanlines: true, brackets: false
        },
        bf1: {
            name: "BATTLEFIELD 1",
            accent: "#c9a05a", accentHi: "#efd19a", accentDim: "#6e552e",
            accent2: "#9b3a2a",
            bg0: "#12100b", bg1: "#1b1710", bg: "#16120c",
            panel: "#1e1810", panelAlt: "#272015", panelHi: "#34291b",
            line: "#4c3f2b", lineBright: "#a9874e",
            text: "#f1e6cf", textDim: "#c5b392", textFaint: "#8f7c5d", textGhost: "#5f513c",
            ink: "#140f08",
            scanlines: false, brackets: true
        }
    })

    // v1 → v2: 黑金重制，旧的金色/冷色 token 全部换新。
    function migrateTheme(parsed) {
        var v = parsed && parsed.version ? parsed.version : 0;
        if (v >= 2)
            return;
        root.set("theme.accent", "#e8bd4f");
        root.set("theme.accent2", "#6f9bc4");
        root.set("theme.panel", "#141416");
        root.set("theme.panelAlt", "#1a1a1d");
        root.set("theme.panelHi", "#24242a");
        root.set("theme.line", "#403a2e");
        root.set("theme.lineBright", "#c9a24a");
        root.set("theme.text", "#f2eee3");
        root.set("theme.textDim", "#b9b1a1");
        root.set("theme.scanlines", false);
        root.set("theme.brackets", true);
        root.set("theme.panelOpacity", 0.95);
        root.set("version", 2);
    }

    // v2 → v3：桌面组件变多，把任务卡下移，避免与用户卡重叠。
    function migrateLayout(parsed) {
        var v = parsed && parsed.version ? parsed.version : 0;
        if (v >= 3)
            return;
        if (root.get("widgets.mission.y", 0.78) < 0.84)
            root.set("widgets.mission.y", 0.87);
        if (root.get("widgets.user.y", 0.60) < 0.56)
            root.set("widgets.user.y", 0.60);
        var left = root.get("bar.left", []);
        if (Array.isArray(left) && left.indexOf("user") < 0) {
            left = left.slice();
            left.splice(Math.min(1, left.length), 0, "user");
            root.set("bar.left", left);
        }
        root.set("version", 3);
    }

    // v3 → v4：把操作员入口加入状态列。
    function migrateBar(parsed) {
        var v = parsed && parsed.version ? parsed.version : 0;
        if (v >= 4)
            return;
        var left = root.get("bar.left", []);
        if (Array.isArray(left) && left.indexOf("user") < 0) {
            left = left.slice();
            left.splice(Math.min(1, left.length), 0, "user");
            root.set("bar.left", left);
        }
        root.set("version", 4);
    }

    // v4 → v5：語言改為四語系代碼（auto 交給系統）。
    function migrateLanguage(parsed) {
        var v = parsed && parsed.version ? parsed.version : 0;
        if (v >= 5)
            return;
        var l = ("" + root.get("language", "auto")).toLowerCase();
        if (l === "zh" || l === "zh_tw" || l === "zh-tw")
            root.set("language", "zh_TW");
        else if (l === "zh_cn" || l === "zh-cn" || l === "zh_hans")
            root.set("language", "zh_CN");
        else if (l === "ja" || l === "ja_jp")
            root.set("language", "ja");
        else if (l === "en" || l === "en_us")
            root.set("language", "en");
        else
            root.set("language", "auto");
        root.set("version", 5);
    }

    function applyPreset(name) {
        var p = root.presets[name];
        if (!p)
            return;
        var base = root.defaults().theme;
        var keys = ["accent", "accent2", "accentHi", "accentDim",
            "bg0", "bg1", "bg", "panel", "panelAlt", "panelHi",
            "line", "lineBright", "text", "textDim", "textFaint", "textGhost", "ink",
            "scanlines", "brackets"];
        root.set("theme.preset", name);
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i];
            root.set("theme." + k, p[k] !== undefined ? p[k] : base[k]);
        }
        root.set("theme.mode", p.mode !== undefined ? p.mode : base.mode);
    }

    function merge(base, incoming) {
        if (incoming === null || incoming === undefined || typeof incoming !== "object")
            return base;
        var out = Array.isArray(base) ? base.slice() : Object.assign({}, base);
        for (var key in incoming) {
            var v = incoming[key];
            var isObj = v !== null && typeof v === "object" && !Array.isArray(v);
            var baseIsObj = base !== null && typeof base === "object" && base[key] !== null
                && typeof base[key] === "object" && !Array.isArray(base[key]);
            if (isObj && baseIsObj)
                out[key] = root.merge(base[key], v);
            else
                out[key] = v;
        }
        return out;
    }

    function set(pathStr, value) {
        var parts = ("" + pathStr).split(".");
        var copy = JSON.parse(JSON.stringify(root.data));
        var node = copy;
        for (var i = 0; i < parts.length - 1; i++) {
            if (node[parts[i]] === null || typeof node[parts[i]] !== "object")
                node[parts[i]] = {};
            node = node[parts[i]];
        }
        node[parts[parts.length - 1]] = value;
        root.data = copy;
        root.dirty = true;
        saveTimer.restart();
    }

    function get(pathStr, fallback) {
        var parts = ("" + pathStr).split(".");
        var node = root.data;
        for (var i = 0; i < parts.length; i++) {
            if (node === null || node === undefined || typeof node !== "object")
                return fallback;
            node = node[parts[i]];
        }
        return node === undefined || node === null ? fallback : node;
    }

    function toggle(pathStr) {
        root.set(pathStr, !root.get(pathStr, false));
    }

    function reset() {
        root.data = root.defaults();
        root.dirty = true;
        root.save();
    }

    function save() {
        if (root.path === "")
            return;
        root.dirty = false;
        cfgFile.setText(JSON.stringify(root.data, null, 2) + "\n");
    }

    // v5 → v6：把藍牙從控制中心拆成狀態列獨立組件。
    function migrateBluetooth(parsed) {
        var v = parsed && parsed.version ? parsed.version : 0;
        if (v >= 6)
            return;
        var right = root.get("bar.right", []);
        if (Array.isArray(right) && right.indexOf("bluetooth") < 0) {
            right = right.slice();
            var idx = right.indexOf("net");
            right.splice(idx >= 0 ? idx + 1 : right.length, 0, "bluetooth");
            root.set("bar.right", right);
        }
        root.set("version", 6);
    }

    // v6 → v7：Dock 應用上限提升到 12。
    function migrateDockLimit(parsed) {
        var v = parsed && parsed.version ? parsed.version : 0;
        if (v >= 7)
            return;
        if (root.get("dock.maxItems", 12) < 12)
            root.set("dock.maxItems", 12);
        root.set("version", 7);
    }

    // v7 → v8：狀態列加入壁紙庫入口。
    function migrateWallpaperComponent(parsed) {
        var v = parsed && parsed.version ? parsed.version : 0;
        if (v >= 8)
            return;
        var right = root.get("bar.right", []);
        if (Array.isArray(right) && right.indexOf("wallpaper") < 0) {
            right = right.slice();
            var idx = right.indexOf("media");
            right.splice(idx >= 0 ? idx + 1 : right.length, 0, "wallpaper");
            root.set("bar.right", right);
        }
        if (root.get("sidebar.assign.wallpaper", "off") === "off")
            root.set("sidebar.assign.wallpaper", "right");
        root.set("version", 8);
    }

    property FileView cfgFile: FileView {
        id: cfg
        path: root.path
        watchChanges: false

        onLoaded: {
            var parsed = null;
            try {
                parsed = JSON.parse(root.readText());
            } catch (e) {
                parsed = null;
            }
            root.data = parsed ? root.merge(root.defaults(), parsed) : root.defaults();
            root.loaded = true;
            if (parsed) {
                root.migrateTheme(parsed);
                root.migrateLayout(parsed);
                root.migrateBar(parsed);
                root.migrateLanguage(parsed);
                root.migrateBluetooth(parsed);
                root.migrateDockLimit(parsed);
                root.migrateWallpaperComponent(parsed);
            }
            if (!parsed)
                root.save();
        }
        onLoadFailed: {
            root.loaded = true;
            if (root.path !== "")
                root.save();
        }
    }

    property Timer saveTimer: Timer {
        interval: 250
        onTriggered: root.save()
    }

    property Process mkdir: Process {
        command: ["mkdir", "-p", root.configDir]
        onExited: root.path = root.configDir + "/config.json"
    }

    Component.onCompleted: root.mkdir.running = true
}
