# Design notes (Girls' Frontline UI language)

[繁體中文](DESIGN.md) · [简体中文](DESIGN.zh-CN.md) · **English** · [日本語](DESIGN.ja.md)

This document records GF-shell's visual decisions, the references used, and what is original vs. what
cannot be bundled.

## References

- [Girls' Frontline official site](https://gf.sunborngame.com/): brand palette (warm charcoal, matte
  gold, steel blue, alert red), condensed all-caps headings, gold hairlines and diagonal composition.
- [GFwiki](https://www.gfwiki.org/): in-game interface screenshots (formation / base / operation map) —
  used to confirm real information density, label ribbons, tab shapes and type proportions.
- [Aigei "Girls' Frontline UI" asset set](https://www.aigei.com/set/shaonvqianxian_ui.html): consulted
  only as a style index for paid assets; **nothing** from it is downloaded or used.

> Copyright in those sites and the game art belongs to their owners (Sunborn / MICA Team etc.).
> This project borrows the *style language* only; every actual graphic is drawn by
> `scripts/gen_assets.py` or in QML.

## Rules extracted from the references

1. **Base**: warm charcoal (`#242421` / `#151513`), not cold blue-black — it makes gold and paper-white
   text pop.
2. **Primary accent**: matte gold `#d8aa4b`; the selected state is a **solid gold fill with black
   text**, not just an outline.
3. **Secondary accent**: steel blue `#87a0b2` (base/data); **red** `#c6523c` is reserved for combat
   power, alerts and dangerous actions.
4. **Frames**: a 1 px gold line plus a second thin white line inset by 4 px (double frame); chamfers
   only on selected corners (top-right / bottom-left).
5. **Labels**: angled parallelogram ribbons (`GfTab` / `GfRibbon`), with a coloured block on the left
   holding a number or icon, white text.
6. **Typography**: condensed all-caps headings with wide tracking; monospaced data; small, wide-tracked,
   low-contrast Chinese subtitles.
7. **Texture**: halftone dots, contour lines, isometric base line-art, thin gold frames, grain; **no**
   CRT scanlines (the game does not use them).
8. **Layout**: dense, strictly aligned; panels separated by gold rules instead of rounded cards or
   drop shadows.

## Mapping to components

| GFL element | GF-shell implementation |
| --- | --- |
| Selected tab (gold fill, black text, angled) | `GfTab` (bar workspaces, launcher categories) |
| Selected button / module toggle | `checked` state of `GfButton`, `CcToggle`, `GfIconButton` |
| Angled label ribbon | `GfRibbon` (optional downward pointer) |
| Double panel frame | `GfFrame` (`borderColor` + `innerLine` + small chamfer) |
| Title strip | `GfSectionHeader` (gold block + condensed white text + gold rule) |
| Resource / status bars | `GfMeter`, `GfSlider` (gold segments / diamond knob) |
| Portrait frame | Launcher dossier (gold corner + hatch backing) |
| Red combat-power number | Launcher dossier `COMBAT POWER` |

## Wallpaper

The default wallpapers are **original** procedural compositions: warm charcoal gradient, gold diagonal
band, halftone dots, contour lines, isometric base line-art, crest watermark, thin gold frame and data
strip; the four variants (ops / sangvis / neural / dusk) share the same visual grammar. Regenerate with:

```bash
python3 scripts/gen_assets.py
```

### Using official promotional art

This project bundles **no** official art (wallpapers, character art, logos, UI textures). If you own
such images legally, keep them locally and point the shell at them; the program never copies or
redistributes them:

```json
// ~/.config/gf-shell/config.json
"wallpaper": {
  "enabled": true,
  "path": "file:///home/you/Pictures/gfl-wallpaper.png",
  "fillMode": "fill",
  "dim": 0.12
}
```

Or pick the file in the Adjutant config → Wallpaper tab. A `dim` of 0.1–0.25 keeps the black UI legible.

## What this project will not do (licensing)

- Download assets from Aigei / the game package / the official site and commit them.
- Redistribute vector or raster redraws of the G&K / Sangvis / game logos (even traced ones can be
  derivative works).
- The bundled crest is an original design (hex frame + three wing chevrons + command star), not any
  official mark.
