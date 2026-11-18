#!/usr/bin/env bash
# GF-shell installer for Fedora / Fedora-based distributions (dnf).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=install-common.sh
source "$SCRIPT_DIR/install-common.sh"

GF_DRY_RUN=0
GF_USE_COPR=1
GF_BUILD_QS=0
SHELL_ARGS=()

usage() {
    cat <<'USAGE'
usage: scripts/install-fedora.sh [options]

  --no-copr          do not enable the errornointernet/quickshell COPR
  --build-quickshell build Quickshell 0.3.2 from source if the repo is too old
  --dry-run          print commands without changing the system
  --link             symlink GF-shell into the Quickshell config dir
  --dest PATH        install GF-shell to PATH
  --yes              assume yes for package and file replacements
  -h, --help         show this help

Fedora's official quickshell package can lag behind (0.2.x on Fedora 44).
The script enables the COPR by default to get a 0.3.x build, then installs
GF-shell into ~/.config/quickshell/gf-shell.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-copr) GF_USE_COPR=0 ;;
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
    *fedora*|*rhel*|*centos*) ;;
    *) gf_die "this script is for Fedora-family systems (found: ${PRETTY_NAME:-unknown})" ;;
esac
RUNTIME=(
    qt6-qtbase qt6-qtdeclarative qt6-qtsvg qt6-qtwayland
    pipewire wireplumber upower NetworkManager bluez
    brightnessctl grim slurp wl-clipboard
    google-noto-sans-cjk-fonts
)
OPTIONAL=(wf-recorder playerctl cava curl)

if [[ "$GF_DRY_RUN" = "1" ]]; then
    echo "  sudo dnf install -y ${RUNTIME[*]}"
    if [[ "$GF_USE_COPR" = "1" ]]; then
        echo "  sudo dnf install -y dnf5-plugins || true"
        echo "  sudo dnf copr enable -y errornointernet/quickshell"
        echo "  sudo dnf install -y quickshell"
    else
        echo "  sudo dnf install -y quickshell"
    fi
    echo "  sudo dnf install -y ${OPTIONAL[*]}"
    echo "  $GF_ROOT/install.sh --skip-qs-check --yes ${SHELL_ARGS[*]:-}"
    echo "(dry run complete; no changes made)"
    exit 0
fi

command -v dnf >/dev/null 2>&1 || gf_die "dnf not found"
[[ ${EUID} -eq 0 ]] && gf_die "run this script as your desktop user, not root; it uses sudo for packages."
command -v sudo >/dev/null 2>&1 || gf_die "sudo is required for package installation"
SUDO=(sudo)
DNF=dnf
command -v dnf5 >/dev/null 2>&1 && DNF=dnf5

gf_log "Fedora-family detected: ${PRETTY_NAME:-Fedora}"
gf_log "Installing GF-shell runtime packages"
"${SUDO[@]}" "$DNF" install -y "${RUNTIME[@]}"

# Quickshell 0.2.x is too old; prefer the COPR build when needed.
QS_VER="$(gf_qs_version || true)"
if [[ -z "$QS_VER" ]] || ! gf_version_ge "$QS_VER" 0.3; then
    if [[ "$GF_USE_COPR" = "1" ]]; then
        gf_log "Enabling errornointernet/quickshell COPR for Quickshell >= 0.3"
        if [[ "$GF_DRY_RUN" = "1" ]]; then
            echo "  ${SUDO[*]} $DNF install -y dnf5-plugins || true"
            echo "  ${SUDO[*]} $DNF copr enable -y errornointernet/quickshell"
            echo "  ${SUDO[*]} $DNF install -y quickshell"
        else
            "${SUDO[@]}" "$DNF" install -y dnf5-plugins 2>/dev/null || true
            if ! "${SUDO[@]}" "$DNF" copr enable -y errornointernet/quickshell; then
                gf_warn "COPR could not be enabled; falling back to the official package."
            fi
            "${SUDO[@]}" "$DNF" install -y quickshell
        fi
    else
        if [[ "$GF_DRY_RUN" = "1" ]]; then
            echo "  ${SUDO[*]} $DNF install -y quickshell"
        else
            "${SUDO[@]}" "$DNF" install -y quickshell
        fi
    fi
fi

# Re-check; build if still too old and requested.
if [[ "$GF_DRY_RUN" != "1" ]] && { [[ -z "$(gf_qs_version || true)" ]] || ! gf_version_ge "$(gf_qs_version)" 0.3; }; then
    if [[ "$GF_BUILD_QS" = "1" ]]; then
        BUILD_DEPS=(
            git cmake ninja-build gcc-c++ pkgconf-pkg-config
            qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtsvg-devel
            qt6-qtwayland-devel qt6-qtbase-private-devel qt6-qtshadertools-devel
            wayland-devel wayland-protocols-devel libdrm-devel
            pipewire-devel cli11-devel jemalloc-devel libxcb-devel
            pam-devel polkit-devel glib2-devel libgbm-devel vulkan-headers
        )
        gf_log "Installing Quickshell build dependencies"
        "${SUDO[@]}" "$DNF" install -y "${BUILD_DEPS[@]}" || gf_warn "some build deps failed; see docs/INSTALL.md"
        gf_build_quickshell "GF-shell installer (Fedora)" || gf_die "Quickshell build failed; install 0.3.x manually."
    else
        gf_die "Quickshell is still older than 0.3. Re-run with --build-quickshell or install ${COPR_HINT:-a 0.3.x package}."
    fi
fi

if [[ "$GF_DRY_RUN" = "1" ]]; then
    echo "  $GF_ROOT/install.sh --skip-qs-check --yes ${SHELL_ARGS[*]:-}"
    echo "(dry run complete; no changes made)"
    exit 0
fi

# Optional tools; never fail the install because one is unavailable.
for pkg in "${OPTIONAL[@]}"; do
    "${SUDO[@]}" "$DNF" install -y "$pkg" >/dev/null 2>&1 || gf_warn "optional package $pkg not installed"
done

gf_require_qs
if ((${#SHELL_ARGS[@]})); then
    gf_install_shell "${SHELL_ARGS[@]}"
else
    gf_install_shell
fi
