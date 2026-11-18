#!/usr/bin/env python3
"""Generate GF-shell's visual assets.

Everything is drawn procedurally so the shell ships without third-party art.
The visual language follows Girls' Frontline's public interface: warm charcoal
surfaces, matte gold linework, halftone dots, topographic contours and thin
double frames.

* wallpapers  — charcoal / gold tactical boards with an original G&K-style crest
* emblem      — original hex + wing-chevron + command-star mark
* textures    — halftone / noise / hatch / scanline / tick tiles
* icon        — the shell's launcher icon

Run:  python3 scripts/gen_assets.py
"""
from __future__ import annotations

import math
import os
import random

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")
WALLS = os.path.join(ASSETS, "wallpapers")
TEX = os.path.join(ASSETS, "textures")
ICONS = os.path.join(ASSETS, "icons")

W, H = 1920, 1080

GOLD = (232, 189, 79)
GOLD_HI = (255, 217, 119)
GOLD_DIM = (125, 100, 40)
STEEL = (111, 155, 196)
CREAM = (242, 238, 227)
RED = (211, 74, 52)


# --------------------------------------------------------------------- utils
def ensure_dirs() -> None:
    for d in (WALLS, TEX, ICONS):
        os.makedirs(d, exist_ok=True)


def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


def vertical_gradient(size, top, bottom):
    w, h = size
    img = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(img)
    for y in range(h):
        d.line([(0, y), (w, y)], fill=lerp(top, bottom, y / max(1, h - 1)))
    return img


def radial_glow(size, center, radius, color, strength):
    w, h = size
    layer = Image.new("RGB", (w, h), (0, 0, 0))
    d = ImageDraw.Draw(layer)
    steps = 30
    for i in range(steps, 0, -1):
        t = i / steps
        r = radius * t
        a = strength * (1 - t) ** 2.2
        d.ellipse([center[0] - r, center[1] - r, center[0] + r, center[1] + r],
                  fill=tuple(int(c * a) for c in color))
    return layer.filter(ImageFilter.GaussianBlur(radius * 0.16))


def screen(base, layer):
    b = np.asarray(base).astype(np.float32) / 255.0
    l = np.asarray(layer).astype(np.float32) / 255.0
    out = 1.0 - (1.0 - b) * (1.0 - l)
    return Image.fromarray((out * 255.0).clip(0, 255).astype("uint8"))


def composite(img, layer):
    return Image.alpha_composite(img.convert("RGBA"), layer.convert("RGBA")).convert("RGB")


def grain(img, amount=4.5, seed=7):
    rnd = np.random.default_rng(seed)
    arr = np.asarray(img).astype(np.float32)
    noise = rnd.normal(0, amount, arr.shape[:2])[:, :, None]
    return Image.fromarray((arr + noise).clip(0, 255).astype("uint8"))


def vignette(img, strength=0.55, power=2.0):
    w, h = img.size
    yy, xx = np.mgrid[0:h, 0:w]
    cx, cy = w / 2.0, h / 2.0
    r = np.sqrt(((xx - cx) / cx) ** 2 + ((yy - cy) / cy) ** 2) / math.sqrt(2)
    mask = (1.0 - strength * (r ** power)).clip(0, 1)[:, :, None]
    arr = (np.asarray(img).astype(np.float32) * mask).clip(0, 255).astype("uint8")
    return Image.fromarray(arr)


# ------------------------------------------------------------------ patterns
def halftone(draw, size, origin, spread, color, max_alpha=26, step=11, fade=1.0):
    """Halftone dot field whose dots grow towards the corner origin."""
    ox, oy = origin
    w, h = size
    for y in range(int(oy), int(min(h, oy + spread)), step):
        for x in range(int(ox), int(min(w, ox + spread)), step):
            dx = (x - ox) / max(1, spread)
            dy = (y - oy) / max(1, spread)
            r = max(0.0, 1.0 - (dx * dx + dy * dy) * fade)
            if r <= 0.05:
                continue
            rad = 0.8 + r * 2.4
            a = int(max_alpha * r)
            draw.ellipse([x - rad, y - rad, x + rad, y + rad], fill=color + (a,))


def contours(draw, center, color, alpha=18, rings=16, spacing=62, seed=3, squash=1.45):
    """Topographic contour rings, like the base-management map background."""
    rnd = random.Random(seed)
    cx, cy = center
    for i in range(rings):
        base = 50 + i * spacing
        pts = []
        phase1 = rnd.uniform(0, math.tau)
        phase2 = rnd.uniform(0, math.tau)
        for a in range(0, 361, 5):
            ar = math.radians(a)
            r = base * (1 + 0.10 * math.sin(3 * ar + phase1) + 0.05 * math.sin(7 * ar + phase2))
            pts.append((cx + r * math.cos(ar) * squash, cy + r * math.sin(ar)))
        a = int(alpha * (0.45 + 0.55 * (1 - i / rings)))
        draw.line(pts, fill=color + (a,), width=1)



def iso_base(draw, origin, cols, rows, cell, color, alpha=16, seed=5):
    """Isometric line-art base cluster (an original nod to GFL's base screen)."""
    rnd = random.Random(seed)
    ox, oy = origin
    cw = cell
    ch = cell * 0.5

    def top_face(cx, cy, w, d):
        return [(cx, cy - d * 0.5), (cx + w * 0.5, cy), (cx, cy + d * 0.5), (cx - w * 0.5, cy)]

    for i in range(cols):
        for j in range(rows):
            if rnd.random() < 0.35:
                continue
            h = rnd.choice((0, 0, 1, 1, 2))
            w = cw * rnd.uniform(0.45, 0.9)
            d = ch * rnd.uniform(0.5, 1.0)
            cx = ox + i * cw * 0.55 - j * cw * 0.55
            cy = oy + i * ch * 0.55 + j * ch * 0.55
            lift = h * cw * 0.22
            top = top_face(cx, cy - lift, w, d)
            draw.polygon(top, outline=color + (alpha,), fill=color + (5,), width=1)
            # two visible side faces
            draw.polygon([top[3], top[2], (top[2][0], top[2][1] + lift), (top[3][0], top[3][1] + lift)],
                         outline=color + (int(alpha * 0.8),), fill=color + (3,), width=1)
            draw.polygon([top[1], top[2], (top[2][0], top[2][1] + lift), (top[1][0], top[1][1] + lift)],
                         outline=color + (int(alpha * 0.8),), fill=color + (3,), width=1)

    # roads: thin lines along the grid
    for i in range(cols):
        x0 = ox + i * cw * 0.55
        y0 = oy + i * ch * 0.55
        draw.line([(x0, y0), (x0 - (rows - 1) * cw * 0.55, y0 + (rows - 1) * ch * 0.55)],
                  fill=color + (max(4, alpha // 3),), width=1)


def gold_band(img, color, alpha=16, width=90, offset=0.0):
    """Wide translucent diagonal band on the right third."""
    w, h = img.size
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    slope = 1.35
    x_at_top = int(w * 0.60 + offset)
    d.polygon([
        (x_at_top, 0), (x_at_top + width, 0),
        (x_at_top + width - h * slope, h), (x_at_top - h * slope, h)
    ], fill=color + (alpha,))
    d.line([(x_at_top, 0), (x_at_top - h * slope, h)], fill=color + (min(255, alpha + 26),), width=1)
    d.line([(x_at_top + width, 0), (x_at_top + width - h * slope, h)],
           fill=color + (min(255, alpha + 14),), width=1)
    return composite(img, layer)


def inner_frame(draw, size, color, alpha=90, inset=26, notch=18):
    """Thin gold frame with notched corners (GFL panel frame)."""
    w, h = size
    x0, y0, x1, y1 = inset, inset, w - inset, h - inset
    c = notch
    pts = [
        (x0 + c, y0), (x1 - c, y0), (x1, y0 + c),
        (x1, y1 - c), (x1 - c, y1), (x0 + c, y1),
        (x0, y1 - c), (x0, y0 + c), (x0 + c, y0)
    ]
    draw.line(pts, fill=color + (alpha,), width=1)
    for x in (w // 2 - 30, w // 2 + 30):
        draw.line([(x, y0 - 4), (x, y0 + 4)], fill=color + (alpha + 40,), width=1)
    for y in (h // 2 - 30, h // 2 + 30):
        draw.line([(x0 - 4, y), (x0 + 4, y)], fill=color + (alpha + 40,), width=1)


def data_strip(draw, x, y, w, h, color, alpha=90, seed=11):
    rnd = random.Random(seed)
    cx = x
    while cx < x + w:
        bw = rnd.choice((1, 1, 2, 3, 4))
        gap = rnd.choice((2, 3, 4, 5))
        draw.rectangle([cx, y, cx + bw, y + h], fill=color + (alpha,))
        cx += bw + gap


# ------------------------------------------------------------------- emblem
def hex_points(cx, cy, r, rotation=0.0):
    return [(cx + r * math.cos(math.radians(60 * i + rotation)),
             cy + r * math.sin(math.radians(60 * i + rotation))) for i in range(6)]


def emblem_image(size=1024, fg=GOLD, stroke=6.0):
    """Hex frame + stacked wing chevrons + command star (original mark)."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = size / 1024.0

    def P(x, y):
        return (x * s, y * s)

    d.polygon([P(x, y) for (x, y) in hex_points(512, 512, 470, 30)],
              outline=fg + (255,), width=max(1, int(round(stroke * s))))
    d.polygon([P(x, y) for (x, y) in hex_points(512, 512, 428, 30)],
              outline=fg + (150,), width=max(1, int(round(2 * s))))

    d.line([P(512, 42), P(512, 108)], fill=fg + (220,), width=max(1, int(round(3 * s))))
    d.polygon([P(512, 126), P(523, 158), P(557, 158), P(530, 178),
               P(539, 212), P(512, 192), P(485, 212), P(494, 178),
               P(467, 158), P(501, 158)], fill=fg + (235,))

    for i, (y, half, w) in enumerate(((372, 214, 26), (478, 172, 24), (584, 128, 22))):
        pts = [P(512 - half, y + 46), P(512, y - 22), P(512 + half, y + 46)]
        d.line(pts, fill=fg + (240 - i * 22,), width=max(1, int(round(w * s))), joint="curve")

    d.rectangle([P(300, 714), P(724, 722)], fill=fg + (235,))
    for i in range(-3, 4):
        x = 512 + i * 58
        hh = 26 if i % 2 == 0 else 14
        d.line([P(x, 742), P(x, 742 + hh)], fill=fg + (180,), width=max(1, int(round(2 * s))))

    return img


def make_emblem_assets():
    emblem_image(1024, fg=GOLD).resize((512, 512), Image.LANCZOS).save(os.path.join(ICONS, "emblem.png"))
    for name, color in (("emblem-accent", GOLD), ("emblem-cream", CREAM), ("emblem-dim", (152, 146, 132))):
        emblem_image(1024, fg=color).resize((192, 192), Image.LANCZOS).save(
            os.path.join(ICONS, name + ".png"))

    icon = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    d = ImageDraw.Draw(icon)
    tile = [(52, 12), (460, 12), (500, 52), (500, 460), (460, 500), (52, 500), (12, 460), (12, 52)]
    d.polygon(tile, fill=(14, 13, 12, 255), outline=GOLD + (255,), width=5)
    d.polygon([(34, 34), (478, 34), (478, 478), (34, 478)], outline=GOLD + (70,), width=1)
    icon.alpha_composite(emblem_image(1024, fg=GOLD).resize((380, 380), Image.LANCZOS), (66, 66))
    icon.save(os.path.join(ASSETS, "icon.png"))


# ---------------------------------------------------------------- wallpapers
def build_wallpaper(seed, gold, accent2, filename, tone="ops"):
    rnd = random.Random(seed)

    top = lerp((22, 21, 18), (36, 34, 30), rnd.uniform(0.35, 0.75))
    bottom = lerp((12, 12, 11), (19, 18, 16), rnd.uniform(0.3, 0.8))
    img = vertical_gradient((W, H), top, bottom)

    img = screen(img, radial_glow((W, H), (int(W * 0.20), int(H * 0.86)), 1150, gold, 0.20))
    img = screen(img, radial_glow((W, H), (int(W * 0.86), int(H * 0.10)), 1000, accent2, 0.10))
    img = screen(img, radial_glow((W, H), (int(W * 0.55), int(H * 0.50)), 1300, (40, 38, 34), 0.22))

    mark = emblem_image(1024, fg=gold).resize((880, 880), Image.LANCZOS)
    r, g, b, a = mark.split()
    mark.putalpha(a.point(lambda v: int(v * 0.11)))
    img = img.convert("RGBA")
    img.alpha_composite(mark, (int(W * 0.55), int(H * 0.08)))
    img = img.convert("RGB")

    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)

    contours(d, (int(W * 0.22), int(H * 0.72)), (200, 192, 178), alpha=14, rings=12,
             spacing=70, seed=seed, squash=1.6)
    iso_base(d, (int(W * 0.30), int(H * 0.34)), 9, 8, 66, (205, 196, 180), alpha=13, seed=seed + 2)
    halftone(d, (W, H), (int(W * 0.03), int(H * 0.04)), int(W * 0.20), (230, 222, 205),
             max_alpha=22, step=12, fade=1.15)

    for x in range(0, W + 1, 64):
        d.line([(x, 0), (x, H)], fill=(220, 212, 195, 7 if x % 256 else 12))
    for y in range(0, H + 1, 64):
        d.line([(0, y), (W, y)], fill=(220, 212, 195, 7 if y % 256 else 12))

    for i, y in enumerate(range(80, H - 60, 26)):
        ln = 10 if i % 4 == 0 else 5
        d.line([(W - 34, y), (W - 34 + ln, y)], fill=gold + (70,), width=1)

    img = composite(img, layer)
    img = gold_band(img, gold, alpha=15 if tone != "sangvis" else 11, width=110, offset=0.0)

    layer2 = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d2 = ImageDraw.Draw(layer2)
    inner_frame(d2, (W, H), gold, alpha=80, inset=22, notch=26)
    data_strip(d2, W - 430, H - 66, 320, 26, gold, alpha=80, seed=seed + 5)
    for i in range(6):
        x = 60 + i * 210
        y = H - 54
        d2.rectangle([x, y, x + 140, y + 2], fill=(230, 222, 205, 22))
        d2.rectangle([x, y + 8, x + 56 + i * 8, y + 10], fill=(230, 222, 205, 14))
    img = composite(img, layer2)

    img = vignette(img, strength=0.5, power=2.2)
    img = grain(img, amount=4.0, seed=seed + 1)
    img.save(os.path.join(WALLS, filename))
    return img


# ------------------------------------------------------------------ textures
def make_textures():
    img = Image.new("RGBA", (4, 3), (0, 0, 0, 0))
    ImageDraw.Draw(img).line([(0, 0), (3, 0)], fill=(0, 0, 0, 40))
    img.save(os.path.join(TEX, "scanlines.png"))

    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for i in range(-16, 32, 6):
        d.line([(i, 16), (i + 16, 0)], fill=(255, 240, 210, 9), width=1)
    img.save(os.path.join(TEX, "hatch.png"))

    img = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([2, 2, 5, 5], fill=(235, 226, 208, 26))
    d.ellipse([14, 14, 17, 17], fill=(235, 226, 208, 18))
    d.ellipse([14, 2, 16, 4], fill=(235, 226, 208, 12))
    d.ellipse([2, 14, 4, 16], fill=(235, 226, 208, 12))
    img.save(os.path.join(TEX, "halftone.png"))

    rnd = np.random.default_rng(5)
    arr = rnd.normal(128, 24, (128, 128)).clip(0, 255).astype("uint8")
    tone = Image.fromarray(arr)
    noise = Image.merge("RGBA", (tone, tone, tone, Image.new("L", (128, 128), 22)))
    noise.save(os.path.join(TEX, "noise.png"))

    img = Image.new("RGBA", (8, 1), (0, 0, 0, 0))
    ImageDraw.Draw(img).line([(0, 0), (1, 0)], fill=(255, 255, 255, 45))
    img.save(os.path.join(TEX, "ticks.png"))


def main():
    ensure_dirs()
    make_textures()
    make_emblem_assets()
    build_wallpaper(11, GOLD, STEEL, "gfl-ops.png", "ops")
    build_wallpaper(23, RED, (180, 170, 150), "gfl-sangvis.png", "sangvis")
    build_wallpaper(37, (126, 178, 210), (90, 120, 160), "gfl-neural.png", "neural")
    build_wallpaper(53, (240, 164, 60), (160, 120, 80), "gfl-dusk.png", "dusk")
    print("assets written to", ASSETS)


if __name__ == "__main__":
    main()
