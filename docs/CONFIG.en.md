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
    "right": ["media", "stats", "net", "volume", "battery", "tray",
              "overview", "control", "power"]
  },
  "dock": {
    "enabled": true,
    "position": "bottom",
    "autoHide": false,
    "avoid": true,
    "trigger": 24,
    "iconSize": 44,
    "size": 1.0,
    "opacity": 0.94,
    "gray": 0.0,
    "blur": 0.0,
    "maxItems": 9,
    "pinned": ["firefox.desktop", "kitty.desktop", "foot.desktop",
               "org.gnome.Nautilus.desktop", "code.desktop", "steam.desktop"]
  },
  "sidebar": {
    "left":  { "enabled": true, "width": 356, "height": 0.82, "align": "top",
               "opacity": 0.96, "gray": 0.0, "blur": 0.0,
               "autoHide": true, "delay": 650, "trigger": 6 },
    "right": { "enabled": true, "width": 372, "height": 0.88, "align": "top",
               "opacity": 0.96, "gray": 0.0, "blur": 0.0,
               "autoHide": true, "delay": 650, "trigger": 6 },
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
  "wallpaper": {
    "enabled": true,
    "path": "",
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
| `net` | Wi-Fi / wired + four signal bars + SSID |
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
| `light` | Daylight: paper white + deep gold (light) | `#b07d18` |

A preset writes the whole `theme.*` palette, including `panel`, `line`, `text`…, so switching repaints
the entire UI immediately. Setting a custom `accent` changes `preset` to `custom`.

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
- `dock.trigger` (4–48 px) is the hot-zone height while hidden; larger is easier to hit. While hidden the zone is transparent, the panel is fully hidden (only a 2 px indicator line remains) and the exclusive zone is 0.
- With `dock.avoid = false` the dock stays fully visible; `dock.autoHide` only applies while avoidance is on.
- Controlled by `dock.avoid` (default true) and `dock.autoHide` (default false).
### Sidebar components

Assign each component to a side, or turn it off, with `sidebar.assign.<id>` (`left` / `right` / `off`):

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

`bar.left`, `bar.center`, `bar.right` are arrays of block ids. In Settings → Status bar → Components, every
block can be set to OFF / LEFT / CENTER / RIGHT; the editor rewrites these arrays. OFF removes the block.


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
- `theme.fontScale` (0.8–1.4) scales text only; `theme.scale` (0.8–1.3) scales the whole shell
  (spacing, panels, icons and text).
- `theme.settingsOpacity` (0.5–1.0) and `theme.settingsGray` (0–1) control the **settings window's**
  translucent gray-white veil; the black rail and header stay opaque.
- Setting custom `bg0/bg1/bg/panel/text/accent/...` switches `mode` to `custom`. The wallpaper is
  washed toward paper white based on `bg0` luminance so dark text stays readable in light themes.
- Presets write the full palette; `scale`, `fontScale`, `settingsOpacity` are not overwritten.

## Wallpaper

- Built-in: `assets/wallpapers/gfl-ops.png`, `gfl-sangvis`, `gfl-neural`, `gfl-dusk`.
- An empty `path` uses the first built-in wallpaper; you can also use `file:///home/user/wall.png` or an
  absolute path.
- `dim` (0–0.6) controls darkening; `fillMode`: `fill` (crop to fill), `fit`, `stretch`.
- Regenerate the built-in wallpapers with `python3 scripts/gen_assets.py`.
