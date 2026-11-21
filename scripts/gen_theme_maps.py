#!/usr/bin/env python3
"""Generate subtle, dark desktop map backgrounds from local Natural Earth rasters."""
import math, os, random
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageOps

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "maps")
SRC_WORLD = "/usr/share/kgeography/world.png"
SRC_EUROPE = "/usr/share/kgeography/europe.png"
SERIF = "/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf"
SANS = "/usr/share/fonts/truetype/dejavu/DejaVuSansCondensed-Bold.ttf"
MONO = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"

PALETTES = {
    "hoi4": ["#343a23", "#44462a", "#535030", "#625a35", "#3c4631", "#4f4b31", "#2f3828", "#6a5f3c", "#443e27", "#5a4c31"],
    "bf1": ["#463d31", "#554838", "#665440", "#3b3730", "#4f4235", "#756148", "#5e4d39", "#372f28"],
    "bf4": ["#0b2029", "#0f2b35", "#143945", "#0a1a21", "#1a4554", "#12323d"],
    "gfl": ["#2b271d", "#3a3022", "#4a3b25", "#1f241b", "#5a4326", "#3d3525"],
}

def font(path, size):
    return ImageFont.truetype(path, size)

def load_source(path, water_colors, tol=14):
    im = Image.open(path).convert("RGB")
    arr = np.asarray(im).astype(np.int16)
    water = np.zeros(arr.shape[:2], dtype=bool)
    for c in water_colors:
        water |= (np.abs(arr - np.array(c)).max(axis=2) <= tol)
    return im, arr, water

def recolor(arr, water, color_list, border_color=(7, 8, 7)):
    h, w = arr.shape[:2]
    out = np.zeros((h, w, 3), dtype=np.uint8)
    # ocean is near-black, with a subtle blue-green shift for HoI4.
    out[:] = np.array([9, 11, 9], dtype=np.uint8)
    flat = arr.reshape(-1, 3)
    # FNV-ish deterministic mapping from source colour to palette.
    idx = ((flat[:, 0].astype(np.int32) * 73856093)
           ^ (flat[:, 1].astype(np.int32) * 19349663)
           ^ (flat[:, 2].astype(np.int32) * 83492791)) % len(color_list)
    pal = np.array([tuple(int(c[i:i + 2], 16) for i in (1, 3, 5)) for c in color_list], dtype=np.uint8)
    land = (~water.reshape(-1)) & (flat.max(axis=1) > 32)
    out.reshape(-1, 3)[land] = pal[idx[land]]
    # Preserve borders as a dark ink line.
    border = (~water.reshape(-1)) & (flat.max(axis=1) <= 32)
    out.reshape(-1, 3)[border] = np.array(border_color, dtype=np.uint8)
    return out

def fit(img, size=(1920, 1080)):
    return ImageOps.fit(img, size, method=Image.LANCZOS, centering=(0.5, 0.5))

def mercator(src, lat_top=84.0, lat_bottom=-58.0, out_lat_top=80.0, out_lat_bottom=-55.0,
             size=(1920, 1080)):
    src = np.asarray(src)
    h, w = src.shape[:2]
    W, H = size
    def m(lat):
        return math.log(math.tan(math.pi / 4 + math.radians(lat) / 2))
    m0, m1 = m(out_lat_top), m(out_lat_bottom)
    out = np.zeros((H, W, 3), dtype=np.uint8)
    for y in range(H):
        lat = math.degrees(2 * math.atan(math.exp(m0 + (m1 - m0) * y / (H - 1))) - math.pi / 2)
        sy = int(round((lat_top - lat) / (lat_top - lat_bottom) * (h - 1)))
        sy = max(0, min(h - 1, sy))
        row = src[sy]
        # Stretch horizontally to fill 16:9.
        row2 = np.asarray(Image.fromarray(row[np.newaxis, :, :]).resize((W, 1), Image.BILINEAR))[0]
        out[y] = row2
    return Image.fromarray(out)

def grain(im, seed=7, strength=7):
    rng = np.random.default_rng(seed)
    arr = np.asarray(im).astype(np.int16)
    n = rng.normal(0, strength, (arr.shape[0], arr.shape[1], 1))
    arr = np.clip(arr + n, 0, 255).astype(np.uint8)
    return Image.fromarray(arr)

def vignette(im, power=2.1, strength=0.62):
    arr = np.asarray(im).astype(np.float32)
    h, w = arr.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    cx, cy = w / 2, h / 2
    r = np.sqrt(((xx - cx) / cx) ** 2 + ((yy - cy) / cy) ** 2) / math.sqrt(2)
    v = 1 - strength * np.clip(r, 0, 1) ** power
    arr *= v[..., None]
    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))

def grid(draw, box, step=96, color=(200, 170, 90, 26), lat_lines=None):
    x0, y0, x1, y1 = box
    for x in range(x0, x1, step):
        draw.line([(x, y0), (x, y1)], fill=color, width=1)
    if lat_lines:
        for y in lat_lines:
            draw.line([(x0, y), (x1, y)], fill=color, width=1)
    else:
        for y in range(y0, y1, step):
            draw.line([(x0, y), (x1, y)], fill=color, width=1)

def border(draw, box, color=(200, 170, 90, 90)):
    x0, y0, x1, y1 = box
    draw.rectangle([x0, y0, x1, y1], outline=color, width=2)
    draw.rectangle([x0 + 8, y0 + 8, x1 - 8, y1 - 8], outline=(200, 170, 90, 30), width=1)

def label(draw, xy, text, f, fill, anchor="la", spacing=0):
    if spacing:
        text = (" " * spacing).join(list(text))
    draw.text(xy, text, font=f, fill=fill, anchor=anchor)

# --------------------------------------------------------------------- HoI4
def hoi4():
    im, arr, water = load_source(SRC_WORLD, [(255, 255, 255), (175, 238, 238)])
    rec = recolor(arr, water, PALETTES["hoi4"], border_color=(10, 10, 7))
    im = mercator(Image.fromarray(rec))
    im = fit(im, (1920, 1080))
    im = grain(im, 11, 6)
    im = vignette(im, 2.0, 0.62)
    # Tint sea slightly olive and add a parchment layer.
    arr = np.asarray(im).astype(np.float32)
    sea = (arr.max(axis=2) < 22)
    arr[sea] = arr[sea] * 0.75 + np.array([9, 11, 7]) * 0.25
    im = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8)).convert("RGBA")
    ov = Image.new("RGBA", im.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    border(d, (54, 64, 1866, 1016), (206, 174, 92, 95))
    # Mercator graticule.
    for lon in range(-180, 181, 30):
        x = 54 + (lon + 180) / 360 * (1812)
        d.line([(x, 70), (x, 1014)], fill=(196, 168, 92, 18), width=1)
    m_top, m_bot = math.log(math.tan(math.pi / 4 + math.radians(80) / 2)), math.log(math.tan(math.pi / 4 + math.radians(-55) / 2))
    for lat in range(-50, 81, 20):
        mm = math.log(math.tan(math.pi / 4 + math.radians(lat) / 2))
        y = 70 + (m_top - mm) / (m_top - m_bot) * 944
        d.line([(70, y), (1850, y)], fill=(196, 168, 92, 18), width=1)
    # Map labels and campaign arrows.
    f_title = font(SERIF, 24); f_sub = font(MONO, 13); f_cap = font(SANS, 14); f_small = font(MONO, 11)
    label(d, (80, 82), "THE WORLD", f_title, (226, 207, 155, 185), spacing=1)
    label(d, (80, 112), "MERCATOR PROJECTION  ·  GENERAL STAFF CARTOGRAPHY", f_sub, (196, 168, 92, 145), spacing=1)
    for text, x, y in [("EUROPE", 975, 265), ("AFRICA", 955, 560), ("ASIA", 1360, 330),
                       ("NORTH AMERICA", 310, 310), ("SOUTH AMERICA", 590, 700), ("OCEANIA", 1530, 790)]:
        label(d, (x, y), text, f_cap, (226, 207, 155, 100), anchor="mm", spacing=1)
    # Faction pin markers.
    for x, y in [(1000, 300), (1170, 280), (880, 330), (1400, 430), (460, 350)]:
        d.rectangle([x - 5, y - 5, x + 5, y + 5], outline=(232, 200, 112, 150), width=1)
        d.line([(x - 8, y), (x + 8, y)], fill=(232, 200, 112, 80), width=1)
    label(d, (1840, 980), "1936 — 1948", f_sub, (196, 168, 92, 140), anchor="rs")
    label(d, (70, 1040), "CLASSIFIED · NATIONAL COMMAND", f_small, (196, 168, 92, 100))
    im = Image.alpha_composite(im, ov)
    im.convert("RGB").save(os.path.join(OUT, "hoi4-world-mercator.png"), optimize=True)

# --------------------------------------------------------------------- BF1
def bf1():
    im, arr, water = load_source(SRC_EUROPE, [(65, 95, 173), (175, 238, 238), (2, 206, 206)])
    rec = recolor(arr, water, PALETTES["bf1"], border_color=(20, 17, 12))
    im = fit(Image.fromarray(rec), (1920, 1080))
    im = grain(im, 4, 8)
    im = vignette(im, 2.0, 0.65)
    im = im.convert("RGBA")
    ov = Image.new("RGBA", im.size, (0, 0, 0, 0)); d = ImageDraw.Draw(ov)
    border(d, (54, 64, 1866, 1016), (201, 160, 90, 120))
    grid(d, (64, 74, 1856, 1006), 120, (201, 160, 90, 18))
    f_title = font(SERIF, 25); f_sub = font(MONO, 13); f_cap = font(SANS, 15); f_small = font(MONO, 11)
    label(d, (82, 82), "EUROPEAN THEATRE", f_title, (238, 218, 176, 180), spacing=1)
    label(d, (82, 114), "1914 — 1918  ·  WESTERN / EASTERN / ITALIAN FRONTS", f_sub, (201, 160, 90, 145), spacing=1)
    for text, x, y in [("WESTERN FRONT", 620, 490), ("EASTERN FRONT", 1400, 470),
                       ("ITALIAN FRONT", 1110, 720), ("BALKANS", 1330, 760),
                       ("NORTH SEA", 620, 270), ("MEDITERRANEAN", 900, 900)]:
        label(d, (x, y), text, f_cap, (238, 218, 176, 105), anchor="mm", spacing=1)
    # Front lines.
    for x in range(520, 900, 8):
        yy = 480 + math.sin(x / 70) * 26
        d.line([(x, yy), (x, yy - 2)], fill=(155, 58, 42, 100), width=1)
    for x in range(1180, 1660, 8):
        yy = 470 + math.sin(x / 90) * 38
        d.line([(x, yy), (x, yy - 2)], fill=(155, 58, 42, 90), width=1)
    # Battle markers.
    for text, x, y in [("YPRES", 560, 380), ("VERDUN", 700, 610), ("SOMME", 640, 520), ("GALLIPOLI", 1330, 860)]:
        d.ellipse([x - 4, y - 4, x + 4, y + 4], outline=(220, 170, 90, 120), width=1)
        label(d, (x + 12, y), text, f_small, (238, 218, 176, 125))
    label(d, (1840, 980), "FIELD CARTOGRAPHY · ALLIED HQ", f_small, (201, 160, 90, 110), anchor="rs")
    im = Image.alpha_composite(im, ov)
    im.convert("RGB").save(os.path.join(OUT, "bf1-europe.png"), optimize=True)

# --------------------------------------------------------------------- BF4
def bf4():
    im, arr, water = load_source(SRC_WORLD, [(255, 255, 255), (175, 238, 238)])
    rec = recolor(arr, water, PALETTES["bf4"], border_color=(2, 16, 22))
    im = fit(Image.fromarray(rec), (1920, 1080))
    im = grain(im, 9, 5)
    im = vignette(im, 2.2, 0.58)
    im = im.convert("RGBA")
    ov = Image.new("RGBA", im.size, (0, 0, 0, 0)); d = ImageDraw.Draw(ov)
    border(d, (54, 64, 1866, 1016), (43, 143, 176, 105))
    for x in range(54, 1866, 96):
        d.line([(x, 64), (x, 1016)], fill=(43, 143, 176, 16), width=1)
    for y in range(64, 1016, 96):
        d.line([(54, y), (1866, y)], fill=(43, 143, 176, 16), width=1)
    f_title = font(SANS, 26); f_sub = font(MONO, 13); f_cap = font(SANS, 14); f_small = font(MONO, 10)
    label(d, (82, 82), "GLOBAL THEATER", f_title, (180, 232, 245, 165), spacing=1)
    label(d, (82, 116), "COMMANDER OVERVIEW  ·  LIVE OPERATIONS GRID", f_sub, (43, 143, 176, 150), spacing=1)
    for text, x, y in [("NORTH AMERICA", 330, 330), ("EUROPE", 1020, 280), ("MIDDLE EAST", 1120, 500),
                       ("EAST ASIA", 1450, 420), ("SOUTH AMERICA", 590, 760), ("OCEANIA", 1540, 800)]:
        label(d, (x, y), text, f_cap, (180, 232, 245, 100), anchor="mm", spacing=1)
    # Operation markers and network arcs.
    pts = [(520, 380), (1020, 300), (1160, 520), (1450, 440), (1500, 760)]
    for i in range(len(pts) - 1):
        d.arc([pts[i][0], pts[i][1] - 80, pts[i + 1][0], pts[i + 1][1] + 80], 200, 340, fill=(43, 143, 176, 55), width=1)
    for x, y in pts:
        d.rectangle([x - 6, y - 6, x + 6, y + 6], outline=(96, 210, 230, 150), width=1)
        d.line([(x - 10, y), (x + 10, y)], fill=(96, 210, 230, 80), width=1)
        d.line([(x, y - 10), (x, y + 10)], fill=(96, 210, 230, 80), width=1)
    label(d, (1840, 980), "TACTICAL NETWORK // SECURE", f_small, (43, 143, 176, 130), anchor="rs")
    im = Image.alpha_composite(im, ov)
    im.convert("RGB").save(os.path.join(OUT, "bf4-world.png"), optimize=True)

# --------------------------------------------------------------------- GFL
def gfl():
    im, arr, water = load_source(SRC_EUROPE, [(65, 95, 173), (175, 238, 238), (2, 206, 206)])
    rec = recolor(arr, water, PALETTES["gfl"], border_color=(16, 13, 9))
    im = fit(Image.fromarray(rec), (1920, 1080))
    im = grain(im, 3, 7)
    im = vignette(im, 2.0, 0.66)
    im = im.convert("RGBA")
    ov = Image.new("RGBA", im.size, (0, 0, 0, 0)); d = ImageDraw.Draw(ov)
    border(d, (54, 64, 1866, 1016), (201, 162, 74, 90))
    grid(d, (64, 74, 1856, 1006), 120, (201, 162, 74, 16))
    f_title = font(SERIF, 25); f_sub = font(MONO, 13); f_cap = font(SANS, 14); f_small = font(MONO, 10)
    label(d, (82, 82), "THE CONTINENT", f_title, (238, 222, 190, 175), spacing=1)
    label(d, (82, 114), "POST-COLLAPSE OPERATIONS MAP  ·  SECTOR 09", f_sub, (201, 162, 74, 145), spacing=1)
    for text, x, y in [("SECTOR 09", 690, 500), ("SECTOR 11", 1160, 610), ("SECTOR 05", 850, 360),
                       ("SANGVIS FERRI", 1080, 720), ("NEURAL CLOUD", 1450, 400), ("ARCTIC OPS", 800, 240)]:
        label(d, (x, y), text, f_cap, (238, 222, 190, 95), anchor="mm", spacing=1)
    # Contamination halos.
    for x, y, r in [(980, 500, 150), (1180, 680, 120), (1450, 420, 110)]:
        for rr in range(r, 12, -18):
            d.ellipse([x - rr, y - rr, x + rr, y + rr], outline=(155, 58, 42, 20), width=1)
    # Griffin routes and nodes.
    for x, y in [(760, 480), (980, 500), (1160, 610), (1450, 400)]:
        d.rectangle([x - 5, y - 5, x + 5, y + 5], outline=(232, 189, 79, 130), width=1)
        d.line([(x - 9, y), (x + 9, y)], fill=(232, 189, 79, 70), width=1)
    d.line([(760, 480), (980, 500), (1160, 610), (1450, 400)], fill=(232, 189, 79, 55), width=1)
    label(d, (1840, 980), "GRIFFIN & KRYUGER // TACTICAL COMMAND", f_small, (201, 162, 74, 115), anchor="rs")
    im = Image.alpha_composite(im, ov)
    im.convert("RGB").save(os.path.join(OUT, "gfl-continent.png"), optimize=True)

# --------------------------------------------------------------------- Arknights terra/Rhodes Island
def ark():
    W, H = 1920, 1080
    bg = (7, 11, 13)
    im = Image.new("RGBA", (W, H), bg + (255,))
    d = ImageDraw.Draw(im, "RGBA")
    rng = random.Random(44)
    # Ocean grid and survey marks.
    for x in range(0, W, 96):
        d.line([(x, 0), (x, H)], fill=(63, 212, 230, 10), width=1)
    for y in range(0, H, 96):
        d.line([(0, y), (W, y)], fill=(63, 212, 230, 10), width=1)
    # Landmass silhouette: a long continent with a bay and peninsulas.
    cx, cy = 920, 560
    pts = []
    n = 180
    for i in range(n):
        a = 2 * math.pi * i / n
        wobble = (0.22 * math.sin(3 * a + 0.8) + 0.10 * math.sin(7 * a + 1.7)
                  + 0.05 * math.sin(13 * a + 0.3))
        rx = 470 * (1 + wobble) * (0.80 if math.cos(a) < 0 else 1.0)
        ry = 300 * (1 + wobble * 0.75)
        pts.append((cx + math.cos(a) * rx, cy + math.sin(a) * ry))
    # Cut a large southern bay.
    bay = [(cx - 120, H), (cx + 20, 760), (cx + 120, 760), (cx + 260, H)]
    land_mask = Image.new("L", (W, H), 0)
    ld = ImageDraw.Draw(land_mask)
    ld.polygon(pts, fill=255)
    ld.polygon(bay, fill=0)
    # Apply soft land fill.
    land = Image.new("RGBA", (W, H), (15, 22, 24, 255))
    land.putalpha(land_mask.filter(ImageFilter.GaussianBlur(1)))
    im = Image.alpha_composite(im, land)
    d = ImageDraw.Draw(im, "RGBA")
    d.line(pts + [pts[0]], fill=(99, 145, 150, 120), width=2)
    # Archipelago.
    for (ix, iy, rr) in [(1430, 300, 34), (1480, 340, 20), (320, 760, 28), (380, 790, 17),
                         (1580, 800, 24), (1500, 850, 14), (520, 290, 18), (470, 320, 10)]:
        d.ellipse([ix - rr, iy - rr * 0.7, ix + rr, iy + rr * 0.7], fill=(15, 22, 24, 255), outline=(99, 145, 150, 100), width=1)
    # Province boundaries clipped roughly to the land mass.
    prov = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    pd = ImageDraw.Draw(prov, "RGBA")
    for i in range(11):
        ox, oy = rng.randint(-80, 80), rng.randint(-60, 60)
        x0, y0 = 920 + ox, 560 + oy
        a = rng.uniform(0, math.pi)
        L = 520
        pd.line([(x0 - math.cos(a) * L, y0 - math.sin(a) * L), (x0 + math.cos(a) * L, y0 + math.sin(a) * L)],
                fill=(63, 212, 230, 26), width=1)
    prov.putalpha(Image.composite(prov.getchannel("A"), Image.new("L", (W, H), 0), land_mask))
    im = Image.alpha_composite(im, prov)
    d = ImageDraw.Draw(im, "RGBA")
    # Coast contour rings.
    for k in (0.94, 0.86, 0.78):
        cp = [(cx + (x - cx) * k, cy + (y - cy) * k) for x, y in pts]
        d.line(cp + [cp[0]], fill=(99, 145, 150, 35), width=1)
    # Survey routes and city nodes.
    nodes = [(700, 500), (900, 560), (1080, 520), (1170, 650), (810, 680), (1370, 360)]
    for i in range(len(nodes) - 1):
        x1, y1 = nodes[i]; x2, y2 = nodes[i + 1]
        # dashed line
        steps = 14
        for s in range(0, steps, 2):
            d.line([(x1 + (x2 - x1) * s / steps, y1 + (y2 - y1) * s / steps),
                    (x1 + (x2 - x1) * (s + 1) / steps, y1 + (y2 - y1) * (s + 1) / steps)],
                   fill=(207, 232, 232, 55), width=1)
    for x, y in nodes:
        d.rectangle([x - 5, y - 5, x + 5, y + 5], outline=(207, 232, 232, 160), width=1)
        d.ellipse([x - 2, y - 2, x + 2, y + 2], fill=(63, 212, 230, 180))
    # Labels.
    f_title = font(SANS, 26); f_sub = font(MONO, 13); f_cap = font(SANS, 14); f_small = font(MONO, 10); f_big = font(SANS, 30)
    label(d, (70, 70), "TERRA", f_title, (207, 232, 232, 175), spacing=1)
    label(d, (70, 104), "RHODES ISLAND CARTOGRAPHIC ARCHIVE  //  LAND SURVEY", f_sub, (63, 212, 230, 135), spacing=1)
    for text, x, y in [("VICTORIA", 800, 380), ("KAZIMIERZ", 1120, 430), ("URSIUS", 1370, 330),
                       ("COLUMBIA", 580, 620), ("SIESTA", 1080, 760), ("SARGON", 1280, 600),
                       ("LEITHANEN", 720, 760), ("HIGASHI", 1480, 760)]:
        label(d, (x, y), text, f_cap, (207, 232, 232, 105), anchor="mm", spacing=1)
    label(d, (920, 640), "RHODES ISLAND", f_big, (207, 232, 232, 165), anchor="mm", spacing=2)
    label(d, (920, 668), "MOBILE CITY  ·  LAND SURVEY 04", f_small, (63, 212, 230, 120), anchor="mm", spacing=1)
    border(d, (54, 64, 1866, 1016), (63, 212, 230, 75))
    # Compass rose.
    ccx, ccy = 1760, 900
    d.ellipse([ccx - 36, ccy - 36, ccx + 36, ccy + 36], outline=(63, 212, 230, 55), width=1)
    d.line([(ccx, ccy - 30), (ccx, ccy + 30)], fill=(207, 232, 232, 100), width=1)
    d.line([(ccx - 30, ccy), (ccx + 30, ccy)], fill=(207, 232, 232, 100), width=1)
    label(d, (ccx, ccy - 46), "N", f_small, (207, 232, 232, 150), anchor="mm")
    label(d, (1840, 980), "TERRA // CARTOGRAPHY DIVISION", f_small, (63, 212, 230, 110), anchor="rs")
    im.convert("RGB").save(os.path.join(OUT, "arknights-rhodes.png"), optimize=True)

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    hoi4(); bf1(); bf4(); gfl(); ark()
    for n in ["hoi4-world-mercator.png", "bf1-europe.png", "bf4-world.png", "gfl-continent.png", "arknights-rhodes.png"]:
        p = os.path.join(OUT, n)
        print(n, Image.open(p).size, os.path.getsize(p))
