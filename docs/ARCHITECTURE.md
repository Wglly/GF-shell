# 架構

**繁體中文** · [简体中文](ARCHITECTURE.zh-CN.md) · [English](ARCHITECTURE.en.md) · [日本語](ARCHITECTURE.ja.md) · [Index](i18n.md)

GF-shell 是單一 Quickshell 設定：`shell.qml` 建立所有視窗，服務層負責與系統對話，
`Theme.qml` 是唯一的視覺真相來源。沒有 C++ 外掛、沒有編譯步驟、沒有網路依賴。

```
                     ┌──────────────────────────────────────────────┐
                     │                 shell.qml                    │
                     │  FontLoader × 10 · Binding 主題 · GlobalShortcut │
                     │  IpcHandler · Variants(螢幕) · 覆蓋層實例      │
                     └───────────────┬──────────────────────────────┘
                                     │
          ┌──────────────────────────┼───────────────────────────────┐
          ▼                          ▼                               ▼
 ┌─────────────────┐      ┌────────────────────┐         ┌──────────────────┐
 │  services/*.qml │      │ modules/common/*   │         │  modules/<模組>   │
 │ 系統狀態 (單例)  │◀────▶│ Theme / ShellState │◀───────▶│ Bar / Launcher … │
 └────────┬────────┘      │ Util / Gf* widgets │         └──────────────────┘
          │               └────────────────────┘
          ▼
 Quickshell 服務 (Pipewire / UPower / Mpris / Networking / Bluetooth /
 SystemTray) · hyprctl / niri msg · /proc · brightnessctl · grim
```

## 視窗層級（layer-shell）

| 視窗 | layer | 說明 |
| --- | --- | --- |
| `Wallpaper` | `Background` | 每螢幕一張壁紙 + 半調網點 + 等高線 + 噪點 + 角落讀數 |
| `DesktopHud` | `Bottom` | 時鐘、生命徵象、通訊、當前任務（`bottom` 會被一般視窗蓋住） |
| `Bar` | `Top` | 狀態列，`exclusiveZone = 高度`，讓視窗避開 |
| `Dock` | `Top` | 梯隊條，`exclusionMode = Ignore`，不推開視窗 |
| `Launcher` / `ControlCenter` / `Overview` / `PowerMenu` / `SettingsWindow` / `Calendar` | `Overlay` | 全螢幕或局部覆蓋層 |
| `Osd` / `Toasts` | `Overlay` | 短暫 HUD |

`ShellState.overlay` 是全域狀態機（`none` / `launcher` / `control` / `overview` / `power` /
`settings` / `calendar`）。同一時間只會有一個覆蓋層可見，`open()` 會先關閉上一個。

## 服務層

| 檔案 | 職責 |
| --- | --- |
| `Compositor.qml` | Hyprland / niri 統一 API：`workspaces`、`windows`、`focusedId`、`windowTitle`、`windowAppId`、`focusWorkspace(id)`、`focusWindow(key)`、`step(delta)`、`backend` |
| `Settings.qml` | `config.json` 讀寫、預設值、`presets`、`set/get/toggle`、防抖保存 |
| `ShellState.qml` | 覆蓋層狀態、OSD 觸發、設置分頁、桌面 HUD 可見性 |
| `Theme.qml` | 色彩/字型/間距/動畫時長 token 與 `alpha/mix/shade` 工具 |
| `Apps.qml` | 掃描 `.desktop`（Name/Exec/Icon/NoDisplay），`launch()`、`findByClass()` |
| `Audio.qml` | 預設 sink 音量/靜音，變更時觸發 OSD |
| `Battery.qml` | UPower 顯示裝置：電量、充電、預估時間、圖示 |
| `Net.qml` | NetworkManager：Wi-Fi 開關、SSID、信號段、有線/離線 |
| `Media.qml` | MPRIS：標題/演出者/封面/進度/播放控制 |
| `Notifs.qml` | NotificationServer、toast 佇列、歷史、DND、7 秒回收 |
| `Stats.qml` | CPU / MEM / 磁碟 / 網路速率 / uptime / load / 行程數 |
| `System.qml` | `brightnessctl`、鎖定/休眠/重啟/關機/登出、`Compositor` 的退出 |
| `Capture.qml` | grim + slurp 截圖、wf-recorder 錄影 |
| `Wallpapers.qml` | 內建壁紙清單、選擇、隨機 |
| `I18n.qml` | 英文 / 繁中字串表 |

服務之間允許互相引用（例如 `Audio` 呼叫 `ShellState.flashOsd()`）；
UI 只讀服務的唯讀屬性，寫入一律走服務的方法。

## Hyprland 細節

- 使用 `Quickshell.Hyprland`：`Hyprland.workspaces`、`Hyprland.toplevels`、`activeToplevel`、
  `focusedMonitor`，全部事件驅動，沒有輪詢。
- Hyprland 0.5x 可跑 Lua 設定；`Hyprland.usingLua` 為真時，派發要用 `hl.dsp.*` 語法
  （見 `Compositor.focusWorkspace()` 與 `System.quitCompositor()`）。
- `GlobalShortcut`（appid `gf-shell`）只在此後端生效。

## niri 細節

Quickshell 0.3.x 沒有 niri 服務，因此：

- 狀態用 `niri msg --json workspaces` / `windows` / `focused-window` 查詢；
- `niri msg event-stream` 當作變更信號（不解析 payload，只拿來觸發查詢）；
- 事件流斷線會 1s 後重連，另有 3s 低頻輪詢兜底；
- 動作走 `niri msg action focus-workspace <idx>` / `focus-window --id` / `move-window-to-workspace`；
- 偵測順序：`NIRI_SOCKET` 優先（nested niri 在 Hyprland 裡時兩者都存在）。

## 新增覆蓋層的最小步驟

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

1. 在 `shell.qml` 加入 `Foo {}`（並 `import qs.modules.foo`）。
2. `ShellState.toggle("foo")` 即可開啟；IPC 與 `GF_OVERLAY` 自動支援。
3. 需要鍵盤：把焦點放在一個 `focus: true` 的 `Item`，用 `Keys.onPressed` 處理 Esc。

## 設計系統

`modules/common/widgets/` 是 GF 的 UI 原語：

| 元件 | 用途 |
| --- | --- |
| `GfFrame` | 切角面板（填色、描邊、掃描線、斜紋、四角括標、頂部/左側強調線） |
| `GfText` / `GfLabel` / `GfSectionHeader` | 字體角色（ui/display/mono/label）與標題 |
| `GfButton` / `GfIconButton` / `GfToggle` / `GfSlider` / `GfTextField` / `GfKeyCap` | 控制項 |
| `GfMeter` / `GfGauge` / `GfDivider` / `GfCorners` / `GfHex` | 儀表與裝飾 |

所有面板都用「切角多邊形 + 1px 描邊」畫在 `QtQuick.Shapes` 上（`Shape.CurveRenderer`），
沒有貼圖、沒有模糊、沒有 Qt5Compat 依賴。

## 效能

- 常駐程序只有一個 `qs`；服務層的輪詢：`Stats` 1s、niri 兜底 3s、其餘事件驅動。
- 不用合成器 blur；掃描線/噪點/斜紋都是 1–4 px 的 tile PNG。
- 動畫只在 hover/展開時觸發，`theme.animations = false` 可全部關閉。
- 圖示字型是子集（~1 MB），壁紙 4 張 PNG（每張 ~2.5 MB）。

## 近期新增模組（2026-11）

- `services/Lyrics.qml`、`Weather.qml`、`Visualizer.qml`、`User.qml`：歌詞、天氣、cava、操作員。
- `modules/sidebars/`：`SidebarPanel` / `SidebarTrigger` + `components/` 11 個可拆裝組件；
  高度（0.4–1.0）、上/中/下對齊與滾動都在 `SidebarPanel` 內處理。
- `modules/bar/BarPopup.qml`：狀態列錨定彈出欄；`blocks/UserBlock.qml` 為操作員入口。
- `modules/settings/Sg*.qml`：紙白/黑線/黃色懸停的設定 UI 元件；`SettingsWindow` 提供 8 個分頁。
- `assets/shaders/glass.frag(.qsb)`：面板的壁紙採樣 blur/desaturate shader。
- `docs/PROGRESS.md`：功能矩陣、全部截圖與已知限制。
