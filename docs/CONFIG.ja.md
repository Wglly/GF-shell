# 設定リファレンス

[繁體中文](CONFIG.md) · [简体中文](CONFIG.zh-CN.md) · [English](CONFIG.en.md) · **日本語** · [Index](i18n.md)

設定ファイル：`~/.config/gf-shell/config.json`
（`XDG_CONFIG_HOME` が設定されている場合はそちらが優先されます。）

- 初回起動時に完全なデフォルト値が生成されます。
- 「副官設定」での操作はすべて即座に書き込まれます（250 ms デバウンス）。
- 手動で編集した場合は、シェルを再起動すると反映されます（一部の値は即時再バインド）。

## 全体構造

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
    "avoid": true,
    "trigger": 24,
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

## 言語

`language`：`auto`（`$LANG` に従う）、`zh_TW`、`zh_CN`、`en`、`ja`。
設定 → システム → 言語 で即時切替できます。

## ステータスバーのブロック

| 値 | 内容 |
| --- | --- |
| `launcher` / `emblem` | G&K エンブレム（クリックでデプロイ端末を開く） |
| `user` | オペレーター入口。クリックでプロフィールを表示 |
| `workspaces` | エシュロン／ワークスペース番号。スクロールで切替、クリックで移動 |
| `title` | アクティブウィンドウの appId + タイトル |
| `clock` | 中央時計 + 日付 + AM/PM（または H24）。クリックでカレンダー |
| `media` | 再生中の通信 + 再生／一時停止 |
| `stats` | CPU / MEM のセグメント表示 |
| `net` | Wi-Fi / 有線 + 4 本の信号バー + SSID。クリックでリンク詳細と付近の Wi-Fi |
| `bluetooth` | Bluetooth 状態と接続数。クリックでアダプターと既知のデバイス |
| `volume` | 音量。左クリックでミュート、右クリックでコントロールセンター、スクロールで調整 |
| `battery` | 残量／充電。低下すると赤色 |
| `tray` | StatusNotifierItem アイコン |
| `overview` / `control` / `power` | 3 つの入口ボタン |

狭い画面での自動非表示順：`title` → `media` → `stats` → `tray` → `net`。

## テーマプリセット

| preset | 説明 | アクセント |
| --- | --- | --- |
| `gfl` | G&K 標準：ウォームチャコール + マットゴールド | `#e8bd4f` |
| `sangvis` | サングヴィス・フェリ：ほぼ黒 + 警告の赤 | `#d34a34` |
| `neural` | ニューラルクラウド：深い青 + アイスシアン | `#7eb2d6` |
| `arctic` | アークティック：冷たいグレー + 淡い金 | `#cbb98a` |
| `arknights` | ロドスアイランド：黒 + 産業シアン + 白 | `#3fd4e6` |
| `bf4` | Battlefield 4：深い青 + スキャンライン + 橙 | `#2a8fb0` |
| `bf1` | Battlefield 1：古紙 + 真鍮 + 暗赤 | `#c9a05a` |
| `hoi4` | Hearts of Iron IV：オリーブ charcoal + 真鍮 + 参謀紙 | `#c9a84f` |
| `light` | デイライト：ニュートラルライトグレー＋深い金（ライト） | `#a97b18` |

プリセットは `panel`、`line`、`text` などを含む `theme.*` 全体を書き換えるため、切り替えると UI 全体が
即座に変わります。`accent` を個別に指定すると `preset` は `custom` になります。

## デザイントークン（`modules/common/Theme.qml`）

```qml
// フォント
fontUI      = "Chakra Petch"        // 通常の UI
fontDisplay = "Saira Condensed"     // 大きな見出し / 数字
fontMono    = "Share Tech Mono"     // データ、ID
fontLabel   = "Rajdhani"            // 小さな大文字ラベル

// 主要カラー
bg0  #06090c      panel      #0f161d      accent   #f0a43c
bg1  #0b1015      panelAlt   #131d26      accent2  #69c9bd
line #283844      panelHi    #1a2733      red      #d6513c
text #eae6dc      lineBright #4a6273      ok       #79c08a

// ジオメトリ
chamfer = 9px     border = 1px     barHeight = 38px
gap = 8px         pad = 12px       radius = 0
```

UI は常に `Theme.alpha(color, a)`、`Theme.mix()`、`Theme.shade()` で色を導出し、
`Theme.px()` / `Theme.fs()` でスケーリングします。

## デスクトップウィジェットの位置

`widgets.<name>.x` / `y` は**画面に対する比率**（0–1）で、原点は左上です。例：

```json
"clock":  { "x": 0.045, "y": 0.10 },
"stats":  { "x": 0.045, "y": 0.42 },
"media":  { "x": 0.70,  "y": 0.10 },
"mission":{ "x": 0.70,  "y": 0.78 }
```

オーバーレイが開いている間、デスクトップ HUD は自動的にフェードアウトします
（`ShellState.overlay !== "none"`）。


## 質感と位置（バー / Dock / サイドバー）

| フィールド | 範囲 | 内容 |
| --- | --- | --- |
| `opacity` | 0.3–1.0 | 背景の不透明度 |
| `gray` | 0–1 | 壁紙サンプリング層の彩度（1 でグレースケール） |
| `blur` | 0–1 | 壁紙サンプリング層のブラー半径（自前シェーダー、コンポジタ不要） |
| `width` / `iconSize` / `thickness` | — | サイズ（サイドバー幅 / Dock アイコン / バー高さ） |
| `position` | top / bottom | バーと Dock の上下位置 |

## サイドバーとバーポップアップ

- `sidebar.left`: オペレーター、カレンダー、分隊名簿。
- `sidebar.right`: メディア＋歌詞（lrclib.net）＋cava スペクトル＋通知ログ。
- 画面端の `trigger`（既定 6px）にポインタが入ると開き、`delay`（既定 650ms）後に閉じます。
- バーの `user` / `clock` / `media` をクリックすると、その位置にユーザー／カレンダー／メディアの詳細パネルが開きます。

## Dock の回避動作

- ウィンドウがあると Dock は 6px の金線まで縮み、下端のホットゾーンで展開します。
- 展開中は `exclusiveZone` が Dock の高さになり、ウィンドウが押し上げられます。
- `dock.pinned` は .desktop ファイル名の配列。固定項目を順に表示し、未固定の実行中アプリを後ろに追加します（上限 `dock.maxItems`、既定 12）。
- 設定 → Dock の「PIN AN APP」でアプリ名を入力して Enter すると固定できます。
- Dock アイコンを右クリックすると固定／解除、新しいウィンドウ、閉じるを選べます。固定状態は `dock.pinned` に保存されます。
- `dock.trigger`（4–48px）は非表示時のホットゾーン高さ。非表示時はホットゾーンが透明でパネルは完全に隠れ、2px の線だけ残ります。`exclusiveZone` は 0 です。
- `dock.avoid = false` なら Dock は常に表示。`dock.autoHide` は回避が有効なときだけ作用します。
- バーと同じ辺にある場合、ホットゾーンと線はバー端に描画され、Dock 本体はバーの内側に密着します。`mask` は Dock とホットゾーンだけを入力対象にするため、バーの他の部分はクリックできます。
- `dock.avoid`（既定 true）/ `dock.autoHide`（既定 false）で調整できます。

### サイドバーコンポーネント

`sidebar.assign.<id>`（`left` / `right` / `off`）で各コンポーネントの配置を決めます。
`user` / `calendar` / `roster` / `actions` / `stats` / `weather` / `clock` / `media` /
`visualizer` / `comms` / `mission` に対応。

`sidebar.<side>.height`（0.4–1.0）と `align`（top / center / bottom）で高さと縦位置を調整できます。

### バーコンポーネント

`bar.left` / `bar.center` / `bar.right` はブロック id の配列です。設定 → ステータスバー → コンポーネントは end-4pc 風のドラッグボードになり、チップを LEFT / CENTER / RIGHT へドラッグして移動・並べ替え、OFF へドロップして非表示にできます。チップをクリックしてから上の LEFT / CENTER / RIGHT / OFF ボタンで移動することもできます。


### デスクトップレイアウト編集

- 設定 → ウィジェット → レイアウト の **デスクトップレイアウトを編集**、`SUPER+SHIFT+W`、または
  `qs -c gf-shell ipc call shell widgets` で開きます。
- グリッドが重なり、枠をドラッグして移動、離すと `widgets.grid` のピクセルグリッドに吸着します。
- 各枠の右上の ON/OFF で個別に表示／非表示を切替できます。編集中はウィジェットが暗くなり操作できません。
- 位置は `widgets.<name>.x/y`（画面比率）に保存。`grid` は 16–96px。
- 各枠の右下角をドラッグしてリサイズ。サイズは `widgets.<name>.width/height` に保存されます。
- `完了` または `Esc` で終了、`リセット` で既定位置とサイズに戻ります。

## テーマモード・スケール・設定画面の表面

- `theme.mode`：`dark` / `light` / `custom`。プリセット（`light` を含む）が自動設定します。
- `theme.fontScale`（0.8–1.4）は文字と展開パネル／カードのレイアウト、`theme.scale`（0.8–1.3）はシェル全体を拡大します。
- `theme.settingsOpacity`（0.5–1.0）と `theme.settingsGray`（0–1）で設定画面のグレーホワイト半透明を調整。
- `bg0/bg1/panel/text/accent` を変えると `mode` は `custom` になります。壁紙は `bg0` の明るさに応じて
  紙白に洗われ、ライトテーマでも濃い文字が読めます。

- `dock.position`：`top` / `bottom` / `left` / `right`。左右では縦型サイド Dock になります。
- `dock.align`：横は `left` / `center` / `right`、縦は `top` / `center` / `bottom`。
- `sidebar.<left|right>.triggerPosition`：`top` / `bottom`。左右画面の上端／下端にホットゾーンを置きます。
- `sidebar.<left|right>.triggerWidth`：横方向の幅（60–420px）。`trigger` は高さ。
- サイドバーコンポーネント `wallpaper` を追加。設定 → サイドバー → コンポーネントで左右に割り当てられます。
- `wallpaper.dir`：取り込む壁紙ディレクトリ（png/jpg/jpeg/webp/avif/bmp）。バーとサイドバーの壁紙ライブラリに全画像が並びます。
- `user.avatar`：カスタムアバターのパス。設定ホームの BROWSE で `~/.config/gf-shell/avatar` にコピーされます。
- ライトテーマでは壁紙に紙白の色を重ねません。`wallpaper.dim` はダークテーマのみ有効です。

### デスクトップ右クリックのコマンドローズ

デスクトップの空白を右クリックすると、ポインタ位置に 7 項目のコマンドローズ（設定、壁紙、ウィジェット配置、デプロイ端末、ネットワーク、ターミナル、ダッシュボード）が開きます。1–7 キーで選択、左クリックまたは Esc で閉じます。4 つのゲームテーマはそれぞれ中心・リング・装飾が異なり、**全画面の暗幕はありません**。`ThemeSignature`、BarThemeAccent、CommandRose、Dashboard の追加スタイルは対応するプリセットでのみ表示されます。

## フォント

`fonts.ui` / `fonts.display` / `fonts.mono` / `fonts.label` で UI、見出し数字、データ、小ラベルのフォントファミリーを指定します。空文字は同梱フォント（Chakra Petch / Saira Condensed / Share Tech Mono / Rajdhani）です。

設定 → 外観 → **TYPOGRAPHY** は `fc-list` で fontconfig のローカルフォントを検出し、役割の切り替え、検索、プレビュー、クリック適用ができます。「この役割をリセット」で同梱フォントに戻ります。一覧は `services/Fonts.qml` が読み込みます。

## ポインター

`cursor.theme` / `cursor.size` に選択を保存します。設定 → 外観 → **POINTER** は `/usr/share/icons`、`~/.local/share/icons`、`~/.icons` の `cursors/` を持つ Xcursor テーマを検出し、検索して即時適用できます。

- Hyprland：`hyprctl setcursor`、GTK の `gsettings` も同期。
- niri：`scripts/niri-gf-cursor.py` が `cursor { xcursor-theme … }` を更新し、バックアップ、`niri validate` 検証、失敗時復元。niri は自動リロードします。

## コンポジタ

設定 → システム → **HYPRLAND / NIRI** は実行中のバックエンドに応じて表示されます：

- **Hyprland**：内外ギャップ、枠線幅、角丸、アクティブ／非アクティブ枠色、ブラー、アニメーション。`hl.config` で即時適用（非 Lua 設定では `hyprctl keyword`）。
- **niri**：ギャップ、枠線／フォーカスリング幅、ウィンドウ角丸、色とオン／オフ。`scripts/niri-gf-settings.py` が `~/.config/niri/config.d/` の layout を更新し、初回は `*.gf-backup` に保存、`niri validate` で検証、失敗時は復元します。niri は自動リロードします。

値は `compositor.hypr.*` / `compositor.niri.*` に保存され、niri の角丸は管理された `window-rule` で全ウィンドウに適用されます。

## 壁紙

- 内蔵：`assets/wallpapers/gfl-ops.png`、`gfl-sangvis`、`gfl-neural`、`gfl-dusk`。
- `path` が空の場合は最初の内蔵壁紙を使用。`file:///home/user/wall.png` や絶対パスも指定できます。
- `dim`（0–0.6）で暗さを調整。`fillMode`：`fill`（切り抜いて埋める）、`fit`、`stretch`。
- 内蔵壁紙の再生成：`python3 scripts/gen_assets.py`。
