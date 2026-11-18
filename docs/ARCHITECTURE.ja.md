# アーキテクチャ

[繁體中文](ARCHITECTURE.md) · [简体中文](ARCHITECTURE.zh-CN.md) · [English](ARCHITECTURE.en.md) · **日本語** · [Index](i18n.md)

GF-shell は 1 つの Quickshell 設定です。`shell.qml` がすべてのウィンドウを作り、サービス層が
システムと対話し、`Theme.qml` が唯一の視覚的な真実の源です。C++ プラグインもビルド手順も
ネットワーク依存もありません。

```
                     ┌──────────────────────────────────────────────┐
                     │                 shell.qml                    │
                     │  FontLoader × 10 · テーマ Binding · GlobalShortcut │
                     │  IpcHandler · Variants(画面) · オーバーレイ実体 │
                     └───────────────┬──────────────────────────────┘
                                     │
          ┌──────────────────────────┼───────────────────────────────┐
          ▼                          ▼                               ▼
 ┌─────────────────┐      ┌────────────────────┐         ┌──────────────────┐
 │  services/*.qml │      │ modules/common/*   │         │  modules/<module>│
 │ システム状態     │◀────▶│ Theme / ShellState │◀───────▶│ Bar / Launcher … │
 │ （シングルトン） │      │ Util / Gf* widgets │         └──────────────────┘
 └────────┬────────┘      └────────────────────┘
          │
          ▼
 Quickshell サービス (Pipewire / UPower / Mpris / Networking / Bluetooth /
 SystemTray) · hyprctl / niri msg · /proc · brightnessctl · grim
```

## ウィンドウレイヤ（layer-shell）

| ウィンドウ | レイヤ | 内容 |
| --- | --- | --- |
| `Wallpaper` | `Background` | 画面ごとの壁紙 + ハーフトーン + 等高線 + グレイン + 隅の読み取り表示 |
| `DesktopHud` | `Bottom` | 時計、バイタル、通信、現在の任務（通常ウィンドウの下に描画） |
| `Bar` | `Top` | ステータスバー。`exclusiveZone = 高さ` でウィンドウが避ける |
| `Dock` | `Top` | エシュロン。`exclusionMode = Ignore` でウィンドウを押し出さない |
| `Launcher` / `ControlCenter` / `Overview` / `PowerMenu` / `SettingsWindow` / `Calendar` | `Overlay` | 全画面または部分的なオーバーレイ |
| `Osd` / `Toasts` | `Overlay` | 一時的な HUD |

`ShellState.overlay` がグローバルな状態機械です（`none` / `launcher` / `control` / `overview` /
`power` / `settings` / `calendar`）。同時に表示されるオーバーレイは 1 つだけで、`open()` は
直前のものを閉じます。

## サービス層

| ファイル | 役割 |
| --- | --- |
| `Compositor.qml` | Hyprland / niri 共通 API：`workspaces`、`windows`、`focusedId`、`windowTitle`、`windowAppId`、`focusWorkspace(id)`、`focusWindow(key)`、`step(delta)`、`backend` |
| `Settings.qml` | `config.json` の読み書き、デフォルト値、`presets`、`set/get/toggle`、デバウンス保存 |
| `ShellState.qml` | オーバーレイ状態、OSD の発火、設定タブ、デスクトップ HUD の表示 |
| `Theme.qml` | 色・フォント・間隔・アニメーション時間のトークンと `alpha/mix/shade` |
| `Apps.qml` | `.desktop` の走査（Name/Exec/Icon/NoDisplay）、`launch()`、`findByClass()` |
| `Audio.qml` | デフォルト sink の音量／ミュート、変更時に OSD を表示 |
| `Battery.qml` | UPower 表示デバイス：残量、充電状態、残り時間、アイコン |
| `Net.qml` | NetworkManager：Wi-Fi 切替、SSID、信号バー、有線／オフライン |
| `Media.qml` | MPRIS：タイトル／アーティスト／アート／進捗／再生操作 |
| `Notifs.qml` | NotificationServer、トースト待ち行列、履歴、DND、7 秒で自動消去 |
| `Stats.qml` | CPU / MEM / ディスク / ネットワーク速度 / uptime / load / プロセス数 |
| `System.qml` | `brightnessctl`、ロック／サスペンド／再起動／シャットダウン／ログアウト、コンポジタ終了 |
| `Capture.qml` | grim + slurp のスクリーンショット、wf-recorder の録画 |
| `Wallpapers.qml` | 内蔵壁紙の一覧、選択、ランダム |
| `I18n.qml` | 英語 / 繁体字中国語の文字列テーブル |

サービス同士の参照は許されています（例：`Audio` が `ShellState.flashOsd()` を呼ぶ）。UI は
サービスの読み取り専用プロパティだけを読み、書き込みは必ずサービスのメソッドを通します。

## Hyprland の詳細

- `Quickshell.Hyprland` を使用：`Hyprland.workspaces`、`Hyprland.toplevels`、`activeToplevel`、
  `focusedMonitor`。すべてイベント駆動でポーリングはありません。
- Hyprland 0.5x は Lua 設定を実行できます。`Hyprland.usingLua` が真の場合、ディスパッチは
  `hl.dsp.*` 構文で行う必要があります（`Compositor.focusWorkspace()` と
  `System.quitCompositor()` を参照）。
- `GlobalShortcut`（appid `gf-shell`）はこのバックエンドでのみ動作します。

## niri の詳細

Quickshell 0.3.x には niri サービスが無いため：

- 状態は `niri msg --json workspaces` / `windows` / `focused-window` で取得；
- `niri msg event-stream` は変更シグナルとしてのみ使用（payload は解析しない）；
- イベントストリームが切れたら 1 秒後に再接続。さらに 3 秒間隔の低頻度ポーリングを保険に持つ；
- 操作は `niri msg action focus-workspace <idx>` / `focus-window --id` /
  `move-window-to-workspace` を使用；
- 検出順：`NIRI_SOCKET` を優先（Hyprland 内にネストした niri では両方が存在）。

## オーバーレイ追加の最小手順

```qml
// modules/foo/Foo.qml
PanelWindow {
    readonly property bool open: ShellState.overlay === "foo"
    visible: open
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    GfFrame { /* … */ }
}
```

1. `shell.qml` に `Foo {}` を追加（`import qs.modules.foo` も）。
2. `ShellState.toggle("foo")` で開けます。IPC と `GF_OVERLAY` は自動的に対応します。
3. キーボードが必要な場合は `focus: true` の `Item` にフォーカスし、`Keys.onPressed` で Esc を処理します。

## デザインシステム

`modules/common/widgets/` が GF の UI プリミティブです：

| コンポーネント | 用途 |
| --- | --- |
| `GfFrame` | 面取りパネル（塗り、枠、スキャンライン、ハッチ、四隅ブラケット、上／左の強調線） |
| `GfText` / `GfLabel` / `GfSectionHeader` | 書体ロール（ui/display/mono/label）と見出し |
| `GfButton` / `GfIconButton` / `GfToggle` / `GfSlider` / `GfTextField` / `GfKeyCap` | コントロール |
| `GfMeter` / `GfGauge` / `GfDivider` / `GfCorners` / `GfHex` | ゲージと装飾 |

すべてのパネルは「面取り多角形 + 1px の枠」を `QtQuick.Shapes`（`Shape.CurveRenderer`）で描画して
います。テクスチャもブラーも Qt5Compat 依存もありません。

## パフォーマンス

- 常駐プロセスは `qs` 1 つ。サービスのポーリングは `Stats` が 1 秒、niri の保険が 3 秒、それ以外は
  イベント駆動。
- コンポジタのブラーは不使用。スキャンライン／グレイン／ハッチは 1–4 px のタイル PNG。
- アニメーションはホバー／展開時のみ。`theme.animations = false` で完全に無効化できます。
- アイコンフォントはサブセット（約 1 MB）、壁紙は PNG 4 枚（各約 2.5 MB）。
