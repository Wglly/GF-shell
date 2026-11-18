# Installation & integration

[繁體中文](INSTALL.md) · [简体中文](INSTALL.zh-CN.md) · **English** · [日本語](INSTALL.ja.md) · [Index](i18n.md)

## 1. Dependencies

```bash
# Arch / CachyOS
sudo pacman -S quickshell qt6-declarative qt6-svg qt6-wayland \
               pipewire wireplumber upower networkmanager bluez \
               brightnessctl grim slurp wl-clipboard wf-recorder
```

| Feature | Needs |
| --- | --- |
| The shell itself | `quickshell` ≥ 0.3 |
| Volume | PipeWire + WirePlumber (`Quickshell.Services.Pipewire`) |
| Battery | UPower |
| Network | NetworkManager (`Quickshell.Networking`) |
| Bluetooth | BlueZ (`Quickshell.Bluetooth`) |
| Brightness | `brightnessctl` |
| Screenshots / recording | `grim`, `slurp`, `wf-recorder`, `wl-clipboard` |

When an optional tool is missing, the matching slider or switch is hidden or disabled without errors.

All fonts are bundled — **no system installation is required**. If you want other apps to use them:

```bash
mkdir -p ~/.local/share/fonts
cp assets/fonts/*.ttf ~/.local/share/fonts/
fc-cache -f
```

## 2. Install

```bash
./install.sh                 # copy to ~/.config/quickshell/gf-shell
./install.sh --link          # symlink (edits take effect immediately during development)
./install.sh --dest /path    # custom location
```

You can also skip installation:

```bash
qs -p "$PWD"
```

> Quickshell recognises named configurations at `~/.config/quickshell/<name>/shell.qml`.
> `qs -c gf-shell` therefore reads `~/.config/quickshell/gf-shell/`.

## 3. Autostart

### Hyprland 0.5x (Lua config)

```lua
-- ~/.config/hypr/custom/execs.lua
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c gf-shell")
end)
```

### Hyprland classic config

```ini
exec-once = qs -c gf-shell
```

### niri

```kdl
// ~/.config/niri/config.kdl
spawn-at-startup "qs" "-c" "gf-shell"
```

### Stop any other shell first

GF-shell creates its own status bar (with an exclusive zone). If end4-pC / caelestia / waybar is still
running, you will get two bars or a double reserved area (e.g. 38 + 50 px). Disable the old shell's
autostart first.

```bash
# check for other Quickshell instances
pgrep -af quickshell
```

## 4. Keybinds

### Hyprland (Lua)

```lua
hl.bind("SUPER + Space",     hl.dsp.global("gf-shell:launcher"))
hl.bind("SUPER + Tab",       hl.dsp.global("gf-shell:overview"))
hl.bind("SUPER + SHIFT + C", hl.dsp.global("gf-shell:control"))
hl.bind("SUPER + SHIFT + P", hl.dsp.global("gf-shell:power"))
hl.bind("PRINT",             hl.dsp.global("gf-shell:screenshot"))
```

### Hyprland (classic)

```ini
bind = SUPER, Space, global, gf-shell:launcher
bind = SUPER, Tab, global, gf-shell:overview
bind = SUPER SHIFT, C, global, gf-shell:control
bind = SUPER SHIFT, P, global, gf-shell:power
bind = , Print, global, gf-shell:screenshot
```

### niri

niri does not implement `hyprland_global_shortcuts_v1`; use IPC instead:

```kdl
Mod+Space { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "launcher"; }
Mod+Tab   { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "overview"; }
Mod+Alt+C { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "control"; }
Mod+Alt+P { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "power"; }
```

> `qs` IPC requires a running instance; if the shell has not loaded yet the command reports
> "no running instance" (safe to ignore).

## 5. Displays / scaling

- The status bar, desktop HUD and dock are created **once per screen** (`Variants` + `Quickshell.screens`).
- Full-screen overlays are created on the currently focused screen (`Compositor.outputName`).
- UI scale: Settings → Appearance → `UI SCALE`, or `theme.scale` (0.7–1.5). It only affects this shell,
  not Qt's global scaling.
- Bar height: Settings → Bar → `THICKNESS` (30–58 px).

## 6. Troubleshooting

| Symptom | Fix |
| --- | --- |
| Nothing appears after launch | Run `qs -c gf-shell` in a terminal; QML load errors are printed with file and line. |
| Two bars / desktop pushed down | Another shell is still running; disable its autostart or quit it. |
| Icons render as boxes or letters | The icon font did not load. Make sure `assets/fonts/GFTacticalIcons.ttf` exists and `qs -c gf-shell` starts from the installed directory. |
| Volume stays at 0% | No PipeWire sink (Bluetooth headset not connected / audio service not running). |
| No brightness slider | `brightnessctl` is missing or there is no backlight device. |
| Notifications never appear | Another program owns `org.freedesktop.Notifications` (e.g. another shell); GF-shell takes over once it exits, or disable it first. |
| Keybinds do nothing on niri | niri lacks Hyprland global shortcuts; bind them through IPC as shown above. |
| Tray icons are dots | That application exposes a non-conformant StatusNotifierItem icon (some Wine / Flatpak apps). |
| Reset everything | Delete `~/.config/gf-shell/config.json` and restart the shell. |

Debug helpers:

```bash
GF_OVERLAY=launcher qs -c gf-shell    # open the launcher on startup
GF_TAB=2 qs -c gf-shell               # open the settings window on tab 3
GF_DEBUG=icons qs -c gf-shell         # render every icon to check the font
GF_DEBUG=gauge qs -c gf-shell         # gauge test page
GF_DEBUG=osd qs -c gf-shell           # keep the volume OSD visible
GF_DEBUG=toast qs -c gf-shell         # show a test notification
```

Full Quickshell log: `/run/user/$UID/quickshell/by-id/<id>/log.qslog`.
