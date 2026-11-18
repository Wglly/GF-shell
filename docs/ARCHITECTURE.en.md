# Architecture

[繁體中文](ARCHITECTURE.md) · [简体中文](ARCHITECTURE.zh-CN.md) · **English** · [日本語](ARCHITECTURE.ja.md) · [Index](i18n.md)

GF-shell is a single Quickshell configuration: `shell.qml` creates every window, the service layer talks
to the system, and `Theme.qml` is the only source of visual truth. There are no C++ plugins, no build
step and no network dependency.

```
                     ┌──────────────────────────────────────────────┐
                     │                 shell.qml                    │
                     │  FontLoader × 10 · theme Binding · GlobalShortcut │
                     │  IpcHandler · Variants(screens) · overlay instances │
                     └───────────────┬──────────────────────────────┘
                                     │
          ┌──────────────────────────┼───────────────────────────────┐
          ▼                          ▼                               ▼
 ┌─────────────────┐      ┌────────────────────┐         ┌──────────────────┐
 │  services/*.qml │      │ modules/common/*   │         │  modules/<module>│
 │  system state   │◀────▶│ Theme / ShellState │◀───────▶│ Bar / Launcher … │
 │  (singletons)   │      │ Util / Gf* widgets │         └──────────────────┘
 └────────┬────────┘      └────────────────────┘
          │
          ▼
 Quickshell services (Pipewire / UPower / Mpris / Networking / Bluetooth /
 SystemTray) · hyprctl / niri msg · /proc · brightnessctl · grim
```

## Window layers (layer-shell)

| Window | Layer | Purpose |
| --- | --- | --- |
| `Wallpaper` | `Background` | One wallpaper per screen + halftone + contours + grain + corner readouts |
| `DesktopHud` | `Bottom` | Clock, vitals, transmission, current mission (drawn below normal windows) |
| `Bar` | `Top` | Status bar; `exclusiveZone = height` so windows avoid it |
| `Dock` | `Top` | Echelon strip; `exclusionMode = Ignore`, so windows are not pushed away |
| `Launcher` / `ControlCenter` / `Overview` / `PowerMenu` / `SettingsWindow` / `Calendar` | `Overlay` | Full-screen or partial overlays |
| `Osd` / `Toasts` | `Overlay` | Transient HUD |

`ShellState.overlay` is the global state machine (`none` / `launcher` / `control` / `overview` /
`power` / `settings` / `calendar`). Only one overlay is visible at a time; `open()` closes the previous
one first.

## Service layer

| File | Responsibility |
| --- | --- |
| `Compositor.qml` | Unified Hyprland / niri API: `workspaces`, `windows`, `focusedId`, `windowTitle`, `windowAppId`, `focusWorkspace(id)`, `focusWindow(key)`, `step(delta)`, `backend` |
| `Settings.qml` | `config.json` persistence, defaults, `presets`, `set/get/toggle`, debounced saving |
| `ShellState.qml` | Overlay state, OSD triggers, settings tab, desktop HUD visibility |
| `Theme.qml` | Colour/font/spacing/animation tokens plus `alpha/mix/shade` helpers |
| `Apps.qml` | Scans `.desktop` files (Name/Exec/Icon/NoDisplay); `launch()`, `findByClass()` |
| `Audio.qml` | Default sink volume/mute; triggers the OSD on change |
| `Battery.qml` | UPower display device: charge, charging state, time estimate, glyph |
| `Net.qml` | NetworkManager: Wi-Fi toggle, SSID, signal bars, wired/offline |
| `Media.qml` | MPRIS: title/artist/art/progress/playback controls |
| `Notifs.qml` | NotificationServer, toast queue, history, DND, 7 s auto-dismiss |
| `Stats.qml` | CPU / MEM / disk / network rates / uptime / load / process count |
| `System.qml` | `brightnessctl`, lock/suspend/restart/shutdown/logout, compositor exit |
| `Capture.qml` | grim + slurp screenshots, wf-recorder recording |
| `Wallpapers.qml` | Built-in wallpaper list, selection, randomise |
| `I18n.qml` | English / Traditional Chinese string tables |

Services may reference each other (for example `Audio` calls `ShellState.flashOsd()`); the UI only reads
read-only service properties and writes exclusively through service methods.

## Hyprland details

- Uses `Quickshell.Hyprland`: `Hyprland.workspaces`, `Hyprland.toplevels`, `activeToplevel`,
  `focusedMonitor` — all event driven, no polling.
- Hyprland 0.5x can run Lua configs; when `Hyprland.usingLua` is true, dispatch must use `hl.dsp.*`
  (see `Compositor.focusWorkspace()` and `System.quitCompositor()`).
- `GlobalShortcut` (appid `gf-shell`) only works on this backend.

## niri details

Quickshell 0.3.x has no niri service, therefore:

- state is queried with `niri msg --json workspaces` / `windows` / `focused-window`;
- `niri msg event-stream` is used as a change signal only (payloads are not parsed);
- a dropped event stream reconnects after 1 s, and a 3 s low-frequency poll acts as a safety net;
- actions go through `niri msg action focus-workspace <idx>` / `focus-window --id` /
  `move-window-to-workspace`;
- detection order: `NIRI_SOCKET` first (a nested niri inside Hyprland has both variables).

## Minimal steps for a new overlay

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

1. Add `Foo {}` (and `import qs.modules.foo`) to `shell.qml`.
2. Open it with `ShellState.toggle("foo")`; IPC and `GF_OVERLAY` pick it up automatically.
3. For keyboard input, focus an `Item` with `focus: true` and handle Esc in `Keys.onPressed`.

## Design system

`modules/common/widgets/` holds the GF UI primitives:

| Component | Purpose |
| --- | --- |
| `GfFrame` | Chamfered panel (fill, border, scanlines, hatching, corner brackets, top/left accent lines) |
| `GfText` / `GfLabel` / `GfSectionHeader` | Type roles (ui/display/mono/label) and headings |
| `GfButton` / `GfIconButton` / `GfToggle` / `GfSlider` / `GfTextField` / `GfKeyCap` | Controls |
| `GfMeter` / `GfGauge` / `GfDivider` / `GfCorners` / `GfHex` | Gauges and decoration |

Every panel is drawn as a "chamfered polygon + 1 px border" with `QtQuick.Shapes`
(`Shape.CurveRenderer`) — no textures, no blur, no Qt5Compat dependency.

## Performance

- Only one resident `qs` process; service polling: `Stats` 1 s, niri fallback 3 s, everything else is
  event driven.
- No compositor blur; scanlines/grain/hatching are 1–4 px tiled PNGs.
- Animations only run on hover/expand and can be disabled entirely with `theme.animations = false`.
- The icon font is a subset (~1 MB); the four wallpapers are PNGs (~2.5 MB each).

## Recent modules (2026-11)

- `services/Lyrics.qml`, `Weather.qml`, `Visualizer.qml`, `User.qml`: lyrics, weather, cava, operator.
- `modules/sidebars/`: `SidebarPanel` / `SidebarTrigger` plus 11 swappable components in `components/`;
  height (0.4–1.0), top/center/bottom alignment and scrolling are handled by `SidebarPanel`.
- `modules/bar/BarPopup.qml`: anchored bar detail popups; `blocks/UserBlock.qml` is the operator entry.
- `modules/settings/Sg*.qml`: paper/black-lines/yellow-hover settings widgets; `SettingsWindow` has 8 tabs.
- `assets/shaders/glass.frag(.qsb)`: wallpaper-sampling blur/desaturate shader for panels.
- `docs/PROGRESS.md`: feature matrix, all screenshots and known limitations.
