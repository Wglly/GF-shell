# 安装与整合

[繁體中文](INSTALL.md) · **简体中文** · [English](INSTALL.en.md) · [日本語](INSTALL.ja.md) · [Index](i18n.md)

## 1. 依赖

```bash
# Arch / CachyOS
sudo pacman -S quickshell qt6-declarative qt6-svg qt6-wayland \
               pipewire wireplumber upower networkmanager bluez \
               brightnessctl grim slurp wl-clipboard wf-recorder
```

| 功能 | 需要 |
| --- | --- |
| 外壳本体 | `quickshell` ≥ 0.3 |
| 音量 | PipeWire + WirePlumber（`Quickshell.Services.Pipewire`） |
| 电池 | UPower |
| 网络 | NetworkManager（`Quickshell.Networking`） |
| 蓝牙 | BlueZ（`Quickshell.Bluetooth`） |
| 亮度 | `brightnessctl` |
| 截图 / 录屏 | `grim`、`slurp`、`wf-recorder`、`wl-clipboard` |

缺少可选工具时，对应的滑条/开关会自动隐藏或禁用，不会报错。

字体全部附带，**不需要**安装到系统。若想让其他程序也用：

```bash
mkdir -p ~/.local/share/fonts
cp assets/fonts/*.ttf ~/.local/share/fonts/
fc-cache -f
```

## 2. 安装

```bash
./install.sh                 # 复制到 ~/.config/quickshell/gf-shell
./install.sh --link          # 符号链接（开发时改文件立即生效）
./install.sh --dest /path    # 自定义位置
```

不安装也可以：

```bash
qs -p "$PWD"
```

> Quickshell 以 `~/.config/quickshell/<name>/shell.qml` 识别具名配置，
> `qs -c gf-shell` 就是读取 `~/.config/quickshell/gf-shell/`。

## 3. 开机自启

### Hyprland 0.5x（Lua 配置）

```lua
-- ~/.config/hypr/custom/execs.lua
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c gf-shell")
end)
```

### Hyprland 传统配置

```ini
exec-once = qs -c gf-shell
```

### niri

```kdl
// ~/.config/niri/config.kdl
spawn-at-startup "qs" "-c" "gf-shell"
```

### 先停止其他外壳

GF-shell 会建立自己的状态栏（exclusive zone）。若同时运行 end4-pC / caelestia / waybar，
会出现两条 bar 或 38 + 50 px 的双重保留区。请先禁用旧外壳的自启。

```bash
# 确认是否还有其他 quickshell 在运行
pgrep -af quickshell
```

## 4. 快捷键

### Hyprland（Lua）

```lua
hl.bind("SUPER + Space",     hl.dsp.global("gf-shell:launcher"))
hl.bind("SUPER + Tab",       hl.dsp.global("gf-shell:overview"))
hl.bind("SUPER + SHIFT + C", hl.dsp.global("gf-shell:control"))
hl.bind("SUPER + SHIFT + P", hl.dsp.global("gf-shell:power"))
hl.bind("PRINT",             hl.dsp.global("gf-shell:screenshot"))
```

### Hyprland（传统）

```ini
bind = SUPER, Space, global, gf-shell:launcher
bind = SUPER, Tab, global, gf-shell:overview
bind = SUPER SHIFT, C, global, gf-shell:control
bind = SUPER SHIFT, P, global, gf-shell:power
bind = , Print, global, gf-shell:screenshot
```

### niri

niri 不支持 `hyprland_global_shortcuts_v1`，请用 IPC：

```kdl
Mod+Space { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "launcher"; }
Mod+Tab   { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "overview"; }
Mod+Alt+C { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "control"; }
Mod+Alt+P { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "power"; }
```

> `qs` 的 IPC 需要实例已启动；若外壳尚未加载，命令会回报 no running instance（可忽略）。

## 5. 屏幕 / 缩放

- 状态栏、桌面 HUD、梯队会为**每个屏幕**各建一份（`Variants` + `Quickshell.screens`）。
- 全屏覆盖层建立在当前聚焦的屏幕（`Compositor.outputName`）。
- UI 缩放：设置 → 外观 → `UI SCALE`，或 `theme.scale`（0.7–1.5）。
  只影响本外壳，不影响 Qt 全局 scaling。
- bar 高度：设置 → 状态栏 → `THICKNESS`（30–58 px）。

## 6. 疑难解答

| 症状 | 处理 |
| --- | --- |
| 启动后什么都没出现 | `qs -c gf-shell` 看终端输出；常见是 QML 加载错误（会打印文件与行号）。 |
| 两条 bar / 桌面被推下去 | 还有其他外壳在运行，禁用其自启或关闭它。 |
| 图标变成方块或字母 | 图标字体没有加载。确认 `assets/fonts/GFTacticalIcons.ttf` 存在且 `qs -c gf-shell` 是从安装目录启动。 |
| 音量条一直是 0% | 没有 PipeWire sink（蓝牙耳机未连 / 音频服务未启动）。 |
| 亮度滑条不见 | 没装 `brightnessctl` 或没有背光设备。 |
| 通知不出现 | 已有其他程序占用 `org.freedesktop.Notifications`（例如另一个 shell）；等它结束后会自动接手，或先禁用它。 |
| niri 上按快捷键没反应 | niri 不支持 Hyprland global shortcut，请照上节用 IPC 绑定。 |
| 托盘图标是圆点 | 该程序的 StatusNotifierItem 图标不标准（例如部分 Wine / Flatpak 应用）。 |
| 想恢复预设 | 删除 `~/.config/gf-shell/config.json` 后重启外壳。 |

调试辅助：

```bash
GF_OVERLAY=launcher qs -c gf-shell    # 启动即打开启动器
GF_TAB=2 qs -c gf-shell               # 设置直接开到第 3 个分页
GF_DEBUG=icons qs -c gf-shell         # 显示全部图标，检查字体
GF_DEBUG=gauge qs -c gf-shell         # 显示仪表测试页
GF_DEBUG=osd qs -c gf-shell           # 固定显示音量 OSD
GF_DEBUG=toast qs -c gf-shell         # 显示一则测试通讯
```

Quickshell 的完整日志：`/run/user/$UID/quickshell/by-id/<id>/log.qslog`。
