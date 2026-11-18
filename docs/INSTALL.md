# 安裝與整合

**繁體中文** · [简体中文](INSTALL.zh-CN.md) · [English](INSTALL.en.md) · [日本語](INSTALL.ja.md) · [Index](i18n.md)

## 1. 依賴

```bash
# Arch / CachyOS
sudo pacman -S quickshell qt6-declarative qt6-svg qt6-wayland \
               pipewire wireplumber upower networkmanager bluez \
               brightnessctl grim slurp wl-clipboard wf-recorder
```

| 功能 | 需要 |
| --- | --- |
| 外殼本體 | `quickshell` ≥ 0.3 |
| 音量 | PipeWire + WirePlumber（`Quickshell.Services.Pipewire`） |
| 電池 | UPower |
| 網路 | NetworkManager（`Quickshell.Networking`） |
| 藍牙 | BlueZ（`Quickshell.Bluetooth`） |
| 亮度 | `brightnessctl` |
| 截圖 / 錄影 | `grim`、`slurp`、`wf-recorder`、`wl-clipboard` |

缺少可選工具時，對應的滑條/開關會自動隱藏或停用，不會報錯。

字型全部隨附，**不需要**安裝到系統。若想讓其他程式也用：

```bash
mkdir -p ~/.local/share/fonts
cp assets/fonts/*.ttf ~/.local/share/fonts/
fc-cache -f
```

## 2. 安裝

```bash
./install.sh                 # 複製到 ~/.config/quickshell/gf-shell
./install.sh --link          # 符號連結（開發時改檔案立即生效）
./install.sh --dest /path    # 自訂位置
```

不安裝也可以：

```bash
qs -p "$PWD"
```

> Quickshell 以 `~/.config/quickshell/<name>/shell.qml` 辨識具名設定，
> `qs -c gf-shell` 就是讀取 `~/.config/quickshell/gf-shell/`。

## 3. 開機自啟

### Hyprland 0.5x（Lua 設定）

```lua
-- ~/.config/hypr/custom/execs.lua
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c gf-shell")
end)
```

### Hyprland 傳統設定

```ini
exec-once = qs -c gf-shell
```

### niri

```kdl
// ~/.config/niri/config.kdl
spawn-at-startup "qs" "-c" "gf-shell"
```

### 先停止其他外殼

GF-shell 會建立自己的狀態列（exclusive zone）。若同時跑 end4-pC / caelestia / waybar，
會出現兩條 bar 或 38 + 50 px 的雙重保留區。請先停用舊外殼的自啟。

```bash
# 確認是否還有其他 quickshell 在跑
pgrep -af quickshell
```

## 4. 快捷鍵

### Hyprland（Lua）

```lua
hl.bind("SUPER + Space",     hl.dsp.global("gf-shell:launcher"))
hl.bind("SUPER + Tab",       hl.dsp.global("gf-shell:overview"))
hl.bind("SUPER + SHIFT + C", hl.dsp.global("gf-shell:control"))
hl.bind("SUPER + SHIFT + P", hl.dsp.global("gf-shell:power"))
hl.bind("PRINT",             hl.dsp.global("gf-shell:screenshot"))
```

### Hyprland（傳統）

```ini
bind = SUPER, Space, global, gf-shell:launcher
bind = SUPER, Tab, global, gf-shell:overview
bind = SUPER SHIFT, C, global, gf-shell:control
bind = SUPER SHIFT, P, global, gf-shell:power
bind = , Print, global, gf-shell:screenshot
```

### niri

niri 不支援 `hyprland_global_shortcuts_v1`，請用 IPC：

```kdl
Mod+Space { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "launcher"; }
Mod+Tab   { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "overview"; }
Mod+Alt+C { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "control"; }
Mod+Alt+P { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "power"; }
```

> `qs` 的 IPC 需要實例已啟動；若外殼尚未載入，指令會回報 no running instance（可忽略）。

## 5. 螢幕 / 縮放

- 狀態列、桌面 HUD、梯隊會為**每個螢幕**各建一份（`Variants` + `Quickshell.screens`）。
- 全螢幕覆蓋層建立在目前聚焦的螢幕（`Compositor.outputName`）。
- UI 縮放：設置 → 外觀 → `UI SCALE`，或 `theme.scale`（0.7–1.5）。
  只影響本外殼，不影響 Qt 全域 scaling。
- bar 高度：設置 → 狀態列 → `THICKNESS`（30–58 px）。

## 6. 疑難排解

| 症狀 | 處理 |
| --- | --- |
| 啟動後什麼都沒出現 | `qs -c gf-shell` 看終端輸出；常見是 QML 載入錯誤（會印出檔案與行號）。 |
| 兩條 bar / 桌面被推下去 | 還有其他外殼在跑，停用其自啟或關閉它。 |
| 圖示變成方塊或字母 | 圖示字型沒有載入。確認 `assets/fonts/GFTacticalIcons.ttf` 存在且 `qs -c gf-shell` 是從安裝目錄啟動。 |
| 音量條一直是 0% | 沒有 PipeWire sink（藍牙耳機未連 / 音效服務未啟動）。 |
| 亮度滑條不見 | 沒裝 `brightnessctl` 或沒有背光裝置。 |
| 通知不出現 | 已有其他程式佔用 `org.freedesktop.Notifications`（例如另一個 shell）；等它結束後會自動接手，或先停用它。 |
| niri 上按快捷鍵沒反應 | niri 不支援 Hyprland global shortcut，請照上節用 IPC 綁定。 |
| 托盤圖示是圓點 | 該程式的 StatusNotifierItem 圖示不標準（例如部分 Wine / Flatpak 應用）。 |
| 想回復預設 | 刪除 `~/.config/gf-shell/config.json` 後重啟外殼。 |

除錯輔助：

```bash
GF_OVERLAY=launcher qs -c gf-shell    # 啟動即打開啟動器
GF_TAB=2 qs -c gf-shell               # 設置直接開到第 3 個分頁
GF_DEBUG=icons qs -c gf-shell         # 顯示全部圖示，檢查字型
GF_DEBUG=gauge qs -c gf-shell         # 顯示儀表測試頁
GF_DEBUG=osd qs -c gf-shell           # 固定顯示音量 OSD
GF_DEBUG=toast qs -c gf-shell         # 顯示一則測試通訊
```

Quickshell 的完整日誌：`/run/user/$UID/quickshell/by-id/<id>/log.qslog`。
