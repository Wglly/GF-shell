# インストールと統合

[繁體中文](INSTALL.md) · [简体中文](INSTALL.zh-CN.md) · [English](INSTALL.en.md) · **日本語** · [Index](i18n.md)

## 1. 依存関係

```bash
# Arch / CachyOS
sudo pacman -S quickshell qt6-declarative qt6-svg qt6-wayland \
               pipewire wireplumber upower networkmanager bluez \
               brightnessctl grim slurp wl-clipboard wf-recorder
```

| 機能 | 必要なもの |
| --- | --- |
| シェル本体 | `quickshell` ≥ 0.3 |
| 音量 | PipeWire + WirePlumber（`Quickshell.Services.Pipewire`） |
| バッテリー | UPower |
| ネットワーク | NetworkManager（`Quickshell.Networking`） |
| Bluetooth | BlueZ（`Quickshell.Bluetooth`） |
| 亮度 | `brightnessctl` |
| スクリーンショット／録画 | `grim`、`slurp`、`wf-recorder`、`wl-clipboard` |

オプションのツールが無い場合、対応するスライダーやスイッチは自動的に非表示または無効になり、
エラーは出ません。

フォントはすべて同梱されています。**システムへのインストールは不要**です。他のアプリでも使いたい場合：

```bash
mkdir -p ~/.local/share/fonts
cp assets/fonts/*.ttf ~/.local/share/fonts/
fc-cache -f
```

## 2. インストール

```bash
./install.sh                 # ~/.config/quickshell/gf-shell にコピー
./install.sh --link          # シンボリックリンク（開発時に編集が即反映）
./install.sh --dest /path    # 任意の場所
```

インストールせずに使うこともできます：

```bash
qs -p "$PWD"
```

> Quickshell は `~/.config/quickshell/<name>/shell.qml` を名前付き設定として認識します。
> `qs -c gf-shell` は `~/.config/quickshell/gf-shell/` を読み込みます。

## 3. 自動起動

### Hyprland 0.5x（Lua 設定）

```lua
-- ~/.config/hypr/custom/execs.lua
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c gf-shell")
end)
```

### Hyprland 従来の設定

```ini
exec-once = qs -c gf-shell
```

### niri

```kdl
// ~/.config/niri/config.kdl
spawn-at-startup "qs" "-c" "gf-shell"
```

### 先に他のシェルを停止する

GF-shell は独自のステータスバー（exclusive zone）を作成します。end4-pC / caelestia / waybar が
同時に動いていると、バーが 2 本になったり、予約領域が二重（38 + 50 px など）になったりします。
先に古いシェルの自動起動を無効にしてください。

```bash
# 他の Quickshell が動いていないか確認
pgrep -af quickshell
```

## 4. キーバインド

### Hyprland（Lua）

```lua
hl.bind("SUPER + Space",     hl.dsp.global("gf-shell:launcher"))
hl.bind("SUPER + Tab",       hl.dsp.global("gf-shell:overview"))
hl.bind("SUPER + SHIFT + C", hl.dsp.global("gf-shell:control"))
hl.bind("SUPER + SHIFT + P", hl.dsp.global("gf-shell:power"))
hl.bind("PRINT",             hl.dsp.global("gf-shell:screenshot"))
```

### Hyprland（従来）

```ini
bind = SUPER, Space, global, gf-shell:launcher
bind = SUPER, Tab, global, gf-shell:overview
bind = SUPER SHIFT, C, global, gf-shell:control
bind = SUPER SHIFT, P, global, gf-shell:power
bind = , Print, global, gf-shell:screenshot
```

### niri

niri は `hyprland_global_shortcuts_v1` に対応していないため、IPC を使います：

```kdl
Mod+Space { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "launcher"; }
Mod+Tab   { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "overview"; }
Mod+Alt+C { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "control"; }
Mod+Alt+P { spawn "qs" "-c" "gf-shell" "ipc" "call" "shell" "toggle" "power"; }
```

> `qs` の IPC はインスタンスが起動している必要があります。シェルがまだ読み込まれていない場合は
> "no running instance" と表示されますが、無視して構いません。

## 5. 画面 / スケーリング

- ステータスバー、デスクトップ HUD、エシュロンは**画面ごとに 1 つずつ**作成されます
  （`Variants` + `Quickshell.screens`）。
- 全画面オーバーレイは現在フォーカスされている画面に作成されます（`Compositor.outputName`）。
- UI スケール：設定 → 外観 → `UI SCALE`、または `theme.scale`（0.7–1.5）。
  本シェルにのみ影響し、Qt のグローバルスケーリングには影響しません。
- バーの高さ：設定 → ステータスバー → `THICKNESS`（30–58 px）。

## 6. トラブルシューティング

| 症状 | 対処 |
| --- | --- |
| 起動しても何も表示されない | ターミナルで `qs -c gf-shell` を実行し出力を確認。多くの場合 QML の読み込みエラーで、ファイル名と行番号が表示されます。 |
| バーが 2 本ある／デスクトップが下に押される | 他のシェルが動いています。自動起動を無効にするか終了してください。 |
| アイコンが四角や文字になる | アイコンフォントが読み込まれていません。`assets/fonts/GFTacticalIcons.ttf` の存在と、`qs -c gf-shell` がインストール先から起動していることを確認してください。 |
| 音量が 0% のまま | PipeWire の sink がありません（Bluetooth ヘッドセット未接続／音声サービス未起動）。 |
| 亮度スライダーが無い | `brightnessctl` が無い、またはバックライトデバイスがありません。 |
| 通知が表示されない | 他のプログラムが `org.freedesktop.Notifications` を占有しています（別のシェルなど）。終了すれば自動的に引き継ぎます。先に無効化しても構いません。 |
| niri でキーバインドが効かない | niri は Hyprland のグローバルショートカット非対応です。上記の IPC でバインドしてください。 |
| トレイアイコンが点になる | そのアプリの StatusNotifierItem アイコンが規格外です（Wine / Flatpak アプリの一部）。 |
| 初期状態に戻したい | `~/.config/gf-shell/config.json` を削除してシェルを再起動。 |

デバッグ用：

```bash
GF_OVERLAY=launcher qs -c gf-shell    # 起動時にランチャーを開く
GF_TAB=2 qs -c gf-shell               # 設定を 3 番目のタブで開く
GF_DEBUG=icons qs -c gf-shell         # すべてのアイコンを表示してフォントを確認
GF_DEBUG=gauge qs -c gf-shell         # ゲージのテストページ
GF_DEBUG=osd qs -c gf-shell           # 音量 OSD を固定表示
GF_DEBUG=toast qs -c gf-shell         # テスト通知を表示
```

Quickshell の完全なログ：`/run/user/$UID/quickshell/by-id/<id>/log.qslog`。
