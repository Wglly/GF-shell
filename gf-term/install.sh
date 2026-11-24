#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
cargo build --release
install -Dm755 target/release/gf-term "${HOME}/.local/bin/gf-term"
install -Dm755 target/release/gf-img "${HOME}/.local/bin/gf-img"
install -Dm644 gf-term.desktop "${HOME}/.local/share/applications/gf-term.desktop"
echo "Installed gf-term and gf-img to ${HOME}/.local/bin"
