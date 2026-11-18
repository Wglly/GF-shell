#!/usr/bin/env bash
# Shared helpers for the distro installers. Source this file; do not execute.
set -euo pipefail

GF_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

gf_log()  { printf '\033[1;33m[gf]\033[0m %s\n' "$*"; }
gf_warn() { printf '\033[1;31m[gf]\033[0m %s\n' "$*" >&2; }
gf_die()  { gf_warn "$*"; exit 1; }

gf_qs_version() {
    command -v qs >/dev/null 2>&1 || return 1
    qs --version 2>/dev/null | sed -n 's/.*Quickshell[[:space:]]\+\([0-9][0-9.]*\).*/\1/p' | head -n1
}

gf_version_ge() {
    # gf_version_ge HAVE WANT
    [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

gf_require_qs() {
    local ver
    ver="$(gf_qs_version || true)"
    if [ -z "$ver" ]; then
        gf_die "Quickshell (qs) was not found. Install Quickshell >= 0.3 first."
    fi
    if ! gf_version_ge "$ver" 0.3; then
        gf_die "Quickshell $ver is too old; GF-shell needs >= 0.3 (0.3.2 recommended)."
    fi
    gf_log "Using Quickshell $ver"
}

gf_install_shell() {
    # Remaining arguments are passed to install.sh (--link/--dest/--yes).
    "$GF_ROOT/install.sh" --skip-qs-check --yes "$@"
}

gf_make_tmp() {
    local dir
    dir="$(mktemp -d "${TMPDIR:-/tmp}/gf-shell-build.XXXXXX")"
    printf '%s\n' "$dir"
}

gf_build_quickshell() {
    # gf_build_quickshell DISTRO_LABEL BUILD_DEPS...
    local label="$1"; shift
    local tmp
    tmp="$(gf_make_tmp)"
    gf_log "Building Quickshell 0.3.2 from source in $tmp"
    if [ "$GF_DRY_RUN" = "1" ]; then
        echo "  git clone --depth 1 --branch v0.3.2 https://github.com/quickshell-mirror/quickshell.git $tmp/quickshell"
        echo "  cmake -GNinja -S $tmp/quickshell -B $tmp/quickshell/build -DCMAKE_BUILD_TYPE=Release -DDISTRIBUTOR=\"$label\" -DCRASH_HANDLER=OFF"
        echo "  cmake --build $tmp/quickshell/build"
        echo "  sudo cmake --install $tmp/quickshell/build"
        return 0
    fi
    git clone --depth 1 --branch v0.3.2 \
        https://github.com/quickshell-mirror/quickshell.git "$tmp/quickshell"
    cmake -GNinja -S "$tmp/quickshell" -B "$tmp/quickshell/build" \
        -DCMAKE_BUILD_TYPE=Release \
        -DDISTRIBUTOR="$label" \
        -DCRASH_HANDLER=OFF
    cmake --build "$tmp/quickshell/build"
    sudo cmake --install "$tmp/quickshell/build"
    gf_log "Quickshell installed to /usr/local; make sure /usr/local/bin is in PATH."
}
