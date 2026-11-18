# GF-shell

**A *Girls' Frontline*–inspired desktop shell built with Quickshell** · for **Hyprland** and **niri** · Wayland

![Desktop](docs/screenshots/01-desktop.png)

[繁體中文](README.md) · [简体中文](README.zh-CN.md) · **English** · [日本語](README.ja.md)

GF-shell is a desktop shell written from scratch with Quickshell (Qt Quick). Its visual language is
borrowed from *Girls' Frontline*'s publicly shown tactical UI: warm charcoal surfaces, matte gold accents,
small 45° chamfers, double frames (a gold hairline plus an inner white line), angled label ribbons,
halftone dots, segmented gauges and monospaced data type. Every graphic asset (wallpapers, emblem, textures, icon backing) is generated
procedurally by `scripts/gen_assets.py` — **no original game art is included**.

Documentation: [Install](docs/INSTALL.en.md) · [Configuration](docs/CONFIG.en.md) · [Architecture](docs/ARCHITECTURE.en.md) · [Design](docs/DESIGN.en.md) · [Progress](docs/PROGRESS.en.md) · [All languages](docs/i18n.md)

---

## Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Requirements](#requirements)
- [Install](#install)
- [Install](#install)
- [Autostart](#autostart)
- [Keybinds & IPC](#keybinds--ipc)
- [Configuration](#configuration)
- [Repository layout](#repository-layout)
- [Customization & theming](#customization--theming)
- [Asset generation](#asset-generation)
- [Dual compositor support](#dual-compositor-support)
- [Known limitations](#known-limitations)
- [License & credits](#license--credits)

---

## Features

| Module | Description |
| --- | --- |
| **Status bar** | G&K emblem block, operator entry, echelon/workspace numbers, active window title, centred clock, media, CPU/memory, network, Bluetooth, volume, battery, system tray, and entries for the operation map, tactical control and system halt. Secondary blocks are hidden automatically on narrow screens. Each block can be switched off and moved between left / centre / right in Settings → Status bar → Components. Network, Bluetooth and performance are independent blocks; click them for details, and the network panel lists nearby Wi-Fi networks. |
| **Deployment terminal (Launcher)** | Full-screen unit list with categories (all/recent/network/development/media/office/combat/system), fuzzy search, keyboard navigation, a unit dossier on the right (CLASS/STATUS/SOURCE/EXEC) and a DEPLOY button. |
| **Tactical control (Control Center)** | Link status (Wi-Fi/Bluetooth), segmented volume/brightness sliders, module switches, CPU/MEM/BAT segmented gauges, notification history and media controls. |
| **Operation map (Overview)** | One "sector" card per workspace listing its units; click a sector to switch workspaces, click a unit to focus its window; drag a unit onto another sector to move that window. |
| **System halt (Power)** | Lock / suspend / restart / shut down / log out. Dangerous actions need a second confirmation (ENTER twice); ESC cancels. |
| **HUD widgets** | Large clock, system vitals, transmission (with lyrics), weather, cava audio spectrum, operator card and current mission; each can be toggled. A **desktop layout editor** overlays a snap grid; drag widgets, resize from the bottom-right corner, and toggle each one ON/OFF. |
| **Echelon (Dock)** | Pinned and running units (up to 12), with running apps appended automatically; pin more by typing an app name in Settings → Dock. Right-click a unit to pin/unpin it, open a new window or close it. It hides while windows are open and expands when the pointer reaches the bottom hot zone, pushing windows away via an exclusive zone. Icon size / opacity / grayscale / blur are adjustable, and the hidden **trigger area is configurable (4–48 px)**. With **Avoid windows** off the dock stays fully visible; when hidden, only an invisible hot zone and a thin line remain, and the panel appears only on expansion. When the dock shares an edge with the bar, the hot zone/indicator sit on the bar and the dock body attaches to its inner edge instead of floating. |
| **Notifications** | "Incoming transmission" toasts in the top-right (slide in, auto-dismiss after 7 s, click to dismiss) plus history in the control centre. |
| **OSD** | Volume/brightness HUD with a segmented meter and a large readout. |
| **Calendar** | Schedule panel dropped from the clock: month navigation, today highlight, week number. |
| **Adjutant config (Settings)** | A GFL-style black-and-white panel: paper background, black rules, charcoal buttons that turn yellow on hover/selection. The background is a **translucent gray-white veil** with adjustable opacity/gray. Eight tabs (appearance/bar/dock/sidebars/widgets/wallpaper/system/about), **dark / light / custom palettes**, **shell scale** and **font scale**; every change is written immediately. |
| **Sidebars** | Left: operator file, calendar, squad roster. Right: media + lyrics + cava spectrum + notification log. Open from screen-edge hot zones, close after the pointer leaves. Every component can be assigned left / right / off in Settings → Sidebars → Components; height (40–100%) and top / centre / bottom alignment are adjustable. |
| **Bar popups** | Clicking the operator, clock or media block opens an anchored detail panel at that block (user / calendar / media are separate). |

Also:

- Five theme presets: **G&K STANDARD**, **SANGVIS FERRI**, **NEURAL CLOUD**, **ARCTIC OPS**, **DAYLIGHT OPS** (light); or choose DARK / LIGHT / CUSTOM and set BG0/BG1/PANEL/TEXT/ACCENT hex colours.
- Global scaling is split into `SHELL SCALE` (everything) and `FONT SCALE` (text plus popup/card layout); the settings veil has adjustable opacity and gray.
- One icon font (a Material Symbols subset renamed *GF Tactical Icons*, ~1 MB, so it never collides with a system font) and four bundled text fonts (Chakra Petch / Saira Condensed / Rajdhani / Share Tech Mono).
- Four interface languages: **Traditional Chinese / Simplified Chinese / English / Japanese**; switch live in Settings → System → Language (the settings window itself is translated too).
- Four built-in wallpapers plus any local image, with adjustable dimming.
- Bar, dock and sidebars expose **opacity, grayscale, blur, size and position**; blur is a wallpaper-sampling shader, so no compositor blur is required.
- Media cards (bar popup, sidebar, desktop) share lyrics (lrclib.net) and the cava spectrum.
- A single global state machine guarantees only one overlay is visible at a time.
- Built-in IPC: `qs -c gf-shell ipc call shell toggle <overlay>` for niri, scripts and keybinds.

---

## Screenshots

| Deployment terminal | Tactical control |
| --- | --- |
| ![Launcher](docs/screenshots/02-launcher.png) | ![Control](docs/screenshots/03-control-center.png) |

| Operation map | System halt |
| --- | --- |
| ![Overview](docs/screenshots/04-overview.png) | ![Power](docs/screenshots/05-power.png) |

| Adjutant config | Wallpaper |
| --- | --- |
| ![Settings](docs/screenshots/06-settings.png) | ![Wallpaper](docs/screenshots/07-settings-wallpaper.png) |

| Calendar popup | OSD | Notifications |
| --- | --- | --- |
| ![Calendar](docs/screenshots/14-bar-popup.png) | ![OSD](docs/screenshots/09-osd.png) | ![Toast](docs/screenshots/10-toast.png) |

| Left sidebar | Right sidebar |
| --- | --- |
| ![Sidebar left](docs/screenshots/12-sidebar-left.png) | ![Sidebar right](docs/screenshots/13-sidebar-right.png) |

| English interface | Japanese interface | Japanese sidebar |
| --- | --- | --- |
| ![English](docs/screenshots/15-settings-en.png) | ![Japanese](docs/screenshots/16-settings-ja.png) | ![Japanese sidebar](docs/screenshots/17-sidebar-ja.png) |

| Bar component editor | Sidebar component editor | Desktop grid layout |
| --- | --- | --- |
| ![Bar components](docs/screenshots/18-settings-bar.png) | ![Sidebar components](docs/screenshots/19-settings-sidebar.png) | ![Widget editor](docs/screenshots/20-widget-editor.png) |

| Light theme: desktop | Light theme: launcher | Settings: scale & surface |
| --- | --- | --- |
| ![Light desktop](docs/screenshots/21-light-desktop.png) | ![Light launcher](docs/screenshots/22-light-launcher.png) | ![Scale and surface](docs/screenshots/23-settings-appearance.png) |

| Network details & nearby Wi-Fi | Bluetooth details | Performance details |
| --- | --- | --- |
| ![Network popup](docs/screenshots/24-network-popup.png) | ![Bluetooth popup](docs/screenshots/25-bluetooth-popup.png) | ![Stats popup](docs/screenshots/26-stats-popup.png) |

The same shell running on **niri** (nested inside Hyprland for testing):

![niri](docs/screenshots/11-niri.png)

---

## Requirements

- **Quickshell ≥ 0.3** (Arch: `quickshell`)
- Qt 6: `qt6-declarative`, `qt6-svg`, `qt6-wayland`, `qt6-base`
- Wayland compositor: **Hyprland** or **niri** (both tested)
- Suggested tools (the matching feature disables itself when missing):
  - `pipewire` + `wireplumber`: volume
  - `brightnessctl`: brightness
  - `NetworkManager`: network toggle / SSID
  - `bluez`: Bluetooth toggle
  - `upower`: battery
  - `cava`: audio spectrum
  - `curl`: weather (wttr.in) and lyrics (lrclib.net)
  - `grim` / `slurp` / `wf-recorder`: screenshots and recording
  - `wl-clipboard`: copy screenshots
- Fonts: all bundled in `assets/fonts/`, no system installation required.

---

## Install

```bash
git clone <repo> GF-shell           # or use this directory as-is
cd GF-shell
./install.sh                        # copies to ~/.config/quickshell/gf-shell
# for development:
./install.sh --link                 # symlink; edits take effect immediately

qs -c gf-shell                      # start
```

You can also run it without installing:

```bash
qs -p /path/to/GF-shell
```

Uninstall:

```bash
rm -rf ~/.config/quickshell/gf-shell
rm -rf ~/.config/gf-shell
```

### Autostart

**Hyprland** (Lua config, 0.5x):

```lua
hl.exec_cmd("qs -c gf-shell")
```

**Hyprland** (classic `hyprland.conf`):

```ini
exec-once = qs -c gf-shell
```

**niri** (`~/.config/niri/config.kdl`):

```kdl
spawn-at-startup "qs" "-c" "gf-shell"
```

> If you already run another shell (end4-pC, caelestia, waybar…), disable its autostart and bar first,
> otherwise you will end up with two stacked bars.

---

## Keybinds & IPC

The shell registers Hyprland global shortcuts under the appid `gf-shell`. Add these binds to your
Hyprland configuration:

```lua
-- Hyprland 0.57 Lua config
hl.bind("SUPER + Space",      hl.dsp.global("gf-shell:launcher"),  { description = "GF-shell: deployment terminal" })
hl.bind("SUPER + ALT + TAB",  hl.dsp.global("gf-shell:overview"),  { description = "GF-shell: operation map" })
hl.bind("SUPER + SHIFT + C",  hl.dsp.global("gf-shell:control"),   { description = "GF-shell: tactical control" })
hl.bind("SUPER + SHIFT + P",  hl.dsp.global("gf-shell:power"),     { description = "GF-shell: system halt" })
hl.bind("PRINT",              hl.dsp.global("gf-shell:screenshot"),{ description = "GF-shell: screenshot" })
```

Classic configuration:

```ini
bind = SUPER, Space, global, gf-shell:launcher
bind = SUPER ALT, TAB, global, gf-shell:overview
bind = SUPER SHIFT, C, global, gf-shell:control
bind = SUPER SHIFT, P, global, gf-shell:power
bind = SUPER SHIFT, W, global, gf-shell:widgets
bind = , Print, global, gf-shell:screenshot
```

**niri** does not implement Hyprland's global-shortcut protocol, so use IPC instead:

```kdl
Mod+Space { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "launcher"; }
Mod+Alt+Tab { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "overview"; }
Mod+Shift+W { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "widgets"; }
```

> Note: `SUPER+Tab` may be taken by another shell (e.g. MC-shell); this project uses `SUPER+ALT+Tab`.
> If the shortcut does nothing, check `hyprctl globalshortcuts | grep gf-shell` for `gf-shell:overview`
> and make sure the same key is not bound twice (a duplicate toggles it open and closed).

IPC surface (`IpcHandler`, target `shell`):

```bash
qs -c gf-shell ipc call shell toggle launcher    # none|launcher|control|overview|power|settings|calendar
qs -c gf-shell ipc call shell open overview
qs -c gf-shell ipc call shell close
qs -c gf-shell ipc call shell widgets   # desktop widget layout editor
qs -c gf-shell ipc call shell volume 0.7   # set volume
qs -c gf-shell ipc call shell mute         # toggle mute
qs -c gf-shell ipc call shell status
```

| Overlay | `GF_OVERLAY` value | Purpose |
| --- | --- | --- |
| Deployment terminal | `launcher` | Search / launch applications |
| Tactical control | `control` | Links, volume, brightness, notifications |
| Operation map | `overview` | Workspaces and windows |
| System halt | `power` | Power actions |
| Adjutant config | `settings` | Settings window |
| Calendar | `calendar` | Schedule |

> Debug environment variables: `GF_OVERLAY=<overlay>` opens an overlay on startup; `GF_TAB=<0-7>`
> selects a settings tab; `GF_DEBUG=osd|toast|gauge|icons` shows the matching debug page
> (`modules/debug/`).

---

## Configuration

Config file: `~/.config/gf-shell/config.json` (created on first start).

| Section | Common keys |
| --- | --- |
| `bar` | `position`, `thickness`, `opacity`, `gray`, `blur`, `clock24h`, `showSeconds`, `left` / `center` / `right` (block order; OFF/LEFT/CENTER/RIGHT in Settings) |
| `sidebar` | `left`/`right`: `width`, `height` (0.4–1.0), `align` (top/center/bottom), `opacity`, `gray`, `blur`, `assign.<id>` (left/right/off) |
| `theme` | `preset` (incl. `light`), `mode` (dark/light/custom), `accent`, `accent2`, `bg0`, `bg1`, `panel`, `text`, `fontScale`, `settingsOpacity`, `settingsGray`, `scale`, `animations` |
| `wallpaper` | `enabled`, `path` (`file://` or empty = built-in), `fillMode`, `dim` |
| `dock` | `enabled`, `autoHide`, `avoid`, `trigger` (4–48 px hot zone), `iconSize`, `opacity`, `gray`, `blur`, `maxItems`, `pinned` |
| `widgets` | `grid` (snap pixels) plus per-widget `enabled`, `x`, `y`, `width`, `height` (drag the bottom-right corner in the layout editor) |
| `overview` | `columns`, `desktops`, `backdrop` |
| `notifications` | `dnd`, `toasts`, `maxToasts` |
| `osd` | `enabled` |
| `language` | `auto` / `zh_TW` / `zh_CN` / `en` / `ja` |

Available `bar.left/center/right` blocks:

```
launcher | emblem | user | workspaces | title | clock | media | stats | net | bluetooth | volume
| battery | tray | overview | control | power
```

Everything can be changed from the Adjutant config window; the file is written back immediately.

---

## Repository layout

```
GF-shell/
├── shell.qml                    # entry point: fonts, theme bindings, shortcuts, per-screen windows, IPC
├── install.sh
├── scripts/gen_assets.py        # wallpaper / emblem / texture generator (Pillow + numpy)
├── assets/
│   ├── fonts/                   # Chakra Petch, Saira Condensed, Rajdhani, Share Tech Mono, GFTacticalIcons
│   ├── icons/                   # emblem*.png (generated)
│   ├── textures/                # halftone / hatch / noise / scanlines
│   └── wallpapers/              # gfl-ops / gfl-sangvis / gfl-neural / gfl-dusk
├── services/                    # singleton service layer
│   ├── Compositor.qml           # unified Hyprland + niri workspace/window API
│   ├── Settings.qml             # config.json persistence and theme presets
│   ├── Audio / Battery / Net / Media / Notifs / Stats / System / Apps / Capture
│   ├── I18n.qml                 # English / Traditional Chinese strings
│   └── Wallpapers.qml
├── modules/
│   ├── common/                  # Theme.qml, ShellState.qml, Util.qml
│   │   └── widgets/             # Gf* design system: Frame / Button / Slider / Toggle / Gauge…
│   ├── bar/                     # status bar, blocks, calendar
│   ├── launcher/                # deployment terminal
│   ├── control/                 # tactical control
│   ├── overview/                # operation map
│   ├── power/                   # system halt
│   ├── widgets/                 # desktop HUD
│   ├── dock/                    # echelon strip
│   ├── notifications/           # transmission toasts
│   ├── osd/                     # volume/brightness HUD
│   ├── wallpaper/               # desktop background layer
│   ├── settings/                # adjutant config
│   └── debug/                   # debug pages used by GF_DEBUG
└── docs/                        # install, configuration, architecture, screenshots
```

**Data flow**: `services/*` subscribe to system state (Quickshell's Pipewire/UPower/Mpris/Networking/SystemTray,
`hyprctl` / `niri msg`). `modules/common/Theme.qml` is the single source of design tokens; the UI only reads
`Theme.*` and read-only service properties. State lives in `ShellState.qml`, writes go through `Settings.qml`.

---

## Customization & theming

- **Colours / spacing / type scale**: edit `modules/common/Theme.qml` only.
- **Theme presets**: the `presets` map in `services/Settings.qml`, or switch them in the settings window.
- **Add a status-bar block**:
  1. create `modules/bar/blocks/FooBlock.qml`;
  2. add a `foo` case to the `switch` in `modules/bar/BarItem.qml`;
  3. add `"foo"` to `bar.left/center/right` in the config.
- **Add an overlay**: create a `PanelWindow` (`WlrLayer.Overlay`) → show it when
  `ShellState.overlay === "name"` → instantiate it in `shell.qml`. `IpcHandler` / `GlobalShortcut`
  already support arbitrary names.
- **Change the wallpaper**: pick one in the settings window, or write a path into `wallpaper.path`. Official art is not bundled — use your own copy (see [design notes](docs/DESIGN.en.md)).

---

## Asset generation

```bash
python3 scripts/gen_assets.py
```

Requires `Pillow` and `numpy`. It regenerates:

- `assets/wallpapers/*.png` (1920×1080: warm charcoal, gold diagonal band, halftone dots, contours, isometric base line-art, crest watermark, thin gold frame)
- `assets/icons/emblem*.png`, `assets/icon.png`
- `assets/textures/*.png`

**The emblem is an original design** (hex frame + three stacked wing chevrons + command star). It is not
any official *Girls' Frontline* mark.

---

## Dual compositor support

`services/Compositor.qml` folds the differences between the two compositors into one API
(`workspaces`, `windows`, `focusedId`, `windowTitle`, `focusWorkspace()`, `focusWindow()`, `step()`):

- **Hyprland**: uses Quickshell's `Quickshell.Hyprland` service (event driven). It also handles Hyprland
  0.5x **Lua configurations** (dispatch through `hl.dsp.*` when `Hyprland.usingLua` is true).
- **niri**: Quickshell 0.3.x has no niri service, so GF-shell queries `niri msg --json` and uses
  `niri msg event-stream` as a change signal, with a 3 s low-frequency poll and event-stream
  reconnection as fallbacks.
- Detection order: `NIRI_SOCKET` first (both variables exist when niri is nested inside Hyprland),
  then `HYPRLAND_INSTANCE_SIGNATURE`.

---

## Known limitations

- **niri**: does not support Hyprland's global-shortcut protocol; `GlobalShortcut` only works on
  Hyprland. Use IPC binds on niri.
- **Blur**: no compositor blur is used (panels are translucent with gold hairlines), so the look is identical
  on every compositor and there is no performance hit.
- **Notifications**: only one `org.freedesktop.Notifications` service can exist at a time. If another
  shell holds it, GF-shell's notification server takes over once that shell exits.
- **Multi-monitor**: the bar, desktop HUD and dock are created once per screen; full-screen overlays are
  created on the currently focused screen.
- **Tray**: some applications expose non-conformant StatusNotifierItem icons and show up as dot
  placeholders.
- **Screenshots**: rely on `grim` (Wayland); `wf-recorder` handles recording.

---

## License & credits

- Code: MIT (see `LICENSE`).
- Bundled fonts: SIL Open Font License 1.1 (Chakra Petch, Saira Condensed, Rajdhani, Share Tech Mono)
  and Apache License 2.0 (Material Symbols Rounded). See `assets/fonts/LICENSES.md`.
- The visual style is a homage to and reinterpretation of *Girls' Frontline*'s **publicly shown interface
  style**. This project contains and distributes no original game art, logos or fonts.
- The architecture was informed by the local end4-pC configuration (the Quickshell port of end-4's
  dots-hyprland) and by common Quickshell shell service patterns, but all UI and assets here were
  written / generated for this project.
