<p align="center">
  <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/github/license/Wglly/GF-shell?style=flat-square&amp;labelColor=070708&amp;color=e8bd4f"></a>
  <img alt="Quickshell 0.3+" src="https://img.shields.io/badge/Quickshell-0.3%2B-e8bd4f?style=flat-square&amp;labelColor=070708">
  <img alt="Hyprland and niri" src="https://img.shields.io/badge/Compositors-Hyprland%20%7C%20niri-c9a24a?style=flat-square&amp;labelColor=070708">
  <img alt="Qt 6 on Wayland" src="https://img.shields.io/badge/Stack-Qt%206%20%7C%20Wayland-6f9bc4?style=flat-square&amp;labelColor=070708">
  <img alt="Arch, Fedora, Debian" src="https://img.shields.io/badge/Distros-Arch%20%7C%20Fedora%20%7C%20Debian-8fc08a?style=flat-square&amp;labelColor=070708">
  <img alt="Four UI languages" src="https://img.shields.io/badge/Languages-4-d34a34?style=flat-square&amp;labelColor=070708">
  <a href="https://github.com/Wglly/GF-shell/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/Wglly/GF-shell?style=flat-square&amp;labelColor=070708&amp;color=e8bd4f&amp;logo=github"></a>
  <a href="https://github.com/Wglly/GF-shell/commits/main"><img alt="Last commit" src="https://img.shields.io/github/last-commit/Wglly/GF-shell?style=flat-square&amp;labelColor=070708&amp;color=c9a24a"></a>
</p>

<p align="center">
  <img src="docs/screenshots/banner.png" alt="GF-shell — tactical desktop shell" width="100%">
</p>

<h1 align="center">GF-shell</h1>

<p align="center"><b>《少女前线》风格的 Quickshell 桌面外壳 · 面向 Hyprland 与 niri · Wayland</b></p>

<p align="center">
  <a href="README.md">繁體中文</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.en.md">English</a> · <a href="README.ja.md">日本語</a>
</p>

![Desktop](docs/screenshots/01-desktop.png)


GF-shell 是一个从零编写的 Quickshell（Qt Quick）桌面外壳，视觉语言取自《少女前线》公开的战术界面：
暖炭黑底、哑光金强调色、45° 小切角、金线 + 内侧细白线的双层框、斜切标签缎带、半调网点、分段式仪表与等宽数据字。
所有图形素材（壁纸、徽章、纹理、图标底色）都由 `scripts/gen_assets.py` 程序化生成，**不含任何游戏原始素材**。

文档：[安装](docs/INSTALL.zh-CN.md) · [配置](docs/CONFIG.zh-CN.md) · [架构](docs/ARCHITECTURE.zh-CN.md) · [设计](docs/DESIGN.zh-CN.md) · [开发进度](docs/PROGRESS.en.md) · [其他语言](docs/i18n.md)

---

## 目录

- [功能](#功能)
- [画面](#画面)
- [需求](#需求)
- [安装](#安装)
- [安装](#安装)
- [开机自启](#开机自启)
- [快捷键与 > 注意：`SUPER+Tab` 可能被其他 shell（例如 MC-shell）占用；本项目使用 `SUPER+ALT+Tab`。
> 若快捷键无作用，先确认 `hyprctl globalshortcuts | grep gf-shell` 含 `gf-shell:overview`，
> 并确认同一组键没有重复绑定（重复会打开又立刻关闭）。

IPC](#快捷键与-ipc)
- [配置](#配置)
- [目录结构](#目录结构)
- [自定义与换肤](#自定义与换肤)
- [素材生成](#素材生成)
- [双合成器支持](#双合成器支持)
- [已知限制](#已知限制)
- [授权与致谢](#授权与致谢)

---

## 功能

| 模块 | 说明 |
| --- | --- |
| **状态栏 (Bar)** | 主题化部署终端（各主题不同徽记与指挥字样，不直接写主题名）、操作员入口、梯队/工作区编号、当前单位（窗口）标题、中央时钟、通讯/CPU/内存/网络/蓝牙/音量/电池/可展开托盘（图标＋最近消息）、壁纸库、作战地图、战术控制、系统停机。窄屏幕会自动隐藏次要区块；组件可在「设置 → 状态栏 → 组件」用 end-4pc 式拖放看板拖到左/中/右排序，或拖到 OFF 关闭。网络、蓝牙、性能监控为独立组件，点击展开详情；网络详情会列出附近可连接的 Wi-Fi。 |
| **GF TERMINAL** | 用 Rust 编写的 GF-shell 专属终端：自绘炭黑/黄铜标题栏、读取 GF-shell 主题与字体、ANSI/256 色、CJK、滚动历史，并原生支持 Kitty 图片协议；状态栏 Terminal 图标与侧边栏 Quick Actions 可直接启动；左上角 CFG 面板可切换 G&K／明日方舟／战地 1／战地 4／钢铁雄心主题与窗口透明度；附带 `gf-img` 可直接在终端显示 PNG/JPEG/GIF/WebP。详见 [gf-term/README.md](gf-term/README.md)。 |
| **部署终端 (Launcher)** | 全屏单位清单：分类（全部/最近/通讯/开发/媒体/文书/作战/系统）、模糊搜索、键盘导航、右侧单位档案（CLASS/STATUS/SOURCE/EXEC）与 DEPLOY；展开后的标题、指挥副标题与圆形勋章会换成当前主题的徽章；支持鼠标滚轮与拖动滚动。 |
| **仪表盘 (Dashboard)** | macOS Launchpad 式全屏总览：顶部主题化标题、系统/电力/链路/媒体四张状态卡、单位搜索、应用网格与 SETTINGS/CONTROL/MAP/LAUNCHER 快捷键；GFL、Arknights、BF4、BF1 各有不同标题、背景与卡片轮廓。 |
| **战术控制 (Control Center)** | 链路（Wi-Fi/蓝牙）、音量/亮度分段滑条、模块开关、CPU/MEM/BAT 分段仪表、通讯记录、随媒体控制。现在以状态栏弹出方式展开（`popupKind=control`），桌面组件保持可见。 |
| **作战地图 (Overview)** | 每个工作区一张“扇区”卡，列出其中的单位；点扇区切换工作区、点单位聚焦窗口；把单位拖到另一个扇区，或右键单位后点击目标扇区，即可移动窗口。 |
| **命令轮盘 (Command Rose)** | **桌面右键**在鼠标位置展开《战地》Q 命令式轮盘：设置、壁纸、桌面组件布局、部署终端、网络、终端、仪表盘。七个选项可点击或按 1–7；左键桌面/Esc 关闭。GFL、Arknights、BF4、BF1、HoI4 各有不同的中心徽章与环线；HoI4 使用参谋罗盘、四向刻记与 HIGH COMMAND / NATIONAL ORDERS 中心牌；**没有全屏暗幕**，展开时桌面保持原本亮度与可视度。 |
| **系统停机 (Power)** | 锁定/休眠/重启/关机/登出；危险操作需二次确认（ENTER 两次），ESC 取消。 |
| **HUD 小工具** | 大时钟、系统生命体征、通讯（含歌词）、天气、cava 音频频谱、操作员卡、当前任务；逐项开关。另有 **桌面布局编辑模式**：叠加网格、拖动吸附、右下角自由缩放、每个组件可单独 ON/OFF；编辑工具栏可调 **全局组件透明度**与**组件线条透明度**。 |
| **梯队 (Dock)** | 固定与运行中的单位依序显示（上限 12）；右键单位可固定/取消固定、开新窗口或关闭；设置 → Dock 可输入应用名称直接固定。`dock.position` 可选上/下/左/右；左右时 Dock **垂直贴边**，`dock.align` 控制垂直上/中/下或水平左/中/右。只有开启自动隐藏时才收起；鼠标移到 Dock 所在的那条屏幕边缘（6px 边线）才展开，并用 exclusive zone 推开窗口。图标尺寸/透明度/灰度/模糊可调；收起判定范围可调（0–240px），关闭“避让窗口”后 Dock 始终完整显示；收起时只保留 6px 边线，展开才显示面板。最右侧部署按钮会展开 **部署终端 / 仪表盘** 二选一，也可在「设置 → Dock → 部署按钮」指定默认。 |
| **通知** | 右上角“通讯”弹窗（滑入、7 秒自动回收、点击关闭）＋控制中心内的历史记录。 |
| **OSD** | 音量/亮度 HUD，分段仪表 + 大号数字。 |
| **日历** | 点时钟下拉的行程面板：月份切换、今日高亮、周数。 |
| **副官设置** | 所有主题统一使用 DAYLIGHT 的纸白控制台（白底、黑线、黑灰按钮），只把强调色、悬停/选中、分区标记与滑杆进度换成当前主题的突出色；背景为 **可调灰白透明**（透明度/灰度）。8 个分页（外观/状态栏/梯队/侧边栏/桌面组件/壁纸/系统/关于）；支持 **亮色 / 暗色 / 自定义配色**、**整体缩放**与**字体缩放**；第一页新增操作员主页（头像上传、用户/系统信息、快速操作）；系统分页可即时调整 Hyprland 或 niri 的间距、边框、圆角与动画；外观分页可从本地 `fc-list` 字体中选择 UI / 标题 / 数据 / 标签字体，也可选择本地 Xcursor 鼠标指针与大小；设置行也会随字体缩放，避免与线条重叠。 |
| **侧边栏 (Sidebars)** | 左：操作员档案、月历、梯队名册；右：媒体 + 歌词 + cava 频谱 + 通讯记录。触发区改在左右屏幕的**顶端或底端**，宽度、高度和位置可在设置调整；移出延迟收起。每个组件可在「设置 → 侧边栏 → 组件」用与状态栏相同的拖放看板拖到左/右排序，或拖到 OFF 关闭；面板高度（40–100%）与上/中/下对齐可调；含壁纸库组件。 |
| **状态栏弹出** | 点击操作员、时钟、媒体，详细栏锚定在该组件下方独立展开（用户/日历/媒体分开）。 |

其他：

- 九套主题预设：**G&K STANDARD**、**SANGVIS FERRI**、**NEURAL CLOUD**、**ARCTIC OPS**、**RHODES ISLAND (Arknights)**、**BATTLEFIELD 4**、**BATTLEFIELD 1**、**HEARTS OF IRON IV**、**DAYLIGHT OPS**（亮色，中性亮灰底）；也可选 DARK / LIGHT / CUSTOM，自订 BG0/BG1/PANEL/TEXT/ACCENT 十六进制颜色。游戏主题只在该主题下加入自己的背景签名、Bar/Dock 细节与仪表盘外观；HoI4 另有“国家档案／外交电报”侧边栏、罗马数字战区页签、参谋地图桌面框、双线黄铜面板与 NATIONAL SITUATION REPORT 抬头。所有出现用户卡片的位置（状态栏用户弹出、侧边栏操作员档案、桌面操作员卡）都会随主题切换版式：HoI4 为国家领导人肖像＋政治力量/稳定度/战争支持，BF4/BF1 为士兵档案＋军衔背景与服役记录，Arknights 为罗德岛干员档案＋职业/稀有度/信赖。桌面概览（OPERATION MAP）展开时的地图背景也会随主题切换：HoI4 为黄铜墨卡托世界图、BF1 为欧洲战线图、BF4 为全球网络图、Arknights 为泰拉／罗德岛测绘、GFL 为世界战区图；其他主题不会加载这些地图。BF1 圆角半径（0–28px）、全局动画速度（0.5×–2.0×）与全局线条透明度（0–1）可在设置 → 外观 → 表面调整。
- 全局缩放：`SHELL SCALE`（整体）与 `FONT SCALE`（文字、展开栏与卡片布局）分开调整；设置背景的灰白遮罩可调透明度与灰度。
- 统一图标字体（Material Symbols 子集，改名为 *GF Tactical Icons*，约 1 MB，避免与系统字体撞名）、四种附带字体（Chakra Petch / Saira Condensed / Rajdhani / Share Tech Mono）。
- 界面支持四种语言：**繁體中文 / 简体中文 / English / 日本語**；在「副官设置 → 系统 → 语言」即时切换（设置页本身也会跟着切换）。
- 壁纸支持内置四张 + **导入整个目录**（自动识别 png/jpg/webp/avif）；状态栏和侧边栏都有壁纸库，展开可浏览所有图片。
- 亮色主题不再给壁纸加纸白洗色。
- 状态栏 / Dock / 侧边栏都可调 **透明度、灰度、模糊、尺寸、位置、外框线宽与透明度**；模糊以壁纸采样 shader 实现，不依赖合成器。
- 媒体卡（状态栏弹出、侧边栏、桌面）共用歌词（lrclib.net）与 cava 频谱。
- 全局状态机只有一个覆盖层可见，避免多个全屏窗口互相冲突。
- 内置 IPC：`qs -c gf-shell ipc call shell toggle <overlay>`，供 niri / 脚本 / 快捷键调用。

---

## 画面

| 部署终端 | 战术控制 |
| --- | --- |
| ![Launcher](docs/screenshots/02-launcher.png) | ![Control](docs/screenshots/03-control-center.png) |

| 作战地图 | 系统停机 |
| --- | --- |
| ![Overview](docs/screenshots/04-overview.png) | ![Power](docs/screenshots/05-power.png) |

| 副官设置 | 壁纸 |
| --- | --- |
| ![Settings](docs/screenshots/06-settings.png) | ![Wallpaper](docs/screenshots/07-settings-wallpaper.png) |

| 日历弹出 | OSD | 通讯 |
| --- | --- | --- |
| ![Calendar](docs/screenshots/14-bar-popup.png) | ![OSD](docs/screenshots/09-osd.png) | ![Toast](docs/screenshots/10-toast.png) |

| 左侧边栏 | 右侧边栏 |
| --- | --- |
| ![Sidebar left](docs/screenshots/12-sidebar-left.png) | ![Sidebar right](docs/screenshots/13-sidebar-right.png) |

| English 界面 | 日本語界面 | 日本語侧边栏 |
| --- | --- | --- |
| ![English](docs/screenshots/15-settings-en.png) | ![Japanese](docs/screenshots/16-settings-ja.png) | ![Japanese sidebar](docs/screenshots/17-sidebar-ja.png) |

| 组件编辑：状态栏 | 侧边栏组件 | 桌面网格布局 |
| --- | --- | --- |
| ![Bar components](docs/screenshots/18-settings-bar.png) | ![Sidebar components](docs/screenshots/19-settings-sidebar.png) | ![Widget editor](docs/screenshots/20-widget-editor.png) |

| 亮色主题：桌面 | 亮色主题：部署终端 | 设置：缩放与表面 |
| --- | --- | --- |
| ![Light desktop](docs/screenshots/21-light-desktop.png) | ![Light launcher](docs/screenshots/22-light-launcher.png) | ![Scale and surface](docs/screenshots/23-settings-appearance.png) |

| Network details & nearby Wi-Fi | Bluetooth details | Performance details |
| --- | --- | --- |
| ![Network popup](docs/screenshots/24-network-popup.png) | ![Bluetooth popup](docs/screenshots/25-bluetooth-popup.png) | ![Stats popup](docs/screenshots/26-stats-popup.png) |

| Settings home / avatar | Wallpaper library | Expandable tray |
| --- | --- | --- |
| ![Settings home](docs/screenshots/27-settings-home.png) | ![Wallpaper library](docs/screenshots/28-wallpaper-library.png) | ![Tray](docs/screenshots/29-tray.png) |

| Dashboard | Command rose (GFL) | Command rose (BF4) |
| --- | --- | --- |
| ![Dashboard](docs/screenshots/31-dashboard-gfl.png) | ![Command rose GFL](docs/screenshots/32-command-rose-gfl.png) | ![Command rose BF4](docs/screenshots/33-command-rose-bf4.png) |

| Command rose (Arknights) | Command rose (BF1) | Vertical dock |
| --- | --- | --- |
| ![Command rose Arknights](docs/screenshots/34-command-rose-arknights.png) | ![Command rose BF1](docs/screenshots/35-command-rose-bf1.png) | ![Vertical dock](docs/screenshots/30-dock-vertical.png) |

| Dock deploy chooser | | |
| --- | --- | --- |
| ![Dock deploy](docs/screenshots/36-dock-deploy.png) | | |


同一套外壳跑在 **niri** 上（嵌套于 Hyprland 测试的窗口）：

![niri](docs/screenshots/11-niri.png)

---

## 需求

- **Quickshell ≥ 0.3**（Arch: `quickshell`；Fedora: COPR；Debian 13: `trixie-backports`）
- Qt 6：`qt6-declarative`、`qt6-svg`、`qt6-wayland`、`qt6-base`
- Wayland 合成器：**Hyprland** 或 **niri**（皆已测试）
- 建议工具（缺少时对应功能自动禁用）：
  - `pipewire` + `wireplumber`：音量
  - `brightnessctl`：亮度
  - `NetworkManager`：网络开关/SSID
  - `bluez`：蓝牙开关
  - `upower`：电池
  - `cava`：音乐频谱
  - `curl`：天气（wttr.in）与歌词（lrclib.net）
  - `grim` / `slurp` / `wf-recorder`：截图与录屏
  - `wl-clipboard`：截图复制
- 字体：西文与图标附带（`assets/fonts/`）；CJK 使用系统 `Noto Sans CJK`。

---

## 安装

```bash
git clone <repo> GF-shell           # 或直接使用本目录
cd GF-shell

# Fedora / Nobara / RHEL 系（自动 COPR + 依赖）
./scripts/install-fedora.sh

# Debian / Ubuntu（Debian 13 自动 backports；无包时加 --build-quickshell）
./scripts/install-debian.sh

# Arch / 通用
./install.sh                        # 复制到 ~/.config/quickshell/gf-shell
# 或开发用：
./install.sh --link                 # 符号链接，改文件即生效

qs -c gf-shell                      # 启动
```

也可以不安装，直接指定路径运行：

```bash
qs -p /path/to/GF-shell
```

卸载：

```bash
rm -rf ~/.config/quickshell/gf-shell
rm -rf ~/.config/gf-shell
```

### 开机自启

**Hyprland**（Lua 配置，0.5x）：

```lua
hl.exec_cmd("qs -c gf-shell")
```

**Hyprland**（传统 `hyprland.conf`）：

```ini
exec-once = qs -c gf-shell
```

**niri**（`~/.config/niri/config.kdl`）：

```kdl
spawn-at-startup "qs" "-c" "gf-shell"
```

> 若原本使用其他外壳（例如 end4-pC / caelestia / waybar），请先禁用它的自启与状态栏，避免两条 bar 叠在一起。

---

## 快捷键与 IPC

外壳通过 Hyprland 的 global shortcut 注册（appid `gf-shell`）。在 Hyprland 里把下列绑定加进配置即可：

```lua
-- Hyprland 0.57 的 Lua 配置
hl.bind("SUPER + Space",      hl.dsp.global("gf-shell:launcher"),  { description = "GF-shell: 部署终端" })
hl.bind("SUPER + ALT + TAB",  hl.dsp.global("gf-shell:overview"),  { description = "GF-shell: 作战地图" })
hl.bind("SUPER + SHIFT + TAB", hl.dsp.global("gf-shell:overview"), { description = "GF-shell: overview (alt)" })
hl.bind("SUPER + SHIFT + C",  hl.dsp.global("gf-shell:control"),   { description = "GF-shell: 战术控制" })
hl.bind("SUPER + SHIFT + P",  hl.dsp.global("gf-shell:power"),     { description = "GF-shell: 系统停机" })
hl.bind("PRINT",              hl.dsp.global("gf-shell:screenshot"),{ description = "GF-shell: 截图" })
```

传统配置：

```ini
bind = SUPER, Space, global, gf-shell:launcher
bind = SUPER ALT, TAB, global, gf-shell:overview
bind = SUPER SHIFT, TAB, global, gf-shell:overview
bind = SUPER SHIFT, C, global, gf-shell:control
bind = SUPER SHIFT, P, global, gf-shell:power
bind = SUPER SHIFT, W, global, gf-shell:widgets
bind = , Print, global, gf-shell:screenshot
```

**niri** 没有 Hyprland 的 global shortcut 协议，改用 IPC：

```kdl
Mod+Space { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "launcher"; }
Mod+Alt+Tab { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "overview"; }
Mod+Shift+Tab { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "overview"; }
Mod+Shift+W { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "widgets"; }
```

IPC 接口（`IpcHandler`，target `shell`）：

```bash
qs -c gf-shell ipc call shell toggle launcher    # none|launcher|control|overview|power|settings|calendar
qs -c gf-shell ipc call shell open overview
qs -c gf-shell ipc call shell close
qs -c gf-shell ipc call shell widgets   # 桌面组件布局编辑
qs -c gf-shell ipc call shell volume 0.7   # 设置音量
qs -c gf-shell ipc call shell mute         # 切换静音
qs -c gf-shell ipc call shell status
```

| 覆盖层 | `GF_OVERLAY` 值 | 说明 |
| --- | --- | --- |
| 部署终端 | `launcher` | 搜索 / 启动应用 |
| 战术控制 | `control` | 链路、音量、亮度、通讯 |
| 作战地图 | `overview` | 工作区与窗口 |
| 系统停机 | `power` | 电源动作 |
| 副官设置 | `settings` | 设置窗口 |
| 日历 | `calendar` | 行程 |

> 调试用环境变量：`GF_OVERLAY=<overlay>` 启动即打开某个覆盖层；`GF_TAB=<0-7>` 指定设置分页；
> `GF_DEBUG=osd|toast|gauge|icons` 显示对应的调试画面（`modules/debug/`）。

---

## 配置

配置文件：`~/.config/gf-shell/config.json`（首次启动自动生成）。

| 区块 | 常用键 |
| --- | --- |
| `bar` | `position`、`thickness`、`opacity`、`gray`、`blur`、`clock24h`、`showSeconds`、`left` / `center` / `right`（组件顺序；可在设置里设 OFF/LEFT/CENTER/RIGHT） |
| `sidebar` | `left` / `right` 的 `width`、`height`（0.4–1.0）、`align`、`opacity`、`gray`、`blur`、`assign.<id>`（left/right/off） |
| `theme` | `preset`（含 `light`）、`mode`（dark/light/custom）、`accent`、`accent2`、`bg0`、`bg1`、`panel`、`text`、`fontScale`、`settingsOpacity`、`settingsGray`、`scale`、`animations` |
| `wallpaper` | `enabled`、`path`（`file://` 或空＝内置）、`fillMode`、`dim` |
| `dock` | `enabled`、`autoHide`、`avoid`、`iconSize`、`opacity`、`gray`、`blur`、`maxItems`、`pinned` |
| `widgets` | `grid`（吸附像素）、各组件的 `enabled`、`x`、`y`、`width`、`height`（布局编辑器右下角缩放） |
| `overview` | `columns`、`desktops`、`backdrop` |
| `notifications` | `dnd`、`toasts`、`maxToasts` |
| `osd` | `enabled` |
| `language` | `auto` / `zh_TW` / `zh_CN` / `en` / `ja` |

`bar.left/center/right` 可用区块：

```
launcher | emblem | user | workspaces | title | clock | media | stats | net | bluetooth | volume
| battery | tray | overview | control | power
```

任何更改都可以在「副官设置」里完成，配置会即时写入。

---

## 目录结构

```
GF-shell/
├── shell.qml                    # 入口：字体、主题绑定、快捷键、每屏幕窗口、IPC
├── install.sh
├── scripts/install-fedora.sh    # Fedora 安装脚本
├── scripts/install-debian.sh    # Debian / Ubuntu 安装脚本
├── scripts/gen_assets.py        # 壁纸 / 徽章 / 纹理生成器（Pillow + numpy）
├── assets/
│   ├── fonts/                   # Chakra Petch、Saira Condensed、Rajdhani、Share Tech Mono、GFTacticalIcons
│   ├── icons/                   # emblem*.png（程序生成）
│   ├── textures/                # halftone / hatch / noise / scanlines
│   └── wallpapers/              # gfl-ops / gfl-sangvis / gfl-neural / gfl-dusk
├── services/                    # 单例服务层
│   ├── Compositor.qml           # Hyprland + niri 统一工作区/窗口 API
│   ├── Settings.qml             # config.json 读写、主题预设
│   ├── Audio / Battery / Net / Media / Notifs / Stats / System / Apps / Capture
│   ├── I18n.qml                 # 英文 / 繁体中文字符串
│   └── Wallpapers.qml
├── modules/
│   ├── common/                  # Theme.qml、ShellState.qml、Util.qml
│   │   └── widgets/             # Gf* 设计系统：Frame / Button / Slider / Toggle / Gauge…
│   ├── bar/                     # 状态栏、区块、日历
│   ├── launcher/                # 部署终端
│   ├── control/                 # 战术控制
│   ├── overview/                # 作战地图
│   ├── power/                   # 系统停机
│   ├── widgets/                 # 桌面 HUD
│   ├── dock/                    # 梯队
│   ├── notifications/           # 通讯弹窗
│   ├── osd/                     # 音量/亮度 HUD
│   ├── wallpaper/               # 桌面底层
│   ├── settings/                # 副官设置
│   └── debug/                   # GF_DEBUG 用的调试页
└── docs/                        # 安装、配置、架构、截图
```

**数据流**：`services/*` 订阅系统状态（Quickshell 的 Pipewire/UPower/Mpris/Networking/SystemTray、
`hyprctl` / `niri msg`），`modules/common/Theme.qml` 提供唯一的设计 token，所有 UI 只读 `Theme.*`
与服务的只读属性；状态机在 `ShellState.qml`，写入在 `Settings.qml`。

---

## 自定义与换肤

- **颜色 / 间距 / 字号**：只改 `modules/common/Theme.qml`。
- **主题预设**：`services/Settings.qml` 的 `presets`，或直接在设置里切换。
- **新增状态栏区块**：
  1. 在 `modules/bar/blocks/` 新增 `FooBlock.qml`；
  2. 在 `modules/bar/BarItem.qml` 的 `switch` 加上 `foo`；
  3. 在配置文件的 `bar.left/center/right` 加入 `"foo"`。
- **新增覆盖层**：创建 `PanelWindow`（`WlrLayer.Overlay`）→ 依 `ShellState.overlay === "name"` 显示 →
  在 `shell.qml` 实例化 → `IpcHandler` / `GlobalShortcut` 已支持任意名称。
- **换壁纸**：在设置里直接选；也可把图片路径写进 `wallpaper.path`。官方公式图请自备（项目不散布版权素材），细节见 [设计说明](docs/DESIGN.zh-CN.md)。

---

## 素材生成

```bash
python3 scripts/gen_assets.py
```

需要 `Pillow` 与 `numpy`。会重新生成：

- `assets/wallpapers/*.png`（1920×1080，暖炭底 + 金色斜带 + 半调网点 + 等高线 + 等距基地线稿 + 徽章水印 + 金色细框）
- `assets/icons/emblem*.png`、`assets/icon.png`
- `assets/textures/*.png`

**徽章是原创设计**（六角框 + 三层翼形雪佛龙 + 指挥星），不是《少女前线》的任何官方标志。

---

## 双合成器支持

`services/Compositor.qml` 把两者的差异收敛成一组 API（`workspaces`、`windows`、`focusedId`、
`windowTitle`、`focusWorkspace()`、`focusWindow()`、`step()`）：

- **Hyprland**：走 Quickshell 的 `Quickshell.Hyprland` 服务（事件驱动）。
  同时处理 Hyprland 0.5x 的 **Lua 配置**（`Hyprland.usingLua` 时改用 `hl.dsp.*` 派发）。
- **niri**：Quickshell 0.3.x 没有 niri 服务，改用 `niri msg --json` 查询 + `niri msg event-stream`
  作为变更信号，并保留 3 秒低频轮询与事件流断线重连作为保险。
- 侦测顺序：`NIRI_SOCKET` 优先（niri 嵌套在 Hyprland 里时两者都会存在），其次 `HYPRLAND_INSTANCE_SIGNATURE`。

---

## 已知限制

- **niri**：不支持 Hyprland 的 global shortcut 协议，`GlobalShortcut` 只会在 Hyprland 生效；niri 请用 IPC 绑定。
- **模糊**：不使用合成器 blur（面板是半透明 + 金线细框），所以在任何合成器上表现一致，也不会拖慢性能。
- **通知**：同一时间只能有一个 `org.freedesktop.Notifications` 服务；若其他外壳已占用，GF-shell 的通知会等对方退出后才接手。
- **多屏幕**：状态栏、桌面 HUD、梯队会为每个屏幕各建一份；全屏覆盖层建立在当前聚焦的屏幕上。
- **托盘**：部分程序的 StatusNotifierItem 图标不标准，会显示为圆点占位符。
- **截图**：依赖 `grim`（Wayland）；`wf-recorder` 用于录屏。

---

## 授权与致谢

- 代码：MIT（见 `LICENSE`）。
- 附带字体：SIL Open Font License 1.1（Chakra Petch、Saira Condensed、Rajdhani、Share Tech Mono）与
  Apache License 2.0（Material Symbols Rounded）；详见 `assets/fonts/LICENSES.md`。
- 视觉风格为对《少女前线》（Girls' Frontline）**公开界面风格**的致敬与再诠释；
  本项目不包含、也不散布任何游戏原始美术素材、标志或字体。
- 架构上参考了使用者本机的 end4-pC（end-4 dots-hyprland 的 Quickshell 移植）与常见 Quickshell 外壳的服务层做法，
  但所有 UI 与素材皆为本项目重新编写 / 生成。
