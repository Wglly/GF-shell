# 配置参考

[繁體中文](CONFIG.md) · **简体中文** · [English](CONFIG.en.md) · [日本語](CONFIG.ja.md) · [Index](i18n.md)

配置文件：`~/.config/gf-shell/config.json`
（设置了 `XDG_CONFIG_HOME` 时以此为准。）

- 首次启动自动生成完整预设值。
- 「副官设置」的所有操作都会即时写入（250 ms 防抖）。
- 手动编辑后重启外壳即可生效（部分项目会即时重新绑定）。

## 完整结构

```json
{
  "version": 4,
  "language": "auto",
  "bar": {
    "position": "top",
    "visible": true,
    "thickness": 38,
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
               "autoHide": true, "delay": 650, "trigger": 12, "triggerWidth": 180, "triggerPosition": "top" },
    "right": { "enabled": true, "width": 372, "height": 0.88, "align": "top",
               "opacity": 0.96, "gray": 0.0, "blur": 0.0,
               "autoHide": true, "delay": 650, "trigger": 12, "triggerWidth": 180, "triggerPosition": "top" },
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

## 语言

`language`：`auto`（跟随 `$LANG`）、`zh_TW`、`zh_CN`、`en`、`ja`。
设置窗口的「系统 → 语言」可即时切换。

## 状态栏区块

| 值 | 内容 |
| --- | --- |
| `launcher` / `emblem` | G&K 识别块（点击打开部署终端） |
| `user` | 操作员入口，点击展开用户档案 |
| `workspaces` | 梯队/工作区编号，滚轮切换，点击切换 |
| `title` | 当前单位（窗口）appId + 标题 |
| `clock` | 中央时钟 + 日期 + AM/PM（或 H24），点击打开日历 |
| `media` | 正在播放的通讯；点击展开媒体 + 歌词弹出栏 |
| `stats` | CPU / MEM 分段读数；点击展开负载、内存、磁盘、网络与前 5 进程 |
| `net` | Wi-Fi / 有线 + 四段信号柱 + SSID；点击展开网络详情与附近可连接 Wi-Fi |
| `bluetooth` | 蓝牙状态与已连接数量；点击展开适配器与已知设备 |
| `volume` | 音量，左键静音、右键控制中心、滚轮调整 |
| `battery` | 电量 / 充电，低电变红 |
| `tray` | StatusNotifierItem 图标 |
| `overview` / `control` / `power` | 三个入口按钮 |

窄屏幕自动隐藏顺序：`title` → `media` → `stats` → `tray` → `net`。

## 主题预设

| preset | 说明 | 主色 |
| --- | --- | --- |
| `gfl` | G&K 标准：暖炭底 + 哑光金 | `#e8bd4f` |
| `sangvis` | 铁血：近黑 + 警戒红 | `#d34a34` |
| `neural` | 神经网络：深蓝 + 冰青 | `#7eb2d6` |
| `arctic` | 极地：冷灰 + 淡金 | `#cbb98a` |
| `arknights` | 罗德岛：近黑 + 工业青 + 白 | `#3fd4e6` |
| `bf4` | 战地 4：深蓝 + 扫描线 + 橙 | `#35c7ff` |
| `bf1` | 战地 1：旧纸 + 黄铜 + 暗红 | `#c9a05a` |
| `light` | 日照：纸白底 + 深金（亮色） | `#b07d18` |

预设会写入整个 `theme.*` 色板，包括 `panel`、`line`、`text`…，所以切换后 UI 会立刻整体变化。
自定义 `accent` 会把 `preset` 设为 `custom`。

## 设计 token（`modules/common/Theme.qml`）

```qml
// 字体
fontUI      = "Chakra Petch"        // 常规界面
fontDisplay = "Saira Condensed"     // 大标题 / 数字
fontMono    = "Share Tech Mono"     // 数据、编号
fontLabel   = "Rajdhani"            // 小号大写标签

// 主色
bg0  #06090c      panel      #0f161d      accent   #f0a43c
bg1  #0b1015      panelAlt   #131d26      accent2  #69c9bd
line #283844      panelHi    #1a2733      red      #d6513c
text #eae6dc      lineBright #4a6273      ok       #79c08a

// 几何
chamfer = 9px     border = 1px     barHeight = 38px
gap = 8px         pad = 12px       radius = 0
```

UI 一律通过 `Theme.alpha(color, a)`、`Theme.mix()`、`Theme.shade()` 取色，
`Theme.px()` / `Theme.fs()` 做缩放。

## 桌面小工具位置

`widgets.<name>.x` / `y` 是**屏幕比例**（0–1），原点在左上角。例如：

```json
"clock":  { "x": 0.045, "y": 0.10 },
"stats":  { "x": 0.045, "y": 0.42 },
"media":  { "x": 0.72,  "y": 0.10 },
"weather":{ "x": 0.045, "y": 0.72 },
"user":   { "x": 0.72,  "y": 0.60 },
"mission":{ "x": 0.72,  "y": 0.87 }
```

覆盖层打开时，桌面 HUD 会自动淡出（`ShellState.overlay !== "none"`）。


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
- `dock.pinned` 是桌面文件名数组；Dock 按顺序显示固定项目，并把正在运行但未固定的应用接在后面，上限 `dock.maxItems`（默认 12）。
- 设置 → Dock 的“PIN AN APP”可输入应用名称后按 Enter 直接固定。
- 右键点击 Dock 图标可固定/取消固定、开新窗口或关闭；固定状态写回 `dock.pinned`。
- `dock.trigger`（4–48px）是 Dock 收起时的热区高度；越大越容易滑出。收起时热区透明、面板完全隐藏，仅留 2px 指示线；`exclusiveZone` 为 0，不推开窗口。
- `dock.avoid = false` 时 Dock 始终完整显示；`dock.autoHide` 只在避让开启时生效。
- Dock 与状态栏同边时，热区与指示线画在状态栏边缘，Dock 本体贴住状态栏内侧；`mask` 只保留 Dock/热区输入，状态栏其余部分仍可点。


### 侧边栏组件

`sidebar.assign.<id>`（`left` / `right` / `off`）决定组件在左侧、右侧或关闭；组件包括
`user`（操作员）、`calendar`（月历）、`roster`（梯队名册）、`actions`（快捷操作）、
`stats`（系统状态）、`weather`（天气）、`clock`（时钟）、`media`（媒体+歌词）、
`visualizer`（频谱）、`comms`（通知）、`mission`（任务）。

`sidebar.<side>.height`（0.4–1.0）与 `align`（top / center / bottom）控制高度与垂直位置。

### 状态栏组件

`bar.left` / `bar.center` / `bar.right` 为区块 id 数组；在「设置 → 状态栏 → 组件」中可逐项设为
OFF / LEFT / CENTER / RIGHT，OFF 即从状态栏移除。


### 桌面布局编辑

- 在「设置 → 桌面组件 → 布局」按 **编辑桌面布局**，或按 `SUPER+SHIFT+W`，或执行
  `qs -c gf-shell ipc call shell widgets`。
- 编辑模式叠加网格；拖动框线移动组件，松手吸附到 `widgets.grid` 像素网格。
- 每个框右上角有 ON/OFF，可直接开关组件；编辑时组件会变暗且不可交互。
- 位置保存为 `widgets.<name>.x/y`（屏幕比例）；`grid` 可设 16–96px。
- 每个框右下角可拖动缩放；尺寸保存为 `widgets.<name>.width/height`。
- `完成` 或 `Esc` 退出；`重置` 恢复默认位置与尺寸。

## 主题模式、缩放与设置表面

- `theme.mode`：`dark` / `light` / `custom`；预设（含 `light`）会自动设置。
- `theme.fontScale`（0.8–1.4）缩放文字，以及展开栏/卡片布局；`theme.scale`（0.8–1.3）缩放整个 shell。
- `theme.settingsOpacity`（0.5–1.0）与 `theme.settingsGray`（0–1）控制设置窗口的灰白半透明遮罩。
- 自定义 `bg0/bg1/panel/text/accent` 会把 `mode` 设为 `custom`；壁纸会按 `bg0` 亮度加纸白洗色。

- `dock.position`：`top` / `bottom` / `left` / `right`；左右时 Dock 垂直贴边。
- `dock.align`：水平 Dock 用 `left` / `center` / `right`；垂直 Dock 用 `top` / `center` / `bottom`。
- `sidebar.<left|right>.triggerPosition`：`top` / `bottom`，触发区位于该侧屏幕的顶端或底端。
- `sidebar.<left|right>.triggerWidth`：横向热区宽度（60–420px）；`trigger` 是热区高度。
- 侧边栏组件新增 `wallpaper`，可在「设置 → 侧边栏 → 组件」分配到左/右。
- `wallpaper.dir`：要导入的壁纸目录；支持 png/jpg/jpeg/webp/avif/bmp。状态栏和侧边栏壁纸库会列出全部图片。
- `user.avatar`：自定义头像路径；设置首页 BROWSE 会复制到 `~/.config/gf-shell/avatar`。
- 亮色主题不再给壁纸加纸白洗色；`wallpaper.dim` 仅在暗色主题生效。

### 桌面右键命令轮盘

在桌面空白处按右键，会在光标位置展开七项命令轮盘（设置、壁纸、桌面组件布局、部署终端、网络、终端、仪表盘）。数字键 1–7 可直接选择；左键桌面或 Esc 关闭。四个游戏主题各有不同的中心、环线与背景；`ThemeSignature`、BarThemeAccent、CommandRose、Dashboard 的额外样式只在对应预设下可见。

## 壁纸

- 内置：`assets/wallpapers/gfl-ops.png`、`gfl-sangvis`、`gfl-neural`、`gfl-dusk`。
- `path` 留空会使用第一张内置壁纸；也可填 `file:///home/user/wall.png` 或绝对路径。
- `dim`（0–0.6）控制压暗；`fillMode`：`fill`（裁切填满）、`fit`、`stretch`。
- 重新生成内置壁纸：`python3 scripts/gen_assets.py`。
