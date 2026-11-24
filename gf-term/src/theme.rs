use std::env;
use std::fs;
use std::path::PathBuf;

use serde_json::Value;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Rgb {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

impl Rgb {
    pub const fn new(r: u8, g: u8, b: u8) -> Self {
        Self { r, g, b }
    }

    pub fn from_hex(s: &str) -> Option<Self> {
        let s = s.trim().trim_start_matches('#');
        if s.len() < 6 {
            return None;
        }
        let r = u8::from_str_radix(&s[0..2], 16).ok()?;
        let g = u8::from_str_radix(&s[2..4], 16).ok()?;
        let b = u8::from_str_radix(&s[4..6], 16).ok()?;
        Some(Self::new(r, g, b))
    }

    pub fn mix(self, other: Self, t: f32) -> Self {
        let t = t.clamp(0.0, 1.0);
        let f = |a: u8, b: u8| (a as f32 + (b as f32 - a as f32) * t).round() as u8;
        Self::new(f(self.r, other.r), f(self.g, other.g), f(self.b, other.b))
    }

    pub fn lighten(self, t: f32) -> Self {
        self.mix(Self::new(255, 255, 255), t)
    }
    pub fn darken(self, t: f32) -> Self {
        self.mix(Self::new(0, 0, 0), t)
    }

    pub fn to_u32(self) -> u32 {
        ((self.r as u32) << 16) | ((self.g as u32) << 8) | self.b as u32
    }
}

#[derive(Clone)]
pub struct Theme {
    pub name: String,
    pub bg: Rgb,
    pub panel: Rgb,
    pub panel_alt: Rgb,
    pub line: Rgb,
    pub gold: Rgb,
    pub accent: Rgb,
    pub accent_hi: Rgb,
    pub accent2: Rgb,
    pub text: Rgb,
    pub text_dim: Rgb,
    pub text_faint: Rgb,
    pub ink: Rgb,
    pub font: String,
    pub ansi: [Rgb; 16],
}

fn get_str(v: &Value, path: &str, default: &str) -> String {
    let mut cur = v;
    for part in path.split('.') {
        match cur.get(part) {
            Some(x) => cur = x,
            None => return default.to_string(),
        }
    }
    cur.as_str().unwrap_or(default).to_string()
}

fn get_color(v: &Value, path: &str, default: Rgb) -> Rgb {
    Rgb::from_hex(&get_str(v, path, "")).unwrap_or(default)
}

fn config_path() -> PathBuf {
    if let Ok(p) = env::var("GF_TERM_CONFIG") {
        return PathBuf::from(p);
    }
    let base = env::var("XDG_CONFIG_HOME")
        .ok()
        .or_else(|| env::var("HOME").ok().map(|h| format!("{h}/.config")))
        .unwrap_or_else(|| ".".into());
    PathBuf::from(base).join("gf-shell/config.json")
}

pub const PRESET_KEYS: [&str; 5] = ["gfl", "arknights", "bf1", "bf4", "hoi4"];
pub const PRESET_LABELS: [&str; 5] = ["G&K", "ARKNIGHTS", "BATTLEFIELD 1", "BATTLEFIELD 4", "HEARTS OF IRON IV"];

fn state_path() -> PathBuf {
    if let Ok(p) = env::var("GF_TERM_STATE") {
        return PathBuf::from(p);
    }
    let base = env::var("XDG_CONFIG_HOME")
        .ok()
        .or_else(|| env::var("HOME").ok().map(|h| format!("{h}/.config")))
        .unwrap_or_else(|| ".".into());
    PathBuf::from(base).join("gf-term/config.json")
}

pub fn load_preferences() -> (Option<String>, f32) {
    let text = fs::read_to_string(state_path()).ok();
    let mut theme = None;
    let mut opacity = 1.0f32;
    if let Some(text) = text {
        if let Ok(v) = serde_json::from_str::<Value>(&text) {
            if let Some(t) = v.get("theme").and_then(|x| x.as_str()) { theme = Some(t.to_string()); }
            if let Some(o) = v.get("opacity").and_then(|x| x.as_f64()) { opacity = o.clamp(0.25, 1.0) as f32; }
        }
    }
    (theme, opacity)
}

pub fn save_preferences(theme: &str, opacity: f32) {
    let path = state_path();
    if let Some(dir) = path.parent() { let _ = fs::create_dir_all(dir); }
    let v = serde_json::json!({ "theme": theme, "opacity": opacity.clamp(0.25, 1.0) });
    if let Ok(s) = serde_json::to_string_pretty(&v) { let _ = fs::write(path, s + "\n"); }
}

impl Theme {
    pub fn preset(name: &str) -> Option<Self> {
        let mut t = Self::default();
        t.name = name.to_string();
        match name {
            "arknights" => {
                t.bg = Rgb::new(0x13, 0x17, 0x18); t.panel = Rgb::new(0x23, 0x2a, 0x2c);
                t.panel_alt = Rgb::new(0x2d, 0x35, 0x37); t.line = Rgb::new(0x3c, 0x47, 0x49);
                t.gold = Rgb::new(0xc8, 0xa2, 0x4c); t.accent = Rgb::new(0x58, 0xb9, 0xc2);
                t.accent_hi = Rgb::new(0x8b, 0xdd, 0xe1); t.accent2 = Rgb::new(0xd7, 0xd2, 0xc5);
                t.text = Rgb::new(0xee, 0xf3, 0xf2); t.text_dim = Rgb::new(0xb2, 0xbf, 0xbe);
                t.text_faint = Rgb::new(0x7b, 0x89, 0x88); t.ink = Rgb::new(0x0e, 0x15, 0x16);
            }
            "bf1" => {
                t.bg = Rgb::new(0x19, 0x16, 0x12); t.panel = Rgb::new(0x29, 0x25, 0x1e);
                t.panel_alt = Rgb::new(0x33, 0x2e, 0x26); t.line = Rgb::new(0x49, 0x42, 0x37);
                t.gold = Rgb::new(0xc8, 0xa2, 0x4c); t.accent = Rgb::new(0xc7, 0xa1, 0x5b);
                t.accent_hi = Rgb::new(0xe2, 0xc4, 0x8a); t.accent2 = Rgb::new(0x9b, 0x4a, 0x36);
                t.text = Rgb::new(0xf1, 0xea, 0xdc); t.text_dim = Rgb::new(0xc1, 0xb6, 0xa3);
                t.text_faint = Rgb::new(0x88, 0x7d, 0x6b); t.ink = Rgb::new(0x15, 0x11, 0x0c);
            }
            "bf4" => {
                t.bg = Rgb::new(0x11, 0x17, 0x1b); t.panel = Rgb::new(0x22, 0x2c, 0x33);
                t.panel_alt = Rgb::new(0x2c, 0x38, 0x40); t.line = Rgb::new(0x39, 0x4a, 0x52);
                t.gold = Rgb::new(0xc8, 0xa2, 0x4c); t.accent = Rgb::new(0x4a, 0x9d, 0xb5);
                t.accent_hi = Rgb::new(0x7c, 0xc3, 0xd7); t.accent2 = Rgb::new(0xd9, 0x87, 0x3f);
                t.text = Rgb::new(0xe8, 0xf0, 0xf3); t.text_dim = Rgb::new(0xa9, 0xb9, 0xc0);
                t.text_faint = Rgb::new(0x75, 0x86, 0x8d); t.ink = Rgb::new(0x0b, 0x12, 0x15);
            }
            "hoi4" => {
                t.bg = Rgb::new(0x17, 0x18, 0x10); t.panel = Rgb::new(0x27, 0x29, 0x1f);
                t.panel_alt = Rgb::new(0x31, 0x34, 0x28); t.line = Rgb::new(0x46, 0x4a, 0x3b);
                t.gold = Rgb::new(0xc8, 0xa2, 0x4c); t.accent = Rgb::new(0xc9, 0xa8, 0x4f);
                t.accent_hi = Rgb::new(0xe3, 0xce, 0x8a); t.accent2 = Rgb::new(0x87, 0x93, 0x6c);
                t.text = Rgb::new(0xee, 0xe9, 0xd8); t.text_dim = Rgb::new(0xb9, 0xb2, 0x9d);
                t.text_faint = Rgb::new(0x82, 0x7c, 0x6a); t.ink = Rgb::new(0x14, 0x15, 0x0e);
            }
            "gfl" => {}
            _ => return None,
        }
        t.build_ansi();
        Some(t)
    }

    pub fn load() -> Self {
        let mut theme = Self::default();
        let path = config_path();
        if let Ok(text) = fs::read_to_string(&path) {
            if let Ok(v) = serde_json::from_str::<Value>(&text) {
                theme.name = get_str(&v, "theme.preset", "gfl");
                theme.bg = get_color(&v, "theme.bg0", theme.bg);
                theme.panel = get_color(&v, "theme.panel", theme.panel);
                theme.panel_alt = get_color(&v, "theme.panelAlt", theme.panel_alt);
                theme.line = get_color(&v, "theme.line", theme.line);
                theme.gold = get_color(&v, "theme.lineBright", theme.gold);
                theme.accent = get_color(&v, "theme.accent", theme.accent);
                theme.accent_hi = get_color(&v, "theme.accentHi", theme.accent_hi);
                theme.accent2 = get_color(&v, "theme.accent2", theme.accent2);
                theme.text = get_color(&v, "theme.text", theme.text);
                theme.text_dim = get_color(&v, "theme.textDim", theme.text_dim);
                theme.text_faint = get_color(&v, "theme.textFaint", theme.text_faint);
                theme.ink = get_color(&v, "theme.ink", theme.ink);
                let f = get_str(&v, "fonts.mono", "");
                if !f.is_empty() {
                    theme.font = f;
                }
            }
        }
        let base_font = theme.font.clone();
        let gf_preset = theme.name.clone();
        let (saved, _) = load_preferences();
        let chosen = saved.or_else(|| {
            if PRESET_KEYS.contains(&gf_preset.as_str()) { Some(gf_preset) } else { None }
        }).unwrap_or_else(|| "gfl".into());
        if let Some(mut p) = Self::preset(&chosen) {
            p.font = base_font;
            theme = p;
        }
        theme.build_ansi();
        theme
    }

    pub fn default() -> Self {
        let mut t = Self {
            name: "gfl".into(),
            bg: Rgb::new(0x15, 0x15, 0x13),
            panel: Rgb::new(0x24, 0x24, 0x21),
            panel_alt: Rgb::new(0x2d, 0x2d, 0x29),
            line: Rgb::new(0x46, 0x44, 0x3c),
            gold: Rgb::new(0xc8, 0xa2, 0x4c),
            accent: Rgb::new(0xd8, 0xaa, 0x4b),
            accent_hi: Rgb::new(0xf0, 0xcf, 0x7a),
            accent2: Rgb::new(0x87, 0xa0, 0xb2),
            text: Rgb::new(0xf2, 0xef, 0xe6),
            text_dim: Rgb::new(0xbc, 0xb5, 0xa8),
            text_faint: Rgb::new(0x85, 0x7f, 0x73),
            ink: Rgb::new(0x18, 0x16, 0x11),
            font: "Share Tech Mono".into(),
            ansi: [Rgb::new(0, 0, 0); 16],
        };
        t.build_ansi();
        t
    }

    fn build_ansi(&mut self) {
        let red = Rgb::new(0xc6, 0x52, 0x3c);
        let green = Rgb::new(0x93, 0xa4, 0x7c);
        let yellow = self.accent;
        let blue = self.accent2;
        let magenta = Rgb::new(0xa8, 0x7b, 0x8c);
        let cyan = if self.name == "bf4" {
            self.accent2
        } else {
            Rgb::new(0x58, 0xb9, 0xc2)
        };
        let white = self.text;
        self.ansi = [
            self.panel,
            red,
            green,
            yellow,
            blue,
            magenta,
            cyan,
            white,
            self.text_faint,
            red.lighten(0.20),
            green.lighten(0.20),
            self.accent_hi,
            blue.lighten(0.20),
            magenta.lighten(0.20),
            cyan.lighten(0.18),
            Rgb::new(0xff, 0xff, 0xf5),
        ];
        self.ansi[0] = self.panel.darken(0.15);
    }

    pub fn color_256(&self, n: u8) -> Rgb {
        match n {
            0..=15 => self.ansi[n as usize],
            16..=231 => {
                let i = n - 16;
                let r = i / 36;
                let g = (i % 36) / 6;
                let b = i % 6;
                let conv = |v: u8| if v == 0 { 0 } else { 55 + v * 40 };
                Rgb::new(conv(r), conv(g), conv(b))
            }
            _ => {
                let v = 8 + (n - 232) * 10;
                Rgb::new(v, v, v)
            }
        }
    }
}
