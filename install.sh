#!/usr/bin/env bash
# GF-shell installer — copies (or symlinks) this directory into the Quickshell
# config directory so the shell can be started with `qs -c gf-shell`.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/gf-shell"
MODE="copy"

usage() {
    cat <<'EOF'
usage: ./install.sh [--link] [--dest PATH] [--yes]

  --link        symlink the repo instead of copying (development)
  --dest PATH   install to PATH (default: ~/.config/quickshell/gf-shell)
  --yes         do not ask before replacing an existing install
  -h, --help    show this help

After installing, start the shell with:
  qs -c gf-shell
EOF
}

ASSUME_YES=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --link) MODE="link" ;;
        --dest) DEST="${2:?--dest needs a path}"; shift ;;
        --yes) ASSUME_YES=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown option: $1" >&2; usage; exit 1 ;;
    esac
    shift
done

if ! command -v qs >/dev/null 2>&1; then
    echo "error: quickshell (qs) was not found in PATH" >&2
    echo "       install it first: sudo pacman -S quickshell" >&2
    exit 1
fi

mkdir -p "$(dirname "$DEST")"

if [[ -e "$DEST" || -L "$DEST" ]]; then
    if [[ "$ASSUME_YES" != "1" ]]; then
        read -r -p "$DEST already exists. Replace it? [y/N] " answer
        [[ "$answer" == "y" || "$answer" == "Y" ]] || { echo "aborted"; exit 0; }
    fi
    rm -rf "$DEST"
fi

if [[ "$MODE" == "link" ]]; then
    ln -s "$SRC" "$DEST"
    echo "linked $DEST -> $SRC"
else
    # Skip the docs' screenshots and VCS metadata to keep the install small.
    mkdir -p "$DEST"
    (cd "$SRC" && tar -cf - --exclude='.git' --exclude='docs/screenshots' .) | (cd "$DEST" && tar -xf -)
    echo "installed to $DEST"
fi

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/gf-shell"

echo
echo "──────────────────────────────────────────────────────────────"
echo " GF-shell is installed."
echo
echo " Start it:        qs -c gf-shell"
echo " Reload config:   qs -c gf-shell ipc call shell toggle launcher"
echo " Config file:     ${XDG_CONFIG_HOME:-$HOME/.config}/gf-shell/config.json"
echo
echo " Compositor keybinds (add to your config):"
echo "   Hyprland (lua):  hl.bind(\"SUPER + Space\", hl.dsp.global(\"gf-shell:launcher\"))"
echo "                    hl.bind(\"SUPER + Tab\",   hl.dsp.global(\"gf-shell:overview\"))"
echo "   niri:            Mod+Space { spawn \"qs\" \"-c\" \"gf-shell\" \"ipc\" \"call\" \"shell\" \"toggle\" \"launcher\"; }"
echo
echo " Autostart: add \`exec-once = qs -c gf-shell\` (Hyprland) or"
echo "            \`spawn-at-startup \"qs\" \"-c\" \"gf-shell\"\` (niri)."
echo "──────────────────────────────────────────────────────────────"
