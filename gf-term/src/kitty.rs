use std::collections::HashMap;
use std::sync::Arc;

use base64::Engine;
use image::{ImageBuffer, Rgba, RgbaImage};

/// Splits Kitty graphics APC sequences out of the PTY byte stream.
/// vte 0.15 has no APC dispatch, so GF-Term handles them before the parser.
#[derive(Default)]
pub struct ApcSplitter {
    in_apc: bool,
    pending_esc: bool,
    apc_esc: bool,
    apc: Vec<u8>,
}

impl ApcSplitter {
    pub fn feed(&mut self, data: &[u8], clean: &mut Vec<u8>, apcs: &mut Vec<Vec<u8>>) {
        for &b in data {
            if self.in_apc {
                if self.apc_esc {
                    if b == b'\\' {
                        self.in_apc = false;
                        self.apc_esc = false;
                        apcs.push(std::mem::take(&mut self.apc));
                    } else {
                        self.apc.push(0x1b);
                        self.apc.push(b);
                        self.apc_esc = false;
                    }
                } else if b == 0x1b {
                    self.apc_esc = true;
                } else {
                    self.apc.push(b);
                }
            } else if self.pending_esc {
                if b == b'_' {
                    self.in_apc = true;
                    self.apc.clear();
                    self.pending_esc = false;
                } else {
                    clean.push(0x1b);
                    clean.push(b);
                    self.pending_esc = false;
                }
            } else if b == 0x1b {
                self.pending_esc = true;
            } else {
                clean.push(b);
            }
        }
    }
}

#[derive(Default)]
pub struct KittyParser {
    pending: Vec<u8>,
    pending_id: Option<u32>,
    pending_format: u32,
    pending_width: Option<u32>,
    pending_height: Option<u32>,
    images: HashMap<u32, Arc<RgbaImage>>,
    next_id: u32,
}

fn parse_params(s: &str) -> Vec<(String, String)> {
    s.split(',')
        .filter_map(|kv| {
            let mut it = kv.splitn(2, '=');
            let k = it.next()?.trim().to_string();
            let v = it.next().unwrap_or("1").trim().to_string();
            if k.is_empty() {
                None
            } else {
                Some((k, v))
            }
        })
        .collect()
}

impl KittyParser {
    pub fn handle(&mut self, apc: &[u8], term: &mut crate::terminal::Terminal) {
        if apc.first() != Some(&b'G') {
            return;
        }
        let rest = &apc[1..];
        let (params_raw, data) = match rest.iter().position(|&b| b == b';') {
            Some(i) => (&rest[..i], &rest[i + 1..]),
            None => (rest, &[][..]),
        };
        let Ok(params_str) = std::str::from_utf8(params_raw) else {
            return;
        };
        let params = parse_params(params_str);
        let get = |name: &str| {
            params
                .iter()
                .find(|(k, _)| k == name)
                .map(|(_, v)| v.as_str())
        };
        let action = get("a").unwrap_or("T");
        let format = get("f").and_then(|v| v.parse::<u32>().ok()).unwrap_or(32);
        let mut id = get("i").and_then(|v| v.parse::<u32>().ok()).unwrap_or(0);
        let quiet = get("q").and_then(|v| v.parse::<u32>().ok()).unwrap_or(0);
        let more = get("m").and_then(|v| v.parse::<u32>().ok()).unwrap_or(0) == 1;
        let sw = get("s").and_then(|v| v.parse::<u32>().ok());
        let sh = get("v").and_then(|v| v.parse::<u32>().ok());
        let display = action == "T";
        let put = action == "p";
        let query = action == "q";
        if query {
            if quiet < 2 {
                term.push_response(format!("\x1b_Gi={id};OK\x1b\\").into_bytes());
            }
            return;
        }
        if id == 0 {
            self.next_id = self.next_id.wrapping_add(1).max(1);
            id = self.next_id;
        }
        if put {
            if let Some(img) = self.images.get(&id).cloned() {
                term.place_image(id, img);
            }
            return;
        }
        if self.pending_id != Some(id) {
            self.pending.clear();
            self.pending_id = Some(id);
            self.pending_format = format;
            self.pending_width = sw;
            self.pending_height = sh;
        }
        self.pending.extend_from_slice(data);
        if more {
            return;
        }
        let encoded = std::mem::take(&mut self.pending);
        self.pending_id = None;
        let Ok(bytes) = base64::engine::general_purpose::STANDARD.decode(encoded) else {
            return;
        };
        let img = match self.pending_format {
            100 => image::load_from_memory(&bytes).ok().map(|i| i.to_rgba8()),
            24 => {
                let (w, h) = (
                    self.pending_width.unwrap_or(0),
                    self.pending_height.unwrap_or(0),
                );
                if w == 0 || h == 0 || bytes.len() < (w * h * 3) as usize {
                    None
                } else {
                    let mut out = RgbaImage::new(w, h);
                    for y in 0..h {
                        for x in 0..w {
                            let i = ((y * w + x) * 3) as usize;
                            out.put_pixel(x, y, Rgba([bytes[i], bytes[i + 1], bytes[i + 2], 255]));
                        }
                    }
                    Some(out)
                }
            }
            32 => {
                let (w, h) = (
                    self.pending_width.unwrap_or(0),
                    self.pending_height.unwrap_or(0),
                );
                if w == 0 || h == 0 || bytes.len() < (w * h * 4) as usize {
                    None
                } else {
                    ImageBuffer::<Rgba<u8>, _>::from_raw(
                        w,
                        h,
                        bytes[..(w * h * 4) as usize].to_vec(),
                    )
                }
            }
            _ => None,
        };
        if let Some(img) = img {
            let arc = Arc::new(img);
            self.images.insert(id, arc.clone());
            if display {
                term.place_image(id, arc);
            }
            let _ = quiet;
        }
    }
}
