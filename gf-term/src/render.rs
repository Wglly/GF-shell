use std::collections::HashMap;

use fontdb::{Family, Query, Stretch, Style, Weight};
use fontdue::{Font, FontSettings};

use crate::terminal::{
    ColorSpec, Terminal, ATTR_BOLD, ATTR_DIM, ATTR_INVISIBLE, ATTR_REVERSE, ATTR_STRIKE,
    ATTR_UNDERLINE,
};
use crate::theme::{Rgb, Theme};

const TITLE_H: usize = 36;
const PAD: usize = 10;

struct Glyph {
    width: usize,
    height: usize,
    xmin: i32,
    ymin: i32,
    bitmap: Vec<u8>,
}

pub struct Renderer {
    pub theme: Theme,
    pub font_size: f32,
    pub cell_w: usize,
    pub cell_h: usize,
    ascent: f32,
    fonts: Vec<Font>,
    cache: HashMap<(usize, char), Glyph>,
}

pub struct Canvas<'a> {
    pub buf: &'a mut [u32],
    pub w: usize,
    pub h: usize,
}

impl<'a> Canvas<'a> {
    #[inline]
    fn px(&mut self, x: i32, y: i32, c: Rgb, alpha: f32) {
        if x < 0 || y < 0 || x as usize >= self.w || y as usize >= self.h {
            return;
        }
        let idx = y as usize * self.w + x as usize;
        let a = alpha.clamp(0.0, 1.0);
        if a <= 0.0 {
            return;
        }
        if a >= 1.0 {
            self.buf[idx] = c.to_u32();
            return;
        }
        let d = self.buf[idx];
        let dr = ((d >> 16) & 0xff) as f32;
        let dg = ((d >> 8) & 0xff) as f32;
        let db = (d & 0xff) as f32;
        let r = (c.r as f32 * a + dr * (1.0 - a)).round() as u32;
        let g = (c.g as f32 * a + dg * (1.0 - a)).round() as u32;
        let b = (c.b as f32 * a + db * (1.0 - a)).round() as u32;
        self.buf[idx] = (r << 16) | (g << 8) | b;
    }

    pub fn fill(&mut self, c: Rgb) {
        for p in self.buf.iter_mut() {
            *p = c.to_u32();
        }
    }

    pub fn rect(&mut self, x: i32, y: i32, w: i32, h: i32, c: Rgb) {
        let x0 = x.max(0) as usize;
        let y0 = y.max(0) as usize;
        let x1 = (x + w).max(0).min(self.w as i32) as usize;
        let y1 = (y + h).max(0).min(self.h as i32) as usize;
        for yy in y0..y1 {
            for xx in x0..x1 {
                self.buf[yy * self.w + xx] = c.to_u32();
            }
        }
    }
}

impl Renderer {
    pub fn new(theme: Theme, font_size: f32) -> Self {
        let mut db = fontdb::Database::new();
        db.load_system_fonts();
        let mut fonts = Vec::new();
        let wanted = [
            theme.font.as_str(),
            "Noto Sans Mono CJK SC",
            "MapleMonoNormal NF CN",
            "JetBrainsMono Nerd Font",
            "Noto Sans CJK SC",
            "DejaVu Sans Mono",
            "monospace",
        ];
        for name in wanted {
            let family = if name == "monospace" {
                Family::Monospace
            } else {
                Family::Name(name)
            };
            let q = Query {
                families: &[family],
                weight: Weight::NORMAL,
                stretch: Stretch::Normal,
                style: Style::Normal,
            };
            if let Some(id) = db.query(&q) {
                let data = db.with_face_data(id, |data, _| data.to_vec());
                if let Some(data) = data {
                    if let Ok(f) = Font::from_bytes(data, FontSettings::default()) {
                        if !fonts
                            .iter()
                            .any(|x: &Font| std::ptr::eq(x as *const _, &f as *const _))
                        {
                            fonts.push(f);
                        }
                    }
                }
            }
        }
        if fonts.is_empty() {
            if let Some(id) = db.query(&Query {
                families: &[Family::Monospace],
                ..Default::default()
            }) {
                if let Some(data) = db.with_face_data(id, |data, _| data.to_vec()) {
                    if let Ok(f) = Font::from_bytes(data, FontSettings::default()) {
                        fonts.push(f);
                    }
                }
            }
        }
        if fonts.is_empty() {
            // A built-in fallback cannot be assumed; use a tiny safe font from the system.
            if let Some(id) = db.query(&Query::default()) {
                if let Some(data) = db.with_face_data(id, |data, _| data.to_vec()) {
                    if let Ok(f) = Font::from_bytes(data, FontSettings::default()) {
                        fonts.push(f);
                    }
                }
            }
        }
        let primary = fonts.first().expect("no usable system font found");
        let lm = primary
            .horizontal_line_metrics(font_size)
            .unwrap_or(fontdue::LineMetrics {
                ascent: font_size * 0.8,
                descent: -font_size * 0.2,
                line_gap: 0.0,
                new_line_size: font_size,
            });
        let cell_h = (lm.ascent - lm.descent + lm.line_gap)
            .ceil()
            .max(font_size * 1.0) as usize
            + 2;
        let cell_w = primary
            .metrics('M', font_size)
            .advance_width
            .ceil()
            .max(font_size * 0.55) as usize;
        Self {
            theme,
            font_size,
            cell_w,
            cell_h,
            ascent: lm.ascent,
            fonts,
            cache: HashMap::new(),
        }
    }

    pub fn cols_rows(&self, width: usize, height: usize) -> (usize, usize) {
        let cols = width.saturating_sub(PAD * 2) / self.cell_w.max(1);
        let rows = height.saturating_sub(TITLE_H + PAD) / self.cell_h.max(1);
        (cols.max(20), rows.max(4))
    }

    fn pick_font(&self, ch: char) -> usize {
        for (i, f) in self.fonts.iter().enumerate() {
            if f.has_glyph(ch) {
                return i;
            }
        }
        0
    }

    fn glyph(&mut self, ch: char) -> (usize, &Glyph) {
        let fi = self.pick_font(ch);
        let key = (fi, ch);
        if !self.cache.contains_key(&key) {
            let f = &self.fonts[fi];
            let (m, bitmap) = f.rasterize(ch, self.font_size);
            self.cache.insert(
                key,
                Glyph {
                    width: m.width,
                    height: m.height,
                    xmin: m.xmin,
                    ymin: m.ymin,
                    bitmap,
                },
            );
        }
        (fi, self.cache.get(&key).unwrap())
    }

    fn color_fg(&self, spec: ColorSpec) -> Rgb {
        match spec {
            ColorSpec::DefaultFg => self.theme.text,
            ColorSpec::DefaultBg => self.theme.text,
            ColorSpec::Indexed(i) => self.theme.color_256(i),
            ColorSpec::Rgb(c) => c,
        }
    }

    fn color_bg(&self, spec: ColorSpec) -> Rgb {
        match spec {
            ColorSpec::DefaultFg | ColorSpec::DefaultBg => self.theme.bg,
            ColorSpec::Indexed(i) => self.theme.color_256(i),
            ColorSpec::Rgb(c) => c,
        }
    }

    fn draw_glyph(
        &mut self,
        canvas: &mut Canvas,
        ch: char,
        x: i32,
        baseline: i32,
        fg: Rgb,
        bold: bool,
    ) {
        if ch == ' ' || ch == '\0' {
            return;
        }
        let (_, g) = self.glyph(ch);
        let gx = x + g.xmin;
        let gy = baseline - g.ymin - g.height as i32;
        let fg2 = if bold { fg.lighten(0.22) } else { fg };
        for yy in 0..g.height {
            for xx in 0..g.width {
                let a = g.bitmap[yy * g.width + xx] as f32 / 255.0;
                if a <= 0.0 {
                    continue;
                }
                canvas.px(gx + xx as i32, gy + yy as i32, fg2, a);
                if bold {
                    canvas.px(gx + xx as i32 + 1, gy + yy as i32, fg2, a * 0.55);
                }
            }
        }
    }

    pub fn text_width(&mut self, text: &str) -> usize {
        let mut w = 0usize;
        for ch in text.chars() {
            let (_, g) = self.glyph(ch);
            w += if ch.is_ascii() {
                self.cell_w
            } else {
                g.width.max(self.cell_w / 2)
            };
        }
        w
    }

    pub fn draw_text(
        &mut self,
        canvas: &mut Canvas,
        text: &str,
        mut x: i32,
        baseline: i32,
        color: Rgb,
        bold: bool,
    ) {
        for ch in text.chars() {
            let (_, g) = self.glyph(ch);
            let adv = if ch.is_ascii() {
                self.cell_w
            } else {
                g.width.max(self.cell_w / 2) + 1
            };
            self.draw_glyph(canvas, ch, x, baseline, color, bold);
            x += adv as i32;
        }
    }

    fn blend_image(
        &self,
        canvas: &mut Canvas,
        x: i32,
        y: i32,
        max_w: usize,
        max_h: usize,
        img: &image::RgbaImage,
    ) {
        if img.width() == 0 || img.height() == 0 {
            return;
        }
        let scale =
            ((max_w as f32 / img.width() as f32).min(max_h as f32 / img.height() as f32)).min(1.0);
        let dw = (img.width() as f32 * scale).max(1.0) as usize;
        let dh = (img.height() as f32 * scale).max(1.0) as usize;
        for yy in 0..dh {
            for xx in 0..dw {
                let sx = (xx as f32 / scale) as u32;
                let sy = (yy as f32 / scale) as u32;
                if sx >= img.width() || sy >= img.height() {
                    continue;
                }
                let p = img.get_pixel(sx, sy);
                let a = p[3] as f32 / 255.0;
                if a > 0.0 {
                    canvas.px(x + xx as i32, y + yy as i32, Rgb::new(p[0], p[1], p[2]), a);
                }
            }
        }
    }

    pub fn draw(
        &mut self,
        canvas: &mut Canvas,
        term: &Terminal,
        window_title: &str,
        close_hover: bool,
        preset: &str,
    ) {
        let bg = self.theme.bg;
        let panel = self.theme.panel;
        let panel_alt = self.theme.panel_alt;
        let gold = self.theme.gold;
        let accent = self.theme.accent;
        let text = self.theme.text;
        let ink = self.theme.ink;
        canvas.fill(bg);

        // Title bar.
        canvas.rect(0, 0, canvas.w as i32, TITLE_H as i32, panel_alt);
        canvas.rect(0, TITLE_H as i32 - 1, canvas.w as i32, 1, gold.darken(0.1));
        canvas.rect(0, 0, 5, TITLE_H as i32, gold);
        let base = (TITLE_H as f32 * 0.68) as i32;
        self.draw_text(canvas, "GF TERMINAL", 18, base, gold, true);
        let tw = self.text_width("GF TERMINAL");
        self.draw_text(
            canvas,
            "//",
            18 + tw as i32 + 8,
            base,
            self.theme.text_faint,
            false,
        );
        self.draw_text(
            canvas,
            &preset.to_uppercase(),
            18 + tw as i32 + 28,
            base,
            self.theme.text_dim,
            false,
        );
        let title = window_title.replace('\n', " ");
        let max_chars = ((canvas.w.saturating_sub(380)) / self.cell_w.max(1)).max(8);
        let title: String = title.chars().take(max_chars).collect();
        let title_x = (canvas.w / 2) as i32 - self.text_width(&title) as i32 / 2;
        self.draw_text(canvas, &title, title_x.max(250), base, text, false);
        // controls
        let cx = canvas.w as i32 - 28;
        canvas.rect(
            cx - 8,
            9,
            22,
            20,
            if close_hover {
                self.theme.accent
            } else {
                panel
            },
        );
        self.draw_text(
            canvas,
            "x",
            cx - 2,
            base,
            if close_hover { ink } else { text },
            false,
        );
        let mx = canvas.w as i32 - 58;
        self.draw_text(canvas, "_", mx, base, self.theme.text_dim, false);
        // thin outer border
        canvas.rect(0, 1, 1, canvas.h as i32, self.theme.line);
        canvas.rect(canvas.w as i32 - 1, 1, 1, canvas.h as i32, self.theme.line);

        let (cols, rows) = (term.grid.cols, term.grid.rows);
        let cell_w = self.cell_w as i32;
        let cell_h = self.cell_h as i32;
        let origin_x = PAD as i32;
        let origin_y = TITLE_H as i32 + 2;
        let view_rows = rows.min(((canvas.h.saturating_sub(TITLE_H + PAD)) / self.cell_h).max(1));
        for y in 0..view_rows {
            for x in 0..cols {
                let cell = term.visible_cell(x, y);
                let mut fg = self.color_fg(cell.fg);
                let mut bgc = self.color_bg(cell.bg);
                if cell.attr & ATTR_REVERSE != 0 {
                    std::mem::swap(&mut fg, &mut bgc);
                }
                if cell.attr & ATTR_DIM != 0 {
                    fg = fg.mix(self.theme.bg, 0.35);
                }
                if cell.attr & ATTR_INVISIBLE != 0 {
                    fg = bgc;
                }
                if cell.attr & ATTR_BOLD != 0 && matches!(cell.fg, ColorSpec::Indexed(0..=7)) {
                    fg = fg.lighten(0.18);
                }
                let px = origin_x + x as i32 * cell_w;
                let py = origin_y + y as i32 * cell_h;
                canvas.rect(px, py, cell_w, cell_h, bgc);
                if cell.ch != ' ' && !(cell.wide && cell.ch == ' ') {
                    let baseline = py + self.ascent as i32;
                    let draw_x = px + 1 + if cell.wide { 1 } else { 0 };
                    self.draw_glyph(
                        canvas,
                        cell.ch,
                        draw_x,
                        baseline,
                        fg,
                        cell.attr & ATTR_BOLD != 0,
                    );
                    if cell.attr & ATTR_UNDERLINE != 0 {
                        canvas.rect(px, py + cell_h - 3, cell_w, 1, fg);
                    }
                    if cell.attr & ATTR_STRIKE != 0 {
                        canvas.rect(px, py + cell_h / 2, cell_w, 1, fg);
                    }
                }
            }
        }
        // Cursor.
        if term.view_offset == 0 && term.grid.cursor_visible {
            let px = origin_x + term.grid.cx as i32 * cell_w;
            let py = origin_y + term.grid.cy as i32 * cell_h;
            canvas.rect(px, py, cell_w, cell_h, accent);
            let cell = term.grid.cell(term.grid.cx, term.grid.cy);
            let ch = if cell.ch == ' ' { ' ' } else { cell.ch };
            if ch != ' ' {
                self.draw_glyph(canvas, ch, px + 1, py + self.ascent as i32, ink, false);
            }
        }
        // Images (Kitty graphics).
        if term.view_offset == 0 {
            let max_w = canvas.w.saturating_sub(PAD * 2);
            let max_h = canvas.h.saturating_sub(TITLE_H + PAD);
            for p in &term.images {
                if p.row < 0 {
                    continue;
                }
                let x = origin_x + p.col as i32 * cell_w;
                let y = origin_y + p.row * cell_h;
                if x as usize >= canvas.w || y as usize >= canvas.h {
                    continue;
                }
                self.blend_image(canvas, x, y, max_w, max_h, &p.image);
            }
        }
        // Scrollbar.
        if term.total_rows() > term.grid.rows {
            let track_y = TITLE_H as i32 + 4;
            let track_h = canvas.h.saturating_sub(TITLE_H + 10);
            canvas.rect(
                canvas.w as i32 - 4,
                track_y,
                2,
                track_h as i32,
                self.theme.line,
            );
            let frac = term.view_offset as f32 / term.history.len().max(1) as f32;
            let thumb_h = (track_h as f32 * term.grid.rows as f32 / term.total_rows() as f32)
                .max(18.0) as i32;
            let thumb_y = track_y + ((track_h as i32 - thumb_h) as f32 * (1.0 - frac)) as i32;
            canvas.rect(canvas.w as i32 - 5, thumb_y, 3, thumb_h, accent);
        }
        // Status footer.
        let fy = canvas.h as i32 - 28;
        canvas.rect(0, fy - 2, canvas.w as i32, 30, panel);
        canvas.rect(0, fy - 2, canvas.w as i32, 1, self.theme.line);
        self.draw_text(canvas, "GF-SHELL // TERMINAL", 12, fy + 15, gold, false);
        let hint = if term.view_offset > 0 {
            "SCROLLBACK"
        } else {
            "KITTY GRAPHICS READY"
        };
        let hint_w = self.text_width(hint) as i32;
        self.draw_text(
            canvas,
            hint,
            canvas.w as i32 - hint_w - 12,
            fy + 15,
            self.theme.text_faint,
            false,
        );
    }
}
