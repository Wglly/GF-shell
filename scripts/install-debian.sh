#!/usr/bin/env bash
# GF-shell installer for Debian / Ubuntu / Debian-family distributions (apt).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=install-common.sh
source "$SCRIPT_DIR/install-common.sh"

GF_DRY_RUN=0
GF_BUILD_QS=0
GF_BACKPORTS=1
SHELL_ARGS=()

usage() {
    cat <<'USAGE'
usage: scripts/install-debian.sh [options]

  --no-backports     do not add Debian trixie-backports automatically
  --build-quickshell build Quickshell 0.3.2 from source when apt has no package
  --dry-run          print commands without changing the system
  --link             symlink GF-shell into the Quickshell config dir
  --dest PATH        install GF-shell to PATH
  --yes              assume yes for package and file replacements
  -h, --help         show this help

Debian 13 (trixie) has Quickshell 0.3.0 in backports; Debian 12 / Ubuntu may
need --build-quickshell. GF-shell itself is installed under
~/.config/quickshell/gf-shell.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-backports) GF_BACKPORTS=0 ;;
        --build-quickshell) GF_BUILD_QS=1 ;;
        --dry-run) GF_DRY_RUN=1 ;;
        --link) SHELL_ARGS+=("--link") ;;
        --dest) SHELL_ARGS+=("--dest" "${2:?--dest needs a path}"); shift ;;
        --yes) SHELL_ARGS+=("--yes") ;;
        -h|--help) usage; exit 0 ;;
        *) gf_die "unknown option: $1" ;;
    esac
    shift
done

OS_RELEASE_FILE="${GF_OS_RELEASE:-/etc/os-release}"
[[ -r "$OS_RELEASE_FILE" ]] || gf_die "cannot read $OS_RELEASE_FILE"
# shellcheck disable=SC1090
. "$OS_RELEASE_FILE"
case "${ID:-} ${ID_LIKE:-}" in
    *debian*|*ubuntu*) ;;
    *) gf_die "this script is for Debian-family systems (found: ${PRETTY_NAME:-unknown})" ;;
esac
CODENAME="${VERSION_CODENAME:-${DEBIAN_CODENAME:-}}"

RUNTIME=(
    qml6-module-qtquick qml6-module-qtquick-window qml6-module-qtquick-controls
    qml6-module-qtquick-layouts qml6-module-qtquick-shapes
    qml6-module-qtquick-templates qml6-module-qtquick-effects
    qml6-module-qtqml-workerscript
    pipewire wireplumber upower network-manager bluez
    brightnessctl grim slurp wl-clipboard fonts-noto-cjk
)
OPTIONAL=(wf-recorder playerctl cava curl zenity)

if [[ "$GF_DRY_RUN" = "1" ]]; then
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y ${RUNTIME[*]}"
    echo "  # Debian 13: add trixie-backports if quickshell is not in apt"
    echo "  sudo apt-get install -y -t trixie-backports quickshell"
    echo "  sudo apt-get install -y ${OPTIONAL[*]}"
    echo "  $GF_ROOT/install.sh --skip-qs-check --yes ${SHELL_ARGS[*]:-}"
    echo "(dry run complete; no changes made)"
    exit 0
fi

command -v apt-get >/dev/null 2>&1 || gf_die "apt-get not found"
[[ ${EUID} -eq 0 ]] && gf_die "run this script as your desktop user, not root; it uses sudo for packages."
command -v sudo >/dev/null 2>&1 || gf_die "sudo is required for package installation"
SUDO=(sudo)
apt_update() {
    if [[ "$GF_DRY_RUN" = "1" ]]; then
        echo "  ${SUDO[*]} apt-get update"
    else
        "${SUDO[@]}" apt-get update
    fi
}

gf_log "Debian-family detected: ${PRETTY_NAME:-$ID} (${CODENAME:-unknown})"
apt_update

gf_log "Installing GF-shell runtime packages"
"${SUDO[@]}" apt-get install -y "${RUNTIME[@]}"

# Quickshell packaging: trixie-backports, sid/forky main, or source.
have_qs_pkg() { apt-cache show quickshell >/dev/null 2>&1; }

if ! have_qs_pkg && [[ "$GF_BACKPORTS" = "1" && "$CODENAME" = "trixie" ]]; then
    gf_log "Enabling trixie-backports for Quickshell"
    if [[ "$GF_DRY_RUN" = "1" ]]; then
        echo "  echo 'deb http://deb.debian.org/debian trixie-backports main' | sudo tee /etc/apt/sources.list.d/gf-shell-backports.list"
    else
        echo "deb http://deb.debian.org/debian trixie-backports main" \
            | "${SUDO[@]}" tee /etc/apt/sources.list.d/gf-shell-backports.list >/dev/null
    fi
    apt_update
fi

if have_qs_pkg; then
    if [[ "$CODENAME" = "trixie" && "$GF_BACKPORTS" = "1" ]]; then
        if [[ "$GF_DRY_RUN" = "1" ]]; then
            echo "  ${SUDO[*]} apt-get install -y -t trixie-backports quickshell"
        else
            "${SUDO[@]}" apt-get install -y -t trixie-backports quickshell
        fi
    else
        if [[ "$GF_DRY_RUN" = "1" ]]; then
            echo "  ${SUDO[*]} apt-get install -y quickshell"
        else
            "${SUDO[@]}" apt-get install -y quickshell
        fi
    fi
fi

if [[ "$GF_DRY_RUN" != "1" ]] && { [[ -z "$(gf_qs_version || true)" ]] || ! gf_version_ge "$(gf_qs_version)" 0.3; }; then
    if [[ "$GF_BUILD_QS" = "1" ]]; then
        BUILD_DEPS=(
            git cmake ninja-build build-essential pkg-config
            qt6-base-dev qt6-base-private-dev qt6-declarative-dev qt6-declarative-private-dev
            libqt6svg6-dev qt6-wayland-dev qt6-wayland-private-dev qt6-shadertools-dev
            libwayland-dev wayland-protocols libdrm-dev libpipewire-0.3-dev
            libcli11-dev libjemalloc-dev libxcb1-dev libpam0g-dev
            libpolkit-agent-1-dev libglib2.0-dev libgbm-dev libvulkan-dev
        )
        gf_log "Installing Quickshell build dependencies"
        "${SUDO[@]}" apt-get install -y "${BUILD_DEPS[@]}" || gf_warn "some build deps failed; see docs/INSTALL.md"
        gf_build_quickshell "GF-shell installer (Debian)" || gf_die "Quickshell build failed; install 0.3.x manually."
    else
        gf_die "Quickshell >= 0.3 is not available via apt. Re-run with --build-quickshell, or use Debian 13/trixie-backports."
    fi
fi

if [[ "$GF_DRY_RUN" = "1" ]]; then
    echo "  $GF_ROOT/install.sh --skip-qs-check --yes ${SHELL_ARGS[*]:-}"
    echo "(dry run complete; no changes made)"
    exit 0
fi

for pkg in "${OPTIONAL[@]}"; do
    "${SUDO[@]}" apt-get install -y "$pkg" >/dev/null 2>&1 || gf_warn "optional package $pkg not installed"
done

gf_require_qs
if ((${#SHELL_ARGS[@]})); then
    gf_install_shell "${SHELL_ARGS[@]}"
else
    gf_install_shell
fi
