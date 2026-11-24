use std::collections::VecDeque;
use std::sync::Arc;

use image::RgbaImage;
use unicode_width::UnicodeWidthChar;
use vte::{Params, Perform};

use crate::kitty::KittyParser;
use crate::theme::{Rgb, Theme};

pub const ATTR_BOLD: u8 = 1;
pub const ATTR_DIM: u8 = 2;
pub const ATTR_ITALIC: u8 = 4;
pub const ATTR_UNDERLINE: u8 = 8;
pub const ATTR_REVERSE: u8 = 16;
pub const ATTR_INVISIBLE: u8 = 32;
pub const ATTR_STRIKE: u8 = 64;

#[derive(Clone, Copy, Debug)]
pub enum ColorSpec {
    DefaultFg,
    DefaultBg,
    Indexed(u8),
    Rgb(Rgb),
}

#[derive(Clone, Copy, Debug)]
pub struct Cell {
    pub ch: char,
    pub fg: ColorSpec,
    pub bg: ColorSpec,
    pub attr: u8,
    pub wide: bool,
}

impl Cell {
    pub fn blank() -> Self {
        Self {
            ch: ' ',
            fg: ColorSpec::DefaultFg,
            bg: ColorSpec::DefaultBg,
            attr: 0,
            wide: false,
        }
    }
}

#[derive(Clone)]
pub struct Grid {
    pub cols: usize,
    pub rows: usize,
    pub cells: Vec<Cell>,
    pub cx: usize,
    pub cy: usize,
    pub saved: (usize, usize),
    pub scroll_top: usize,
    pub scroll_bottom: usize,
    pub fg: ColorSpec,
    pub bg: ColorSpec,
    pub attr: u8,
    pub autowrap: bool,
    pub cursor_visible: bool,
    pub insert: bool,
}

impl Grid {
    pub fn new(cols: usize, rows: usize) -> Self {
        Self {
            cols: cols.max(2),
            rows: rows.max(2),
            cells: vec![Cell::blank(); cols.max(2) * rows.max(2)],
            cx: 0,
            cy: 0,
            saved: (0, 0),
            scroll_top: 0,
            scroll_bottom: rows.max(2) - 1,
            fg: ColorSpec::DefaultFg,
            bg: ColorSpec::DefaultBg,
            attr: 0,
            autowrap: true,
            cursor_visible: true,
            insert: false,
        }
    }

    #[inline]
    pub fn idx(&self, x: usize, y: usize) -> usize {
        y * self.cols + x
    }

    pub fn cell(&self, x: usize, y: usize) -> Cell {
        if x < self.cols && y < self.rows {
            self.cells[self.idx(x, y)]
        } else {
            Cell::blank()
        }
    }

    pub fn cell_mut(&mut self, x: usize, y: usize) -> &mut Cell {
        let i = self.idx(x, y);
        &mut self.cells[i]
    }

    pub fn clear(&mut self) {
        self.cells.fill(Cell::blank());
        self.cx = 0;
        self.cy = 0;
    }
}

pub struct ImagePlacement {
    pub _id: u32,
    pub row: i32,
    pub col: usize,
    pub image: Arc<RgbaImage>,
}

pub struct Terminal {
    pub grid: Grid,
    pub history: VecDeque<Vec<Cell>>,
    pub history_limit: usize,
    pub view_offset: usize,
    pub images: Vec<ImagePlacement>,
    pub kitty: KittyParser,
    pub responses: Vec<Vec<u8>>,
    pub title: String,
    pub bell: bool,
    pub theme: Theme,
    pub cell_w: usize,
    pub cell_h: usize,
    alternate: Option<Grid>,
}

impl Terminal {
    pub fn new(cols: usize, rows: usize, theme: Theme, title: String) -> Self {
        Self {
            grid: Grid::new(cols, rows),
            history: VecDeque::new(),
            history_limit: 2000,
            view_offset: 0,
            images: Vec::new(),
            kitty: KittyParser::default(),
            responses: Vec::new(),
            title,
            bell: false,
            theme,
            cell_w: 8,
            cell_h: 18,
            alternate: None,
        }
    }

    pub fn push_response(&mut self, bytes: Vec<u8>) {
        self.responses.push(bytes);
    }

    pub fn take_responses(&mut self) -> Vec<Vec<u8>> {
        std::mem::take(&mut self.responses)
    }

    pub fn resize(&mut self, cols: usize, rows: usize) {
        let cols = cols.max(2);
        let rows = rows.max(2);
        if cols == self.grid.cols && rows == self.grid.rows {
            return;
        }
        let mut next = Grid::new(cols, rows);
        next.fg = self.grid.fg;
        next.bg = self.grid.bg;
        next.attr = self.grid.attr;
        next.autowrap = self.grid.autowrap;
        next.cursor_visible = self.grid.cursor_visible;
        let copy_rows = rows.min(self.grid.rows);
        let copy_cols = cols.min(self.grid.cols);
        for y in 0..copy_rows {
            for x in 0..copy_cols {
                let i = next.idx(x, y);
                next.cells[i] = self.grid.cells[self.grid.idx(x, y)];
            }
        }
        next.cx = self.grid.cx.min(cols - 1);
        next.cy = self.grid.cy.min(rows - 1);
        next.scroll_top = 0;
        next.scroll_bottom = rows - 1;
        self.grid = next;
        self.view_offset = 0;
    }

    pub fn scroll_view(&mut self, delta: i32) {
        let max = self.history.len();
        let next = (self.view_offset as i32 + delta).clamp(0, max as i32) as usize;
        self.view_offset = next;
    }

    pub fn total_rows(&self) -> usize {
        self.history.len() + self.grid.rows
    }

    pub fn visible_cell(&self, x: usize, y: usize) -> Cell {
        if self.view_offset == 0 {
            return self.grid.cell(x, y);
        }
        let total = self.total_rows();
        let start = total.saturating_sub(self.grid.rows + self.view_offset);
        let row = start + y;
        if row < self.history.len() {
            self.history
                .get(row)
                .and_then(|r| r.get(x))
                .copied()
                .unwrap_or_else(Cell::blank)
        } else {
            self.grid.cell(x, row - self.history.len())
        }
    }

    fn reset_cell_style(&self) -> Cell {
        Cell {
            ch: ' ',
            fg: self.grid.fg,
            bg: self.grid.bg,
            attr: self.grid.attr,
            wide: false,
        }
    }

    fn scroll_up(&mut self, n: usize) {
        let n = n.min(self.grid.rows);
        for _ in 0..n {
            let row: Vec<Cell> = self.grid.cells.drain(0..self.grid.cols).collect();
            self.history.push_back(row);
            while self.history.len() > self.history_limit {
                self.history.pop_front();
            }
            let blank = Cell::blank();
            self.grid
                .cells
                .extend(std::iter::repeat(blank).take(self.grid.cols));
        }
        self.images.retain_mut(|p| {
            p.row -= n as i32;
            if p.row < 0 {
                false
            } else {
                true
            }
        });
        self.view_offset = 0;
    }

    fn scroll_down(&mut self, n: usize) {
        let n = n.min(self.grid.rows);
        for _ in 0..n {
            let at = self.grid.cells.len() - self.grid.cols;
            self.grid.cells.drain(at..);
            let blank = Cell::blank();
            for _ in 0..self.grid.cols {
                self.grid.cells.insert(0, blank);
            }
        }
    }

    fn linefeed(&mut self) {
        self.view_offset = 0;
        if self.grid.cy == self.grid.scroll_bottom {
            self.scroll_up(1);
        } else if self.grid.cy + 1 < self.grid.rows {
            self.grid.cy += 1;
        }
    }

    fn put_char(&mut self, c: char) {
        self.view_offset = 0;
        let width = UnicodeWidthChar::width(c).unwrap_or(1);
        if width == 0 {
            return;
        }
        if self.grid.autowrap && self.grid.cx + width > self.grid.cols {
            self.grid.cx = 0;
            self.linefeed();
        }
        if self.grid.cx >= self.grid.cols {
            self.grid.cx = self.grid.cols - 1;
        }
        let fg = self.grid.fg;
        let bg = self.grid.bg;
        let attr = self.grid.attr;
        if self.grid.insert {
            let y = self.grid.cy;
            for x in (self.grid.cx..self.grid.cols - width).rev() {
                let v = self.grid.cell(x, y);
                *self.grid.cell_mut(x + width, y) = v;
            }
        }
        {
            let cell = self.grid.cell_mut(self.grid.cx, self.grid.cy);
            *cell = Cell {
                ch: c,
                fg,
                bg,
                attr,
                wide: width == 2,
            };
        }
        if width == 2 && self.grid.cx + 1 < self.grid.cols {
            *self.grid.cell_mut(self.grid.cx + 1, self.grid.cy) = Cell {
                ch: ' ',
                fg,
                bg,
                attr,
                wide: true,
            };
        }
        self.grid.cx += width;
        if self.grid.cx >= self.grid.cols {
            if self.grid.autowrap {
                self.grid.cx = 0;
                self.linefeed();
            } else {
                self.grid.cx = self.grid.cols - 1;
            }
        }
    }

    fn erase_display(&mut self, mode: u16) {
        let blank = self.reset_cell_style();
        match mode {
            0 => {
                let start = self.grid.idx(self.grid.cx, self.grid.cy);
                for c in &mut self.grid.cells[start..] {
                    *c = blank;
                }
            }
            1 => {
                let end = self.grid.idx(self.grid.cx, self.grid.cy) + 1;
                for c in &mut self.grid.cells[..end] {
                    *c = blank;
                }
            }
            2 | 3 => {
                for c in &mut self.grid.cells {
                    *c = blank;
                }
            }
            _ => {}
        }
        self.view_offset = 0;
    }

    fn erase_line(&mut self, mode: u16) {
        let y = self.grid.cy;
        let blank = self.reset_cell_style();
        let (a, b) = match mode {
            0 => (self.grid.cx, self.grid.cols),
            1 => (0, (self.grid.cx + 1).min(self.grid.cols)),
            2 => (0, self.grid.cols),
            _ => (0, 0),
        };
        for x in a..b {
            *self.grid.cell_mut(x, y) = blank;
        }
    }

    fn set_alt(&mut self, on: bool) {
        if on {
            if self.alternate.is_none() {
                let mut g = Grid::new(self.grid.cols, self.grid.rows);
                g.fg = self.grid.fg;
                g.bg = self.grid.bg;
                g.attr = self.grid.attr;
                self.alternate = Some(self.grid.clone());
                self.grid = g;
            }
        } else if let Some(mut g) = self.alternate.take() {
            if g.cols != self.grid.cols || g.rows != self.grid.rows {
                let mut n = Grid::new(self.grid.cols, self.grid.rows);
                let rows = n.rows.min(g.rows);
                let cols = n.cols.min(g.cols);
                for y in 0..rows {
                    for x in 0..cols {
                        let i = n.idx(x, y);
                        n.cells[i] = g.cells[g.idx(x, y)];
                    }
                }
                n.cx = g.cx.min(n.cols - 1);
                n.cy = g.cy.min(n.rows - 1);
                g = n;
            }
            self.grid = g;
            self.view_offset = 0;
        }
    }

    pub fn handle_kitty(&mut self, apc: &[u8]) {
        let mut kitty = std::mem::take(&mut self.kitty);
        kitty.handle(apc, self);
        self.kitty = kitty;
    }

    pub fn write_system_message(&mut self, msg: &str) {
        self.grid.attr = 0;
        self.grid.fg = ColorSpec::DefaultFg;
        self.grid.bg = ColorSpec::DefaultBg;
        for ch in msg.chars() {
            if ch == '\n' {
                self.linefeed();
            } else if ch == '\r' {
                self.grid.cx = 0;
            } else {
                self.put_char(ch);
            }
        }
    }

    pub fn set_cell_size(&mut self, width: usize, height: usize) {
        self.cell_w = width.max(1);
        self.cell_h = height.max(1);
    }

    pub fn place_image(&mut self, id: u32, image: Arc<RgbaImage>, advance: bool) {
        let row = self.grid.cy;
        let col = self.grid.cx;
        let rows = ((image.height() as usize + self.cell_h - 1) / self.cell_h).max(1);
        self.images.push(ImagePlacement {
            _id: id,
            row: row as i32,
            col,
            image,
        });
        if !advance {
            return;
        }
        // Reserve the image's cells: the next prompt/session output starts below
        // the image instead of being painted over it.
        let target = row.saturating_add(rows).min(self.grid.rows.saturating_sub(1));
        while self.grid.cy < target {
            self.linefeed();
        }
        self.grid.cx = 0;
        self.view_offset = 0;
    }

    fn set_fg_rgb(&mut self, c: Rgb) {
        self.grid.fg = ColorSpec::Rgb(c);
    }
    fn set_bg_rgb(&mut self, c: Rgb) {
        self.grid.bg = ColorSpec::Rgb(c);
    }

    fn sgr(&mut self, vals: &[u16]) {
        if vals.is_empty() {
            self.reset_attr();
            return;
        }
        let mut i = 0;
        while i < vals.len() {
            let n = vals[i];
            match n {
                0 => self.reset_attr(),
                1 => self.grid.attr |= ATTR_BOLD,
                2 => self.grid.attr |= ATTR_DIM,
                3 => self.grid.attr |= ATTR_ITALIC,
                4 => self.grid.attr |= ATTR_UNDERLINE,
                7 => self.grid.attr |= ATTR_REVERSE,
                8 => self.grid.attr |= ATTR_INVISIBLE,
                9 => self.grid.attr |= ATTR_STRIKE,
                21 | 22 => self.grid.attr &= !(ATTR_BOLD | ATTR_DIM),
                23 => self.grid.attr &= !ATTR_ITALIC,
                24 => self.grid.attr &= !ATTR_UNDERLINE,
                27 => self.grid.attr &= !ATTR_REVERSE,
                28 => self.grid.attr &= !ATTR_INVISIBLE,
                29 => self.grid.attr &= !ATTR_STRIKE,
                30..=37 => self.grid.fg = ColorSpec::Indexed((n - 30) as u8),
                39 => self.grid.fg = ColorSpec::DefaultFg,
                40..=47 => self.grid.bg = ColorSpec::Indexed((n - 40) as u8),
                49 => self.grid.bg = ColorSpec::DefaultBg,
                90..=97 => self.grid.fg = ColorSpec::Indexed((n - 90 + 8) as u8),
                100..=107 => self.grid.bg = ColorSpec::Indexed((n - 100 + 8) as u8),
                38 | 48 => {
                    if i + 1 < vals.len() && vals[i + 1] == 5 && i + 2 < vals.len() {
                        let idx = vals[i + 2] as u8;
                        if n == 38 {
                            self.grid.fg = ColorSpec::Indexed(idx);
                        } else {
                            self.grid.bg = ColorSpec::Indexed(idx);
                        }
                        i += 2;
                    } else if i + 1 < vals.len() && vals[i + 1] == 2 && i + 4 < vals.len() {
                        let c = Rgb::new(vals[i + 2] as u8, vals[i + 3] as u8, vals[i + 4] as u8);
                        if n == 38 {
                            self.set_fg_rgb(c);
                        } else {
                            self.set_bg_rgb(c);
                        }
                        i += 4;
                    }
                }
                _ => {}
            }
            i += 1;
        }
    }

    fn reset_attr(&mut self) {
        self.grid.fg = ColorSpec::DefaultFg;
        self.grid.bg = ColorSpec::DefaultBg;
        self.grid.attr = 0;
    }
}

pub fn flatten_params(params: &Params) -> Vec<u16> {
    let mut out = Vec::new();
    for group in params.iter() {
        for v in group {
            out.push(*v);
        }
    }
    out
}

pub struct Performer<'a> {
    pub term: &'a mut Terminal,
}

impl<'a> Perform for Performer<'a> {
    fn print(&mut self, c: char) {
        self.term.put_char(c);
    }

    fn execute(&mut self, byte: u8) {
        match byte {
            0x07 => self.term.bell = true,
            0x08 => {
                if self.term.grid.cx > 0 {
                    self.term.grid.cx -= 1;
                }
            }
            0x09 => {
                let next = (self.term.grid.cx / 8 + 1) * 8;
                self.term.grid.cx = next.min(self.term.grid.cols - 1);
            }
            0x0a | 0x0b | 0x0c => self.term.linefeed(),
            0x0d => self.term.grid.cx = 0,
            _ => {}
        }
    }

    fn csi_dispatch(&mut self, params: &Params, intermediates: &[u8], _ignore: bool, action: char) {
        let vals = flatten_params(params);
        let get = |i: usize, default: u16| vals.get(i).copied().unwrap_or(default).max(1) as usize;
        let private = intermediates.contains(&b'?');
        match action {
            'A' => self.term.grid.cy = self.term.grid.cy.saturating_sub(get(0, 1)),
            'B' => self.term.grid.cy = (self.term.grid.cy + get(0, 1)).min(self.term.grid.rows - 1),
            'C' => self.term.grid.cx = (self.term.grid.cx + get(0, 1)).min(self.term.grid.cols - 1),
            'D' => self.term.grid.cx = self.term.grid.cx.saturating_sub(get(0, 1)),
            'E' => {
                self.term.grid.cy = (self.term.grid.cy + get(0, 1)).min(self.term.grid.rows - 1);
                self.term.grid.cx = 0;
            }
            'F' => {
                self.term.grid.cy = self.term.grid.cy.saturating_sub(get(0, 1));
                self.term.grid.cx = 0;
            }
            'G' => self.term.grid.cx = (get(0, 1) - 1).min(self.term.grid.cols - 1),
            'd' => self.term.grid.cy = (get(0, 1) - 1).min(self.term.grid.rows - 1),
            'H' | 'f' => {
                self.term.grid.cy = (get(0, 1) - 1).min(self.term.grid.rows - 1);
                self.term.grid.cx = (get(1, 1) - 1).min(self.term.grid.cols - 1);
            }
            'J' => self.term.erase_display(vals.get(0).copied().unwrap_or(0)),
            'K' => self.term.erase_line(vals.get(0).copied().unwrap_or(0)),
            'm' => self.term.sgr(&vals),
            'r' => {
                let top = get(0, 1) - 1;
                let bottom = get(1, self.term.grid.rows as u16) - 1;
                if top < bottom && bottom < self.term.grid.rows {
                    self.term.grid.scroll_top = top;
                    self.term.grid.scroll_bottom = bottom;
                    self.term.grid.cy = 0;
                    self.term.grid.cx = 0;
                }
            }
            's' => self.term.grid.saved = (self.term.grid.cx, self.term.grid.cy),
            'u' => {
                self.term.grid.cx = self.term.grid.saved.0.min(self.term.grid.cols - 1);
                self.term.grid.cy = self.term.grid.saved.1.min(self.term.grid.rows - 1);
            }
            'L' => {
                let n = get(0, 1).min(self.term.grid.rows - self.term.grid.cy);
                for _ in 0..n {
                    let at = self.term.grid.idx(0, self.term.grid.cy);
                    let end = at + self.term.grid.cols;
                    self.term.grid.cells.drain(at..end);
                    let blank = Cell::blank();
                    for _ in 0..self.term.grid.cols {
                        self.term.grid.cells.insert(at, blank);
                    }
                }
            }
            'M' => {
                let n = get(0, 1).min(self.term.grid.rows - self.term.grid.cy);
                for _ in 0..n {
                    let at = self.term.grid.idx(0, self.term.grid.cy);
                    let end = at + self.term.grid.cols;
                    self.term.grid.cells.drain(at..end);
                    let blank = Cell::blank();
                    for _ in 0..self.term.grid.cols {
                        self.term.grid.cells.push(blank);
                    }
                }
            }
            'P' => {
                let n = get(0, 1).min(self.term.grid.cols - self.term.grid.cx);
                let y = self.term.grid.cy;
                for _ in 0..n {
                    let at = self.term.grid.idx(self.term.grid.cx, y);
                    self.term.grid.cells.remove(at);
                    self.term.grid.cells.insert(
                        self.term.grid.idx(self.term.grid.cols - 1, y),
                        Cell::blank(),
                    );
                }
            }
            '@' => {
                let n = get(0, 1).min(self.term.grid.cols - self.term.grid.cx);
                let y = self.term.grid.cy;
                let at = self.term.grid.idx(self.term.grid.cx, y);
                for _ in 0..n {
                    self.term.grid.cells.insert(at, Cell::blank());
                }
                self.term
                    .grid
                    .cells
                    .truncate(self.term.grid.cols * self.term.grid.rows);
            }
            'X' => {
                let n = get(0, 1).min(self.term.grid.cols - self.term.grid.cx);
                let blank = Cell::blank();
                for x in self.term.grid.cx..self.term.grid.cx + n {
                    *self.term.grid.cell_mut(x, self.term.grid.cy) = blank;
                }
            }
            'S' => self.term.scroll_up(get(0, 1)),
            'T' => self.term.scroll_down(get(0, 1)),
            'h' | 'l' => {
                let on = action == 'h';
                if private {
                    for &v in &vals {
                        match v {
                            25 => self.term.grid.cursor_visible = on,
                            7 => self.term.grid.autowrap = on,
                            1049 | 47 | 1047 => self.term.set_alt(on),
                            4 => self.term.grid.insert = on,
                            _ => {}
                        }
                    }
                } else if vals.contains(&4) {
                    self.term.grid.insert = on;
                }
            }
            'n' => {
                if vals.get(0) == Some(&6) {
                    let r = self.term.grid.cy + 1;
                    let c = self.term.grid.cx + 1;
                    self.term
                        .push_response(format!("\x1b[{};{}R", r, c).into_bytes());
                } else if vals.get(0) == Some(&5) {
                    self.term.push_response(b"\x1b[0n".to_vec());
                }
            }
            'c' => self.term.push_response(b"\x1b[?62;22c".to_vec()),
            _ => {}
        }
    }

    fn esc_dispatch(&mut self, _intermediates: &[u8], _ignore: bool, byte: u8) {
        match byte {
            b'7' => self.term.grid.saved = (self.term.grid.cx, self.term.grid.cy),
            b'8' => {
                self.term.grid.cx = self.term.grid.saved.0.min(self.term.grid.cols - 1);
                self.term.grid.cy = self.term.grid.saved.1.min(self.term.grid.rows - 1);
            }
            b'D' => self.term.linefeed(),
            b'E' => {
                self.term.grid.cx = 0;
                self.term.linefeed();
            }
            b'M' => {
                if self.term.grid.cy == self.term.grid.scroll_top {
                    self.term.scroll_down(1);
                } else {
                    self.term.grid.cy = self.term.grid.cy.saturating_sub(1);
                }
            }
            b'c' => {
                self.term.grid.clear();
                self.term.reset_attr();
                self.term.grid.scroll_top = 0;
                self.term.grid.scroll_bottom = self.term.grid.rows - 1;
            }
            _ => {}
        }
    }

    fn osc_dispatch(&mut self, params: &[&[u8]], _bell: bool) {
        if params.len() >= 2 && (params[0] == b"0" || params[0] == b"2") {
            if let Ok(s) = std::str::from_utf8(params[1]) {
                self.term.title = s.to_string();
            }
        }
    }
}
