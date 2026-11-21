# Configuration reference

[繁體中文](CONFIG.md) · [简体中文](CONFIG.zh-CN.md) · **English** · [日本語](CONFIG.ja.md) · [Index](i18n.md)

Config file: `~/.config/gf-shell/config.json`
(uses `XDG_CONFIG_HOME` when it is set).

- The complete defaults are created on first start.
- Every action in the Adjutant config window is written immediately (250 ms debounce).
- After manual edits, restart the shell to apply them (some values rebind live).

## Full structure

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
    "hideMargin": 48,
    "avoid": true,
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
  "fonts": { "ui": "", "display": "", "mono": "", "label": "" },
  "cursor": { "theme": "", "size": 24 },
  "compositor": {
    "hypr": {
      "gapsIn": 5, "gapsOut": 10, "borderWidth": 1, "rounding": 8,
      "activeColor": "#e8bd4f", "inactiveColor": "#403a2e",
      "blur": true, "animations": true
    },
    "niri": {
      "gaps": 16, "borderWidth": 2, "focusWidth": 4, "radius": 12,
      "activeColor": "#e8bd4f", "inactiveColor": "#403a2e",
      "border": true, "focus": false
    }
  },
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

## Language

`language`: `auto` (follows `$LANG`), `zh_TW`, `zh_CN`, `en`, `ja`.
The Settings → System → Language selector switches live; every string bound to `I18n.t()` updates immediately.

## Status-bar blocks

| Value | Contents |
| --- | --- |
| `launcher` / `emblem` | G&K emblem block (click to open the deployment terminal) |
| `workspaces` | Echelon/workspace numbers; scroll to cycle, click to switch |
| `title` | Active window's appId + title |
| `clock` | Centred clock + date + AM/PM (or H24); click for the calendar |
| `media` | Now-playing transmission + play/pause |
| `stats` | CPU / MEM segmented readout |
| `net` | Wi-Fi / wired + four signal bars + SSID; click for link details and nearby connectable Wi-Fi |
| `bluetooth` | Bluetooth state and connected count; click for adapter and known devices |
| `volume` | Volume; left click mutes, right click opens the control centre, scroll adjusts |
| `battery` | Charge / charging; turns red when low |
| `tray` | StatusNotifierItem icons |
| `overview` / `control` / `power` | The three entry buttons |

Auto-hide order on narrow screens: `title` → `media` → `stats` → `tray` → `net`.

## Theme presets

| preset | Description | Accent |
| --- | --- | --- |
| `gfl` | G&K standard: warm charcoal surfaces + matte gold | `#e8bd4f` |
| `sangvis` | Sangvis Ferri: near-black + alert red | `#d34a34` |
| `neural` | Neural Cloud: deep blue + ice cyan | `#7eb2d6` |
| `arctic` | Arctic: cool grey + pale gold | `#cbb98a` |
| `arknights` | Rhodes Island: near-black + industrial cyan + white | `#3fd4e6` |
| `bf4` | Battlefield 4: deep blue + scanlines + orange | `#2a8fb0` |
| `bf1` | Battlefield 1: aged paper + brass + dark red | `#c9a05a` |
| `hoi4` | Hearts of Iron IV: olive charcoal + brass + staff paper | `#c9a84f` |
| `light` | Daylight: neutral light grey + deep gold (light) | `#a97b18` |

A preset writes the whole `theme.*` palette, including `panel`, `line`, `text`…, so switching repaints
the entire UI immediately. Setting a custom `accent` changes `preset` to `custom`.

### Theme theatre maps

The desktop overview (OPERATION MAP) loads exactly one map background per `theme.preset`; the wallpaper and desktop widgets are untouched, and other themes load none:

| preset | Map |
| --- | --- |
| `hoi4` | `assets/maps/hoi4-world-mercator.png` (Mercator world) |
| `bf1` | `assets/maps/bf1-europe.png` (European fronts) |
| `bf4` | `assets/maps/bf4-world.png` (global network) |
| `arknights` | `assets/maps/arknights-rhodes.png` (Terra / Rhodes Island) |
| `gfl` / `sangvis` / `neural` / `arctic` | `assets/maps/gfl-world.png` (Continent operations) |

`modules/themes/ThemeMapBackground.qml` selects only the active theme's map; light mode loads none. The images are regenerated by `scripts/gen_theme_maps.py` from the local Natural Earth raster.

## Design tokens (`modules/common/Theme.qml`)

```qml
// fonts
fontUI      = "Chakra Petch"        // regular UI
fontDisplay = "Saira Condensed"     // large headings / numerals
fontMono    = "Share Tech Mono"     // data, IDs
fontLabel   = "Rajdhani"            // small uppercase labels

// core palette (black & gold)
bg0  #070708      panel      #141416      accent   #e8bd4f   (gold)
bg1  #0d0d0f      panelAlt   #1a1a1d      accent2  #6f9bc4   (steel)
line #403a2e      panelHi    #24242a      red      #d34a34
text #f2eee3      lineBright #c9a24a      ok       #8fc08a

// geometry
chamfer = 6px     border = 1px     barHeight = 38px
gap = 8px         pad = 12px       radius = 0
```

The UI always derives colours through `Theme.alpha(color, a)`, `Theme.mix()` and `Theme.shade()`, and
scales through `Theme.px()` / `Theme.fs()`.

## Desktop widget positions

`widgets.<name>.x` / `y` are **screen fractions** (0–1) with the origin at the top-left. For example:

```json
"clock":  { "x": 0.045, "y": 0.10 },
"stats":  { "x": 0.045, "y": 0.42 },
"media":  { "x": 0.70,  "y": 0.10 },
"mission":{ "x": 0.70,  "y": 0.78 }
```

While an overlay is open the desktop HUD fades out (`ShellState.overlay !== "none"`).


## Surfaces (bar / dock / sidebars)

All three surfaces share these fields:

| Field | Range | Meaning |
| --- | --- | --- |
| `opacity` | 0.3–1.0 | Background opacity |
| `gray` | 0–1 | Desaturate the wallpaper sample (1 = grayscale) |
| `blur` | 0–1 | Blur radius for the wallpaper sample (own shader; no compositor blur) |
| `width` / `iconSize` / `thickness` | — | Size (sidebar width / dock icon / bar height) |
| `position` | top / bottom | Which screen edge the bar and dock use |

## Sidebars and bar popups

- `sidebar.left`: operator file, calendar, squad roster, deploy.
- `sidebar.right`: media + lyrics (lrclib.net) + cava spectrum + notification log.
- Opening: pointer enters the screen-edge `trigger` (6 px default); closing: `delay` ms after leaving (650 default).
- Clicking `user` / `clock` / `media` in the bar opens an anchored panel for the operator / calendar / media.

## Dock avoidance

- With windows open the dock collapses to a 6 px gold line; it expands when the pointer reaches the bottom hot zone.
- While expanded, `exclusiveZone` equals the dock height, so the compositor pushes windows up.
- `dock.pinned` is an array of desktop file names; the dock shows pinned entries in order and appends running apps that are not pinned, up to `dock.maxItems` (default 12).
- Settings → Dock → “PIN AN APP” lets you type an app name and press Enter to pin it.
- Right-click a dock icon to pin/unpin it, open a new window or close it; the pin state is written back to `dock.pinned`.
- `dock.avoid` only controls window avoidance; `dock.autoHide` only controls hiding. They are independent.
- `dock.hideMargin` (0–240 px, default 48) is the collapse margin: the dock closes only after the pointer moves this far away from the screen edge.
- When the dock shares an edge with the bar, the 6 px edge line/indicator are drawn on the screen edge; the input `mask` only keeps the dock and edge line, so the rest of the bar remains clickable.
- `dock.position`: `top` / `bottom` / `left` / `right`; left/right are vertical side docks and `dock.align` becomes `top` / `center` / `bottom`.
- `dock.deployMode`: `launcher` / `dashboard`; default/checked option in the deploy button chooser.
- `terminal.command`: command used by the rose Terminal action; empty tries kitty/foot/alacritty/wezterm in order.

### Desktop command rose

Right-click empty desktop to open a seven-action command rose at the pointer (Settings, Wallpaper, Widget Layout, Deploy Terminal, Network, Terminal, Dashboard). Press 1–7 to select; left-click desktop or Esc closes. The four game themes have their own centre, rings and decoration, with **no full-screen dim layer**. `ThemeSignature`, `BarThemeAccent`, `CommandRose` and `Dashboard` extra styling is visible only for the matching preset.
- Controlled by `dock.avoid` (default true) and `dock.autoHide` (default false).
### Sidebar components

Settings → Sidebars → Components uses the same drag board as the bar: drag between left / right to reorder, or into OFF to hide. Order is stored in `sidebar.leftOrder` / `sidebar.rightOrder`, and `sidebar.assign.<id>` is kept in sync:

| id | content |
| --- | --- |
| `user` | operator card |
| `calendar` | month view |
| `roster` | squad roster |
| `actions` | deploy / tactical / config / halt |
| `stats` | CPU / MEM / NET / DISK |
| `weather` | wttr.in conditions |
| `clock` | large time and date |
| `media` | player + lyrics + spectrum |
| `visualizer` | cava spectrum |
| `comms` | recent notifications |
| `mission` | current mission |

`sidebar.<side>.height` (0.4–1.0) and `sidebar.<side>.align` (`top` / `center` / `bottom`) control the
panel height and vertical placement; the panel scrolls when its components do not fit.

### Bar components

`bar.left`, `bar.center`, `bar.right` are arrays of block ids. Settings → Status bar → Components is now an end-4pc-style drag board: drag chips into LEFT / CENTER / RIGHT to move and order them, or into OFF to disable. You can also click a chip, then press the LEFT / CENTER / RIGHT / OFF buttons above. The arrays are rewritten live.


### Desktop layout editor

- Open Settings → Widgets → Layout, press **EDIT DESKTOP LAYOUT**, hit `SUPER+SHIFT+W`, or run
  `qs -c gf-shell ipc call shell widgets`.
- The editor overlays a grid; drag a frame to move the widget, release to snap to the `widgets.grid`
  pixel grid.
- Each frame has an ON/OFF button in its top-right corner; widgets are dimmed and non-interactive
  while editing.
- Positions are stored as `widgets.<name>.x/y` screen fractions; `grid` accepts 16–96 px.
- Drag the bottom-right corner to resize; sizes are stored as `widgets.<name>.width/height`.
- `DONE` or `Esc` exits; `RESET` restores default positions and sizes.

## Theme modes, scaling and the settings surface

- `theme.mode`: `dark` / `light` / `custom`; presets (including `light`) set it automatically.
- `theme.fontScale` (0.8–1.4) scales text and popup/card layout; `theme.scale` (0.8–1.3) scales the whole shell
  (spacing, panels, icons and text).
- `theme.settingsOpacity` (0.5–1.0) and `theme.settingsGray` (0–1) control the **settings window's**
  translucent gray-white veil; the black rail and header stay opaque.
- Setting custom `bg0/bg1/bg/panel/text/accent/...` switches `mode` to `custom`. The wallpaper is
  washed toward paper white based on `bg0` luminance so dark text stays readable in light themes.
- Presets write the full palette; `scale`, `fontScale`, `settingsOpacity` are not overwritten.

- `dock.position`: `top` / `bottom` / `left` / `right`; left/right render a vertical side dock.
- `dock.align`: horizontal `left` / `center` / `right`; vertical `top` / `center` / `bottom`.
- `sidebar.<left|right>.triggerPosition`: `top` / `bottom`; the hot zone sits at the top or bottom corner.
- `sidebar.<left|right>.triggerWidth`: horizontal hot-zone width (60–420 px); `trigger` is its height.
- The `wallpaper` sidebar component can be assigned left/right in Settings → Sidebars → Components.
- `wallpaper.dir`: folder to import (png/jpg/jpeg/webp/avif/bmp). The bar and sidebar wallpaper libraries list every image.
- `user.avatar`: custom avatar path; BROWSE on the settings home copies it to `~/.config/gf-shell/avatar`.
- Light themes no longer tint the wallpaper with a paper-white wash; `wallpaper.dim` applies to dark themes.

## Typography

`fonts.ui` / `fonts.display` / `fonts.mono` / `fonts.label` select families for the interface, display/numbers, data and small labels. An empty string uses the bundled font (Chakra Petch / Saira Condensed / Share Tech Mono / Rajdhani).

Settings → Appearance → **TYPOGRAPHY** scans fontconfig with `fc-list`; pick a role, search, preview and click a family, or reset the role to the bundled font. The list is loaded by `services/Fonts.qml`.

## Pointer

`cursor.theme` / `cursor.size` store the selection. Settings → Appearance → **POINTER** scans `/usr/share/icons`, `~/.local/share/icons` and `~/.icons` for Xcursor themes with a `cursors/` directory; search and apply them live.

- Hyprland: `hyprctl setcursor`, with GTK `gsettings` kept in sync.
- niri: `scripts/niri-gf-cursor.py` updates the `cursor { xcursor-theme … }` block, backs it up, validates with `niri validate`, restores on failure, and niri auto-reloads.

## Compositor

Settings → System → **HYPRLAND / NIRI** shows the section for the running backend:

- **Hyprland**: inner/outer gaps, border width, rounding, active/inactive border colours, blur and animations. Changes are applied live with `hl.config` (or `hyprctl keyword` on non-Lua configs).
- **niri**: gaps, border/focus-ring width, window corner radius, colours and toggles. `scripts/niri-gf-settings.py` patches the layout block under `~/.config/niri/config.d/`, backs up each file as `*.gf-backup` on first change, validates with `niri validate`, restores backups on failure, and lets niri auto-reload.

Values live under `compositor.hypr.*` and `compositor.niri.*`; the niri radius is applied globally through a managed `window-rule`.

## Wallpaper

- Built-in: `assets/wallpapers/gfl-ops.png`, `gfl-sangvis`, `gfl-neural`, `gfl-dusk`.
- An empty `path` uses the first built-in wallpaper; you can also use `file:///home/user/wall.png` or an
  absolute path.
- `dim` (0–0.6) controls darkening; `fillMode`: `fill` (crop to fill), `fit`, `stretch`.
- Regenerate the built-in wallpapers with `python3 scripts/gen_assets.py`.
