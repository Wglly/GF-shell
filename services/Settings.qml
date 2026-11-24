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
            version: 11,
            language: "auto",            // auto | zh_TW | zh_CN | en | ja
            bar: {
                position: "top",         // top | bottom
                visible: true,
                thickness: 38,
                autoHide: false,
                clock24h: true,
                showSeconds: false,
                edgeWidth: 1,
                edgeOpacity: 0.55,
                titleMode: "window",     // window | mission
                opacity: 0.94,
                gray: 0.0,
                blur: 0.0,
                size: 1.0,
                left: ["launcher", "user", "workspaces", "title"],
                center: ["clock"],
                right: ["media", "wallpaper", "stats", "net", "bluetooth", "volume", "battery", "tray", "overview", "terminal", "control", "power"]
            },
            dock: {
                enabled: true,
                position: "bottom",
                align: "center",          // center | left | right
                autoHide: false,
                hideMargin: 48,
                deployMode: "launcher",
                edgeWidth: 1,
                edgeOpacity: 0.55,
                iconSize: 44,
                opacity: 0.94,
                gray: 0.0,
                blur: 0.0,
                size: 1.0,
                avoid: true,
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
                bg0: "#151513",
                bg1: "#1d1d1a",
                bg: "#191917",
                panel: "#242421",
                panelAlt: "#2d2d29",
                panelHi: "#3a3a34",
                line: "#46443c",
                lineBright: "#c8a24c",
                text: "#f2efe6",
                textDim: "#bcb5a8",
                textFaint: "#857f73",
                textGhost: "#514d45",
                ink: "#181611",
                accent: "#d8aa4b",
                accentHi: "#f0cf7a",
                accentDim: "#7a6127",
                accent2: "#87a0b2",
                scanlines: false,
                brackets: true,
                fontScale: 1.0,
                bf1Radius: 12,
                animSpeed: 1.0,
                lineOpacity: 1.0,
                settingsOpacity: 0.9,
                settingsGray: 0.22,
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
                opacity: 1.0,
                lineOpacity: 1.0,
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
                    autoHide: true, delay: 650, trigger: 12, triggerWidth: 180, triggerPosition: "top",
                    edgeWidth: 1, edgeOpacity: 0.55
                },
                right: {
                    enabled: true, width: 372, height: 0.88, align: "top",
                    opacity: 0.94, gray: 0.0, blur: 0.0,
                    autoHide: true, delay: 650, trigger: 12, triggerWidth: 180, triggerPosition: "top",
                    edgeWidth: 1, edgeOpacity: 0.55
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
            fonts: {
                ui: "", display: "", mono: "", label: ""
            },
            cursor: {
                theme: "", size: 24
            },
            compositor: {
                hypr: {
                    gapsIn: 5, gapsOut: 10, borderWidth: 1, rounding: 8,
                    activeColor: "#e8bd4f", inactiveColor: "#403a2e",
                    blur: true, animations: true
                },
                niri: {
                    gaps: 16, borderWidth: 2, focusWidth: 4, radius: 12,
                    activeColor: "#e8bd4f", inactiveColor: "#403a2e",
                    border: true, focus: false
                }
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
            accent: "#d8aa4b",
            accentHi: "#f0cf7a",
            accentDim: "#7a6127",
            accent2: "#87a0b2",
            bg0: "#151513",
            bg1: "#1d1d1a",
            bg: "#191917",
            panel: "#242421",
            panelAlt: "#2d2d29",
            panelHi: "#3a3a34",
            line: "#46443c",
            lineBright: "#c8a24c",
            text: "#f2efe6",
            textDim: "#bcb5a8",
            textFaint: "#857f73",
            textGhost: "#514d45",
            ink: "#181611",
            scanlines: false,
            brackets: true
        },
        sangvis: {
            name: "SANGVIS FERRI",
            accent: "#c6523c",
            accentHi: "#e47a5f",
            accentDim: "#6f2a20",
            accent2: "#c9c2b4",
            bg0: "#171414",
            bg1: "#201c1c",
            bg: "#1b1818",
            panel: "#282323",
            panelAlt: "#322c2c",
            panelHi: "#403838",
            line: "#4b4140",
            lineBright: "#c8a24c",
            text: "#f2eee9",
            textDim: "#bfb4ad",
            textFaint: "#877b75",
            textGhost: "#514744",
            ink: "#191312",
            scanlines: false,
            brackets: true
        },
        neural: {
            name: "NEURAL CLOUD",
            accent: "#6f9eb8",
            accentHi: "#9cc4d8",
            accentDim: "#3d5b69",
            accent2: "#c8a24c",
            bg0: "#14181b",
            bg1: "#1c2125",
            bg: "#171c1f",
            panel: "#242b30",
            panelAlt: "#2e373d",
            panelHi: "#3b464d",
            line: "#3f4a51",
            lineBright: "#c8a24c",
            text: "#edf1f3",
            textDim: "#b2bcc2",
            textFaint: "#7e8a91",
            textGhost: "#4b555b",
            ink: "#111619",
            scanlines: false,
            brackets: true
        },
        arctic: {
            name: "ARCTIC OPS",
            accent: "#c9b27a",
            accentHi: "#e4d3a0",
            accentDim: "#6f6243",
            accent2: "#8f9ea8",
            bg0: "#161819",
            bg1: "#1e2123",
            bg: "#191c1d",
            panel: "#272b2d",
            panelAlt: "#313639",
            panelHi: "#3e4447",
            line: "#454b4f",
            lineBright: "#c8a24c",
            text: "#f0f1ef",
            textDim: "#b9bfc0",
            textFaint: "#838a8c",
            textGhost: "#4f5557",
            ink: "#131617",
            scanlines: false,
            brackets: false
        },
        arknights: {
            name: "RHODES ISLAND",
            accent: "#58b9c2",
            accentHi: "#8bdde1",
            accentDim: "#2b6d73",
            accent2: "#d7d2c5",
            bg0: "#131718",
            bg1: "#1b2022",
            bg: "#161b1c",
            panel: "#232a2c",
            panelAlt: "#2d3537",
            panelHi: "#3a4346",
            line: "#3c4749",
            lineBright: "#c8a24c",
            text: "#eef3f2",
            textDim: "#b2bfbe",
            textFaint: "#7b8988",
            textGhost: "#4a5655",
            ink: "#0e1516",
            scanlines: false,
            brackets: true
        },
        bf4: {
            name: "BATTLEFIELD 4",
            accent: "#4a9db5",
            accentHi: "#7cc3d7",
            accentDim: "#245a68",
            accent2: "#d9873f",
            bg0: "#11171b",
            bg1: "#192127",
            bg: "#141b20",
            panel: "#222c33",
            panelAlt: "#2c3840",
            panelHi: "#39474f",
            line: "#394a52",
            lineBright: "#c8a24c",
            text: "#e8f0f3",
            textDim: "#a9b9c0",
            textFaint: "#75868d",
            textGhost: "#45555c",
            ink: "#0b1215",
            scanlines: true,
            brackets: false
        },
        bf1: {
            name: "BATTLEFIELD 1",
            accent: "#c7a15b",
            accentHi: "#e2c48a",
            accentDim: "#6d5430",
            accent2: "#9b4a36",
            bg0: "#191612",
            bg1: "#211d18",
            bg: "#1c1915",
            panel: "#29251e",
            panelAlt: "#332e26",
            panelHi: "#403a30",
            line: "#494237",
            lineBright: "#c8a24c",
            text: "#f1eadc",
            textDim: "#c1b6a3",
            textFaint: "#887d6b",
            textGhost: "#51493d",
            ink: "#15110c",
            scanlines: false,
            brackets: true
        },
        hoi4: {
            name: "HEARTS OF IRON IV",
            accent: "#c9a84f",
            accentHi: "#e3ce8a",
            accentDim: "#6e5d2c",
            accent2: "#87936c",
            bg0: "#171810",
            bg1: "#1f2117",
            bg: "#1a1c13",
            panel: "#27291f",
            panelAlt: "#313428",
            panelHi: "#3e4233",
            line: "#464a3b",
            lineBright: "#c8a24c",
            text: "#eee9d8",
            textDim: "#b9b29d",
            textFaint: "#827c6a",
            textGhost: "#4d493c",
            ink: "#14150e",
            scanlines: false,
            brackets: true
        },
        light: {
            name: "DAYLIGHT OPS",
            mode: "light",
            accent: "#b0832b",
            accentHi: "#c99d43",
            accentDim: "#705219",
            accent2: "#6f7f86",
            bg0: "#f0ede6",
            bg1: "#f6f3ec",
            bg: "#f2efe8",
            panel: "#faf7f0",
            panelAlt: "#eae5da",
            panelHi: "#ddd6c8",
            line: "#c9c0ae",
            lineBright: "#b38c3e",
            text: "#211f1b",
            textDim: "#5c574f",
            textFaint: "#8a8377",
            textGhost: "#b7afa1",
            ink: "#17140f",
            scanlines: false,
            brackets: true
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

    // v9 → v10: harmonise every preset with the Sunborn charcoal / brass palette.
    function migratePalette(parsed) {
        var v = parsed && parsed.version ? parsed.version : 0;
        if (v >= 10)
            return;
        var preset = root.get("theme.preset", "gfl");
        if (root.presets[preset])
            root.applyPreset(preset);
        root.set("version", 10);
    }

    // v10 → v11: the branded GF Terminal gets a bar launcher.
    function migrateTerminalItem(parsed) {
        var v = parsed && parsed.version ? parsed.version : 0;
        if (v >= 11)
            return;
        var left = root.get("bar.left", []);
        var center = root.get("bar.center", []);
        var right = root.get("bar.right", []);
        var present = function (a) { return Array.isArray(a) && a.indexOf("terminal") >= 0; };
        if (!present(left) && !present(center) && !present(right)) {
            right = Array.isArray(right) ? right.slice() : [];
            var idx = right.indexOf("control");
            if (idx >= 0) right.splice(idx, 0, "terminal");
            else right.push("terminal");
            root.set("bar.right", right);
        }
        root.set("version", 11);
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
                root.migratePalette(parsed);
                root.migrateTerminalItem(parsed);
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
