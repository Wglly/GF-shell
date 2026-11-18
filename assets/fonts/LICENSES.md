# 隨附字型與授權

本目錄的字型只為了讓外殼在任何機器上渲染一致；全部來自 Google Fonts，授權如下。

| 檔案 | 家族 | 作者 / 來源 | 授權 |
| --- | --- | --- | --- |
| `ChakraPetch-*.ttf` | Chakra Petch | Cadson Demak — https://fonts.google.com/specimen/Chakra+Petch | SIL OFL 1.1 |
| `Rajdhani-*.ttf` | Rajdhani | Indian Type Foundry — https://fonts.google.com/specimen/Rajdhani | SIL OFL 1.1 |
| `SairaCondensed-*.ttf` | Saira Condensed | Omnibus-Type — https://fonts.google.com/specimen/Saira+Condensed | SIL OFL 1.1 |
| `ShareTechMono-Regular.ttf` | Share Tech Mono | Carrois Apostrophe — https://fonts.google.com/specimen/Share+Tech+Mono | SIL OFL 1.1 |
| `GFTacticalIcons.ttf` | Material Symbols Rounded (子集) | Google — https://fonts.google.com/icons | Apache License 2.0 |

## SIL Open Font License 1.1

Chakra Petch、Rajdhani、Saira Condensed、Share Tech Mono 以 SIL Open Font License 1.1 發佈。
完整條文見本目錄的 [`OFL-1.1.txt`](OFL-1.1.txt)。
重點：字型可自由使用、修改、再散布（包含嵌入軟體），但修改後的版本不得使用原保留字型名稱（Reserved Font Name）。

## Apache License 2.0

Material Symbols Rounded 由 Google 以 Apache License 2.0 發佈。
`GFTacticalIcons.ttf`（家族名重新命名為 *GF Tactical Icons*，避免與系統安裝的 Material Symbols 撞名）是本專案從完整可變字型固定預設軸（wght 400 / FILL 0 / GRAD 0 / opsz 24）
並依實際使用的圖示名稱子集化後的版本（約 1 MB）。
完整條文：https://www.apache.org/licenses/LICENSE-2.0

## 重新產生子集

```bash
# 需要 fontTools
python3 - <<'PY'
from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
# 1. 下載完整 Material Symbols Rounded variable TTF
# 2. 固定軸
f = TTFont("MaterialSymbolsRounded.ttf")
f = instantiateVariableFont(f, {"wght": 400, "FILL": 0, "GRAD": 0, "opsz": 24})
f.save("/tmp/icons-static.ttf")
# 3. 以實際使用的 icon 名稱（ligature）子集
opts = subset.Options()
opts.layout_features = ["*"]
font = subset.load_font("/tmp/icons-static.ttf", opts)
s = subset.Subsetter(options=opts)
s.populate(text="search close settings volume_up …", unicodes=[])
s.subset(font)
subset.save_font(font, "GFTacticalIcons.ttf", opts)
PY
```
