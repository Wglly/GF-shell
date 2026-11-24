use std::io::{Cursor, Write};

use base64::Engine;
use image::ImageFormat;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 || args[1] == "-h" || args[1] == "--help" {
        eprintln!("usage: gf-img FILE");
        eprintln!("Print a Kitty graphics sequence for gf-term (also works with Kitty).");
        std::process::exit(if args.len() < 2 { 1 } else { 0 });
    }
    let path = &args[1];
    let data = match std::fs::read(path) {
        Ok(d) => d,
        Err(e) => {
            eprintln!("gf-img: {e}");
            std::process::exit(1);
        }
    };
    let img = match image::load_from_memory(&data) {
        Ok(i) => i,
        Err(e) => {
            eprintln!("gf-img: unsupported image: {e}");
            std::process::exit(1);
        }
    };
    let rgba = img.to_rgba8();
    let mut png = Vec::new();
    if rgba
        .write_to(&mut Cursor::new(&mut png), ImageFormat::Png)
        .is_err()
    {
        eprintln!("gf-img: could not encode PNG");
        std::process::exit(1);
    }
    let b64 = base64::engine::general_purpose::STANDARD.encode(&png);
    let id = std::process::id()
        ^ (std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.subsec_nanos())
            .unwrap_or(0));
    let id = id.max(1);
    let chunk = 4096;
    let mut out = std::io::stdout().lock();
    let mut pos = 0;
    while pos < b64.len() {
        let end = (pos + chunk).min(b64.len());
        let more = if end < b64.len() { 1 } else { 0 };
        let header = if pos == 0 {
            format!("\x1b_Ga=T,f=100,i={},m={};", id, more)
        } else {
            format!("\x1b_Gi={},m={};", id, more)
        };
        if out.write_all(header.as_bytes()).is_err()
            || out.write_all(&b64.as_bytes()[pos..end]).is_err()
            || out.write_all(b"\x1b\\").is_err()
        {
            break;
        }
        pos = end;
    }
    let _ = out.write_all(b"\r\n");
    let _ = out.flush();
}
