# 架构

[繁體中文](ARCHITECTURE.md) · **简体中文** · [English](ARCHITECTURE.en.md) · [日本語](ARCHITECTURE.ja.md) · [Index](i18n.md)

GF-shell 是单一 Quickshell 配置：`shell.qml` 建立所有窗口，服务层负责与系统对话，
`Theme.qml` 是唯一的视觉真相来源。没有 C++ 插件、没有编译步骤、没有网络依赖。

```
                     ┌──────────────────────────────────────────────┐
                     │                 shell.qml                    │
                     │  FontLoader × 10 · 主题 Binding · GlobalShortcut │
                     │  IpcHandler · Variants(屏幕) · 覆盖层实例      │
                     └───────────────┬──────────────────────────────┘
                                     │
          ┌──────────────────────────┼───────────────────────────────┐
          ▼                          ▼                               ▼
 ┌─────────────────┐      ┌────────────────────┐         ┌──────────────────┐
 │  services/*.qml │      │ modules/common/*   │         │  modules/<模块>   │
 │ 系统状态 (单例)  │◀────▶│ Theme / ShellState │◀───────▶│ Bar / Launcher … │
 └────────┬────────┘      │ Util / Gf* widgets │         └──────────────────┘
          │               └────────────────────┘
          ▼
 Quickshell 服务 (Pipewire / UPower / Mpris / Networking / Bluetooth /
 SystemTray) · hyprctl / niri msg · /proc · brightnessctl · grim
```

## 窗口层级（layer-shell）

| 窗口 | layer | 说明 |
| --- | --- | --- |
| `Wallpaper` | `Background` | 每屏幕一张壁纸 + 半调网点 + 等高线 + 噪点 + 角落读数 |
| `DesktopHud` | `Bottom` | 时钟、生命体征、通讯、当前任务（`bottom` 会被普通窗口盖住） |
| `Bar` | `Top` | 状态栏，`exclusiveZone = 高度`，让窗口避开 |
| `Dock` | `Top` | 梯队条，`exclusionMode = Ignore`，不推开窗口 |
| `Launcher` / `ControlCenter` / `Overview` / `PowerMenu` / `SettingsWindow` / `Calendar` | `Overlay` | 全屏或局部覆盖层 |
| `Osd` / `Toasts` | `Overlay` | 短暂 HUD |

`ShellState.overlay` 是全局状态机（`none` / `launcher` / `control` / `overview` / `power` /
`settings` / `calendar`）。同一时间只有一个覆盖层可见，`open()` 会先关闭上一个。

## 服务层

| 文件 | 职责 |
| --- | --- |
| `Compositor.qml` | Hyprland / niri 统一 API：`workspaces`、`windows`、`focusedId`、`windowTitle`、`windowAppId`、`focusWorkspace(id)`、`focusWindow(key)`、`step(delta)`、`backend` |
| `Settings.qml` | `config.json` 读写、预设值、`presets`、`set/get/toggle`、防抖保存 |
| `ShellState.qml` | 覆盖层状态、OSD 触发、设置分页、桌面 HUD 可见性 |
| `Theme.qml` | 颜色/字体/间距/动画时长 token 与 `alpha/mix/shade` 工具 |
| `Apps.qml` | 扫描 `.desktop`（Name/Exec/Icon/NoDisplay），`launch()`、`findByClass()` |
| `Audio.qml` | 默认 sink 音量/静音，变更时触发 OSD |
| `Battery.qml` | UPower 显示设备：电量、充电、预计时间、图标 |
| `Net.qml` | NetworkManager：Wi-Fi 开关、SSID、信号段、有线/离线 |
| `Media.qml` | MPRIS：标题/演出者/封面/进度/播放控制 |
| `Notifs.qml` | NotificationServer、toast 队列、历史、DND、7 秒回收 |
| `Stats.qml` | CPU / MEM / 磁盘 / 网络速率 / uptime / load / 进程数 |
| `System.qml` | `brightnessctl`、锁定/休眠/重启/关机/登出、`Compositor` 的退出 |
| `Capture.qml` | grim + slurp 截图、wf-recorder 录屏 |
| `Wallpapers.qml` | 内置壁纸清单、选择、随机 |
| `I18n.qml` | 英文 / 繁体中文字符串表 |

服务之间允许互相引用（例如 `Audio` 调用 `ShellState.flashOsd()`）；
UI 只读服务的只读属性，写入一律走服务的方法。

## Hyprland 细节

- 使用 `Quickshell.Hyprland`：`Hyprland.workspaces`、`Hyprland.toplevels`、`activeToplevel`、
  `focusedMonitor`，全部事件驱动，没有轮询。
- Hyprland 0.5x 可运行 Lua 配置；`Hyprland.usingLua` 为真时，派发要用 `hl.dsp.*` 语法
  （见 `Compositor.focusWorkspace()` 与 `System.quitCompositor()`）。
- `GlobalShortcut`（appid `gf-shell`）只在此后端生效。

## niri 细节

Quickshell 0.3.x 没有 niri 服务，因此：

- 状态用 `niri msg --json workspaces` / `windows` / `focused-window` 查询；
- `niri msg event-stream` 当作变更信号（不解析 payload，只用来触发查询）；
- 事件流断线会 1s 后重连，另有 3s 低频轮询兜底；
- 动作走 `niri msg action focus-workspace <idx>` / `focus-window --id` / `move-window-to-workspace`；
- 侦测顺序：`NIRI_SOCKET` 优先（嵌套 niri 在 Hyprland 里时两者都存在）。

## 新增覆盖层的最小步骤

```qml
// modules/foo/Foo.qml
PanelWindow {
    readonly property bool open: ShellState.overlay === "foo"
    visible: open
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    GfFrame { /* … */ }
}
```

1. 在 `shell.qml` 加入 `Foo {}`（并 `import qs.modules.foo`）。
2. `ShellState.toggle("foo")` 即可打开；IPC 与 `GF_OVERLAY` 自动支持。
3. 需要键盘：把焦点放在一个 `focus: true` 的 `Item`，用 `Keys.onPressed` 处理 Esc。

## 设计系统

`modules/common/widgets/` 是 GF 的 UI 原语：

| 组件 | 用途 |
| --- | --- |
| `GfFrame` | 切角面板（填色、描边、扫描线、斜纹、四角括标、顶部/左侧强调线） |
| `GfText` / `GfLabel` / `GfSectionHeader` | 字体角色（ui/display/mono/label）与标题 |
| `GfButton` / `GfIconButton` / `GfToggle` / `GfSlider` / `GfTextField` / `GfKeyCap` | 控件 |
| `GfMeter` / `GfGauge` / `GfDivider` / `GfCorners` / `GfHex` | 仪表与装饰 |

所有面板都用「切角多边形 + 1px 描边」画在 `QtQuick.Shapes` 上（`Shape.CurveRenderer`），
没有贴图、没有模糊、没有 Qt5Compat 依赖。

## 性能

- 常驻进程只有一个 `qs`；服务层的轮询：`Stats` 1s、niri 兜底 3s、其余事件驱动。
- 不用合成器 blur；扫描线/噪点/斜纹都是 1–4 px 的 tile PNG。
- 动画只在 hover/展开时触发，`theme.animations = false` 可全部关闭。
- 图标字体是子集（~1 MB），壁纸 4 张 PNG（每张 ~2.5 MB）。
