# 設定參考

**繁體中文** · [简体中文](CONFIG.zh-CN.md) · [English](CONFIG.en.md) · [日本語](CONFIG.ja.md) · [Index](i18n.md)

設定檔：`~/.config/gf-shell/config.json`
（`XDG_CONFIG_HOME` 有設定時以此為準。）

- 首次啟動自動生成完整預設值。
- 「副官設置」的所有操作都會即時寫入（250 ms 防抖）。
- 手動編輯後重啟外殼即可生效（部分項目會即時重新綁定）。

## 完整結構

```json
{
  "version": 4,
  "language": "auto",
  "bar": {
    "position": "top",
    "visible": true,
    "thickness": 38,
    "edgeWidth": 1,
    "edgeOpacity": 0.55,
    "size": 1.0,
    "autoHide": false,
    "opacity": 0.94,
    "gray": 0.0,
    "blur": 0.0,
    "clock24h": true,
    "showSeconds": false,
    "titleMode": "window",
    "left": ["launcher", "user", "workspaces", "title"],
    "center": ["clock"],
    "right": ["media", "wallpaper", "stats", "net", "bluetooth", "volume", "battery", "tray",
              "overview", "control", "power"]
  },
  "dock": {
    "enabled": true,
    "position": "bottom",
    "align": "center",
    "deployMode": "launcher",
    "edgeWidth": 1,
    "edgeOpacity": 0.55,
    "autoHide": false,
    "avoid": true,
    "trigger": 24,
    "iconSize": 44,
    "size": 1.0,
    "opacity": 0.94,
    "gray": 0.0,
    "blur": 0.0,
    "maxItems": 12,
    "pinned": ["firefox.desktop", "kitty.desktop", "foot.desktop",
               "org.gnome.Nautilus.desktop", "code.desktop", "steam.desktop"]
  },
  "sidebar": {
    "left":  { "enabled": true, "width": 356, "height": 0.82, "align": "top",
               "opacity": 0.96, "gray": 0.0, "blur": 0.0,
               "autoHide": true, "delay": 650, "trigger": 12, "triggerWidth": 180, "triggerPosition": "top",
               "edgeWidth": 1, "edgeOpacity": 0.55 },
    "right": { "enabled": true, "width": 372, "height": 0.88, "align": "top",
               "opacity": 0.96, "gray": 0.0, "blur": 0.0,
               "autoHide": true, "delay": 650, "trigger": 12, "triggerWidth": 180, "triggerPosition": "top",
               "edgeWidth": 1, "edgeOpacity": 0.55 },
    "assign": {
      "user": "left", "calendar": "left", "roster": "left", "actions": "left",
      "weather": "left", "stats": "right", "mission": "right",
      "media": "right", "visualizer": "right", "comms": "right", "clock": "off"
    }
  },
  "launcher": {
    "columns": 6,
    "showCategories": true,
    "showDetail": true,
    "width": 1040,
    "height": 640
  },
  "theme": {
    "preset": "gfl",
    "bf1Radius": 12,
    "mode": "dark",
    "bg0": "#070708",
    "bg1": "#0d0d0f",
    "bg": "#0a0a0c",
    "textFaint": "#7d7668",
    "textGhost": "#4a463d",
    "ink": "#12100c",
    "accentHi": "#ffd977",
    "accentDim": "#7d6428",
    "fontScale": 1.0,
    "animSpeed": 1.0,
    "lineOpacity": 1.0,
    "settingsOpacity": 0.9,
    "settingsGray": 0.22,
    "accent": "#e8bd4f",
    "accent2": "#6f9bc4",
    "panel": "#141416",
    "panelAlt": "#1a1a1d",
    "panelHi": "#24242a",
    "line": "#403a2e",
    "lineBright": "#c9a24a",
    "text": "#f2eee3",
    "textDim": "#b9b1a1",
    "scanlines": false,
    "brackets": true,
    "panelOpacity": 0.95,
    "scale": 1.0,
    "animations": true
  },
  "terminal": { "command": "" },
  "wallpaper": {
    "enabled": true,
    "path": "",
    "dir": "",
    "fillMode": "fill",
    "dim": 0.06,
    "color": "#080b0e"
  },
  "widgets": {
    "grid": 48,
    "opacity": 1.0,
    "lineOpacity": 1.0,
    "clock":      { "enabled": true,  "x": 0.045, "y": 0.10, "width": 360, "height": 168, "showDate": true, "showSeconds": true },
    "stats":      { "enabled": true,  "x": 0.045, "y": 0.42 },
    "media":      { "enabled": true,  "x": 0.72,  "y": 0.10 },
    "calendar":   { "enabled": false, "x": 0.72,  "y": 0.42 },
    "weather":    { "enabled": true,  "x": 0.045, "y": 0.72 },
    "visualizer": { "enabled": false, "x": 0.72,  "y": 0.42 },
    "user":       { "enabled": true,  "x": 0.72,  "y": 0.60 },
    "mission":    { "enabled": true,  "x": 0.72,  "y": 0.87 }
  },
  "osd":    { "enabled": true, "position": "center" },
  "overview": { "columns": 4, "desktops": 8, "backdrop": 0.94, "showWindows": true },
  "power":  { "confirm": true },
  "user": { "avatar": "" },
  "notifications": { "dnd": false, "toasts": true, "maxToasts": 4, "position": "top-right" },
  "hotkeys": { "launcher": "SUPER+Space", "overview": "SUPER+ALT+Tab", "control": "SUPER+Shift+C" },
  "shell":  { "keepAwake": false }
}
```

## 語言

`language`：`auto`（跟隨 `$LANG`）、`zh_TW`、`zh_CN`、`en`、`ja`。
設定視窗的「系統 → 語言」可即時切換，所有以 `I18n.t()` 綁定的文字會立即更新。

## 狀態列區塊

| 值 | 內容 |
| --- | --- |
| `launcher` / `emblem` | G&K 識別塊（點擊開部署終端） |
| `user` | 操作員入口，點擊展開使用者檔案 |
| `workspaces` | 梯隊/工作區編號，滾輪切換，點擊切換 |
| `title` | 當前單位（視窗）appId + 標題 |
| `clock` | 中央時鐘 + 日期 + AM/PM（或 H24），點擊在該處展開月曆 |
| `media` | 正在播放的通訊；點擊展開媒體 + 歌詞彈出欄 |
| `stats` | CPU / MEM 分段讀數；點擊展開負載、記憶體、磁碟、網路與前 5 進程 |
| `net` | Wi-Fi / 有線 + 四段信號柱 + SSID；點擊展開網路詳情與附近可連接 Wi-Fi |
| `bluetooth` | 藍牙狀態與已連線數量；點擊展開轉接器與已知裝置 |
| `volume` | 音量，左鍵靜音、右鍵控制中心、滾輪調整 |
| `battery` | 電量 / 充電，低電變紅 |
| `tray` | StatusNotifierItem 圖示 |
| `overview` / `control` / `power` | 三個入口按鈕 |

窄螢幕自動隱藏順序：`title` → `media` → `stats` → `tray` → `net` → `bluetooth`。

## 主題預設

| preset | 說明 | 主色 |
| --- | --- | --- |
| `gfl` | G&K 標準：暖炭底 + 啞光金 | `#e8bd4f` |
| `sangvis` | 鐵血：近黑 + 警戒紅 | `#d34a34` |
| `neural` | 神經網絡：深藍 + 冰青 | `#7eb2d6` |
| `arctic` | 極地：冷灰 + 淡金 | `#cbb98a` |
| `arknights` | 羅德島：近黑 + 工業青 + 白 | `#3fd4e6` |
| `bf4` | 戰地 4：深藍 + 掃描線 + 橙 | `#2a8fb0` |
| `bf1` | 戰地 1：舊紙 + 黃銅 + 暗紅 | `#c9a05a` |
| `light` | 日照：紙白底 + 深金（亮色） | `#b07d18` |

預設只會寫入 `theme.*` 的色票，其餘 token（`panel`、`line`、`text`…）也會一起被覆寫，
所以切換後 UI 會立刻整體變化。自訂 `accent` 會把 `preset` 設為 `custom`。

## 設計 token（`modules/common/Theme.qml`）

```qml
// 字型
fontUI      = "Chakra Petch"        // 常規介面
fontDisplay = "Saira Condensed"     // 大標題 / 數字
fontMono    = "Share Tech Mono"     // 數據、編號
fontLabel   = "Rajdhani"            // 小號大寫標籤

// 主要色（黑金）
bg0  #070708      panel      #141416      accent   #e8bd4f   (gold)
bg1  #0d0d0f      panelAlt   #1a1a1d      accent2  #6f9bc4   (steel)
line #403a2e      panelHi    #24242a      red      #d34a34
text #f2eee3      lineBright #c9a24a      ok       #8fc08a

// 幾何
chamfer = 6px     border = 1px     barHeight = 38px
gap = 8px         pad = 12px       radius = 0
```

UI 一律透過 `Theme.alpha(color, a)`、`Theme.mix()`、`Theme.shade()` 取色，
`Theme.px()` / `Theme.fs()` 做縮放。

## 桌面小工具位置

`widgets.<name>.x` / `y` 是**螢幕比例**（0–1），原點在左上角。例如：

```json
"clock":  { "x": 0.045, "y": 0.10 },
"stats":  { "x": 0.045, "y": 0.42 },
"media":  { "x": 0.72,  "y": 0.10 },
"weather":{ "x": 0.045, "y": 0.72 },
"user":   { "x": 0.72,  "y": 0.60 },
"mission":{ "x": 0.72,  "y": 0.87 }
```

覆蓋層打開時，桌面 HUD 會自動淡出（`ShellState.overlay !== "none"`）。


## 質感與位置（狀態列 / Dock / 側邊欄）

三個表面都吃同一組欄位：

| 欄位 | 範圍 | 說明 |
| --- | --- | --- |
| `opacity` | 0.3–1.0 | 背景不透明度 |
| `gray` | 0–1 | 壁紙採樣層去飽和（0 = 彩色，1 = 灰階） |
| `blur` | 0–1 | 壁紙採樣層模糊半徑（自繪 shader，不需合成器 blur） |
| `width` / `iconSize` / `thickness` | — | 尺寸（側邊欄寬度 / Dock 圖示 / 狀態列高度） |
| `position` | top / bottom | 狀態列與 Dock 貼齊上緣或下緣 |

## 側邊欄與狀態列彈出

`sidebar.left` / `sidebar.right`：

| 欄位 | 預設 | 說明 |
| --- | --- | --- |
| `enabled` | true | 是否啟用該側邊欄 |
| `width` | 356 / 372 | 面板寬度 |
| `opacity` / `gray` / `blur` | 0.96 / 0 / 0 | 同上面的表面質感 |
| `delay` | 650 | 滑出後自動收起延遲（ms） |
| `trigger` | 6 | 螢幕邊緣熱區寬度（px） |

- 左側：操作員檔案、月曆、梯隊名冊、DEPLOY。
- 右側：媒體 + 歌詞（lrclib.net）+ cava 頻譜 + 通知紀錄。
- 狀態列點擊 `user` / `clock` / `media` 會分別在該元件下方打開使用者 / 日曆 / 媒體彈出欄。

## 天氣與歌詞

- 天氣：`widgets.weather.city` 留空時由 wttr.in 依 IP 定位；20 分鐘輪詢。
- 歌詞：透過 lrclib.net 查詢，按 `artist + title` 快取；同步歌詞優先，其次純文字。
- 兩者都需要 `curl`；沒有網路時顯示 `NO DATA` / `AWAITING TRANSMISSION`。

## Dock 避讓

`dock.avoid`（預設 true）與 `dock.autoHide`（預設 false）控制避讓：

- 有視窗時 Dock 收起成 6px 金線；滑到下緣熱區才展開。
- 展開時 `exclusiveZone` 變成 Dock 高度，合成器會把視窗往上推（應用避讓）。
- 滑出後自動收起，視窗恢復原位。
- `dock.pinned` 是桌面檔名陣列；Dock 依序顯示固定項目，並把正在執行但未固定的應用接在後面，上限 `dock.maxItems`（預設 12）。
- 設定 → Dock 的「PIN AN APP」可輸入應用名稱後按 Enter 直接固定。
- 右鍵點擊 Dock 圖示可固定/取消固定、開新視窗或關閉；固定狀態寫回 `dock.pinned`。
- `dock.trigger`（4–48px）是 Dock 收起時的熱區高度；越大越容易滑出。收起時熱區透明、面板完全隱藏，僅留 2px 指示線；`exclusiveZone` 為 0，不推開視窗。
- `dock.avoid = false` 時 Dock 始終完整顯示；`dock.autoHide` 只在避讓開啟時生效。
- Dock 與狀態列同邊時，熱區與指示線畫在狀態列邊緣，Dock 本體貼住狀態列內側；`mask` 只保留 Dock/熱區輸入，狀態列其餘部分仍可點。
- `dock.position` 可為 `top` / `bottom` / `left` / `right`；左右為垂直側邊 Dock，`dock.align` 在垂直時是 `top` / `center` / `bottom`。
- `dock.deployMode`：`launcher` / `dashboard`，部署按鈕彈出二選一時的預設/勾選項。
- `terminal.command`：命令輪盤「終端」使用的指令；留空會依序嘗試 kitty/foot/alacritty/wezterm。

### 桌面右鍵命令輪盤

在桌面空白處按右鍵，會在游標位置展開七項命令輪盤（設定、壁紙、桌面組件佈局、部署終端、網路、終端、儀表盤）。數字鍵 1–7 可直接選取；左鍵桌面或 Esc 關閉。四個遊戲主題各自有不同的中心、環線與裝飾，**沒有全屏暗幕**；`ThemeSignature`、BarThemeAccent、CommandRose、Dashboard 的額外樣式都只在對應 preset 下可見。


### 側邊欄組件

用 `sidebar.assign.<id>`（`left` / `right` / `off`）把每個組件分配到左或右，或關閉：

| id | 內容 |
| --- | --- |
| `user` | 操作員卡 |
| `calendar` | 月曆 |
| `roster` | 梯隊名冊 |
| `actions` | 部署 / 戰術 / 設定 / 停機 |
| `stats` | CPU / MEM / NET / DISK |
| `weather` | wttr.in 天氣 |
| `clock` | 大時計與日期 |
| `media` | 播放器 + 歌詞 + 頻譜 |
| `visualizer` | cava 頻譜 |
| `comms` | 最近通知 |
| `mission` | 當前任務 |

`sidebar.<side>.height`（0.4–1.0）與 `sidebar.<side>.align`（`top` / `center` / `bottom`）控制面板高度與垂直位置；
內容放不下時面板可滾動。

### 狀態列組件

`bar.left`、`bar.center`、`bar.right` 是區塊 id 陣列。在「設定 → 狀態列 → 組件」可把每個區塊設為
OFF / LEFT / CENTER / RIGHT，編輯器會改寫這三個陣列；OFF 等同從狀態列移除。


### 桌面佈局編輯

- 在「設定 → 桌面組件 → LAYOUT」按 **EDIT DESKTOP LAYOUT**，或按 `SUPER+SHIFT+W`，或
  `qs -c gf-shell ipc call shell widgets`。
- 編輯模式會疊加網格；拖動框線即可移動組件，鬆手後吸附到 `widgets.grid` 像素網格。
- 每個框右上角有 ON/OFF，可直接開關該組件；桌面組件在編輯時會變暗且不可互動。
- 位置存回 `widgets.<name>.x/y`（螢幕比例）；`grid` 可設 16–96px。
- 每個框右下角可拖動縮放；尺寸存為 `widgets.<name>.width/height`。
- `DONE` 或 `Esc` 退出；`RESET` 回復預設位置與尺寸。

## 主題模式、縮放與設定表面

- `theme.mode`：`dark` / `light` / `custom`；也可直接套用 `preset`（含 `light`）。
- `theme.fontScale`（0.8–1.4）縮放文字，以及展開欄/卡片佈局；`theme.scale`（0.8–1.3）縮放整個 shell（間距、面板、圖示與文字）。
- `theme.settingsOpacity`（0.5–1.0）與 `theme.settingsGray`（0–1）控制 **設定介面** 的灰白透明遮罩；
  黑色導航列與頁首保持不透明。
- 自訂 `bg0/bg1/bg/panel/text/accent/...` 會把 `mode` 設為 `custom`；壁紙會依 `bg0` 亮度自動加上
  紙白洗色，讓深色文字在亮色主題下仍可讀。
- 主題預設寫入完整色盤；`scale`、`fontScale`、`settingsOpacity` 不會被預設覆蓋。

- `dock.position`：`top` / `bottom` / `left` / `right`；左右時 Dock 垂直貼邊。
- `dock.align`：水平 Dock 用 `left` / `center` / `right`；垂直 Dock 用 `top` / `center` / `bottom`。
- `sidebar.<left|right>.triggerPosition`：`top` / `bottom`，觸發區位於該側螢幕的頂端或底端。
- `sidebar.<left|right>.triggerWidth`：橫向熱區寬度（60–420px）；`trigger` 是熱區高度。
- 側邊欄組件新增 `wallpaper`；可在「設定 → 側邊欄 → 組件」分配到左/右。
- `wallpaper.dir`：要匯入的壁紙目錄；支援 png/jpg/jpeg/webp/avif/bmp。狀態列與側邊欄的壁紙庫會列出全部圖片。
- `user.avatar`：自訂頭像路徑；設定首頁的 BROWSE 會複製到 `~/.config/gf-shell/avatar`。
- 亮色主題不再對壁紙加紙白洗色；`wallpaper.dim` 僅在暗色主題套用。

## 壁紙

- 內建：`assets/wallpapers/gfl-ops.png`、`gfl-sangvis`、`gfl-neural`、`gfl-dusk`。
- `path` 留空會用第一張內建壁紙；也可填 `file:///home/user/wall.png` 或絕對路徑。
- `dim`（0–0.6）控制壓暗；`fillMode`：`fill`（裁切填滿）、`fit`、`stretch`。
- 重新生成內建壁紙：`python3 scripts/gen_assets.py`。
