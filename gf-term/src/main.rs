mod gl;
mod kitty;
mod pty;
mod render;
mod terminal;
mod theme;

use std::rc::Rc;
use std::time::{Duration, Instant};

use anyhow::Result;
use winit::application::ApplicationHandler;
use winit::dpi::{LogicalSize, PhysicalSize};
use winit::event::{ElementState, MouseButton, MouseScrollDelta, WindowEvent};
use winit::event_loop::{ActiveEventLoop, ControlFlow, EventLoop};
use winit::keyboard::{Key, ModifiersState, NamedKey};
use winit::window::{Window, WindowId};

use gl::GlState;
use kitty::ApcSplitter;
use pty::PtySession;
use render::{Canvas, Renderer};
use terminal::{Performer, Terminal};
use theme::Theme;

struct App {
    theme: Theme,
    renderer: Renderer,
    parser: vte::Parser,
    splitter: ApcSplitter,
    pending: Vec<u8>,
    term: Option<Terminal>,
    pty: Option<PtySession>,
    window: Option<Rc<Window>>,
    gl: Option<GlState>,
    size: PhysicalSize<u32>,
    mods: ModifiersState,
    close_hover: bool,
    settings_hover: bool,
    hover_theme: Option<usize>,
    settings_open: bool,
    dragging_opacity: bool,
    opacity: f32,
    cursor: (f64, f64),
    dirty: bool,
    font_size: f32,
}

impl App {
    fn new(font_size: f32) -> Self {
        let theme = Theme::load();
        let renderer = Renderer::new(theme.clone(), font_size);
        let (_, opacity) = theme::load_preferences();
        Self {
            theme,
            renderer,
            parser: vte::Parser::new(),
            splitter: ApcSplitter::default(),
            pending: Vec::new(),
            term: None,
            pty: None,
            window: None,
            gl: None,
            size: PhysicalSize::new(1100, 720),
            mods: ModifiersState::empty(),
            close_hover: false,
            settings_hover: false,
            hover_theme: None,
            settings_open: false,
            dragging_opacity: false,
            opacity,
            cursor: (0.0, 0.0),
            dirty: true,
            font_size,
        }
    }

    fn create_session(&mut self, width: usize, height: usize) {
        let (cols, rows) = self.renderer.cols_rows(width, height);
        let mut term = Terminal::new(cols, rows, self.theme.clone(), "shell".into());
        term.theme = self.theme.clone();
        term.set_cell_size(self.renderer.cell_w, self.renderer.cell_h);
        self.term = Some(term);
        match PtySession::spawn(cols, rows) {
            Ok(p) => self.pty = Some(p),
            Err(e) => {
                if let Some(t) = self.term.as_mut() {
                    t.write_system_message(&format!("gf-term: failed to start shell: {e}\r\n"));
                }
            }
        }
    }

    fn resize_all(&mut self) {
        let (cols, rows) = self
            .renderer
            .cols_rows(self.size.width as usize, self.size.height as usize);
        if let Some(t) = self.term.as_mut() {
            t.set_cell_size(self.renderer.cell_w, self.renderer.cell_h);
            t.resize(cols, rows);
        }
        if let Some(p) = self.pty.as_mut() {
            p.resize(cols, rows);
        }
        self.dirty = true;
    }

    fn reload_theme(&mut self) {
        self.theme = Theme::load();
        self.renderer = Renderer::new(self.theme.clone(), self.font_size);
        if let Some(t) = self.term.as_mut() {
            t.theme = self.theme.clone();
        }
        self.resize_all();
        if let Some(w) = self.window.as_ref() {
            w.request_redraw();
        }
    }

    fn set_theme(&mut self, key: &str) {
        if let Some(mut t) = Theme::preset(key) {
            t.font = self.theme.font.clone();
            self.theme = t.clone();
            self.renderer.theme = t.clone();
            if let Some(term) = self.term.as_mut() {
                term.theme = t;
            }
            theme::save_preferences(&self.theme.name, self.opacity);
            self.dirty = true;
            if let Some(w) = self.window.as_ref() {
                w.request_redraw();
            }
        }
    }

    fn set_opacity(&mut self, value: f32) {
        self.opacity = value.clamp(0.25, 1.0);
        theme::save_preferences(&self.theme.name, self.opacity);
        self.dirty = true;
        if let Some(w) = self.window.as_ref() {
            w.request_redraw();
        }
    }

    fn feed(&mut self, bytes: &[u8]) {
        let mut clean = Vec::with_capacity(bytes.len());
        let mut apcs = Vec::new();
        self.splitter.feed(bytes, &mut clean, &mut apcs);
        if !clean.is_empty() {
            if let Some(term) = self.term.as_mut() {
                let mut perf = Performer { term };
                self.parser.advance(&mut perf, &clean);
            }
        }
        for apc in apcs {
            if let Some(term) = self.term.as_mut() {
                term.handle_kitty(&apc);
            }
        }
        if let Some(term) = self.term.as_mut() {
            let responses = term.take_responses();
            if let Some(p) = self.pty.as_mut() {
                for r in responses {
                    let _ = p.write(&r);
                }
            }
        }
        self.dirty = true;
    }

    fn send_key(&mut self, event: &winit::event::KeyEvent) {
        if event.logical_key == Key::Named(NamedKey::F2) {
            self.settings_open = !self.settings_open;
            self.hover_theme = None;
            self.dirty = true;
            if let Some(w) = self.window.as_ref() { w.request_redraw(); }
            return;
        }
        if self.settings_open && event.logical_key == Key::Named(NamedKey::Escape) {
            self.settings_open = false;
            self.hover_theme = None;
            self.dirty = true;
            return;
        }
        if self.settings_open {
            if let Some(text) = event.text.as_ref() {
                if let Some(ch) = text.chars().next() {
                    if ('1'..='5').contains(&ch) {
                        let key = theme::PRESET_KEYS[ch as usize - '1' as usize];
                        self.set_theme(key);
                        return;
                    }
                    if ch == '[' { self.set_opacity(self.opacity - 0.05); return; }
                    if ch == ']' { self.set_opacity(self.opacity + 0.05); return; }
                }
            }
        }
        let Some(text) = event.text.as_ref() else {
            self.send_named(event);
            return;
        };
        if self.mods.control_key() {
            if let Some(ch) = text.chars().next() {
                if self.mods.shift_key() && ch.eq_ignore_ascii_case(&'r') {
                    self.reload_theme();
                    return;
                }
                if self.mods.shift_key() && ch.eq_ignore_ascii_case(&'q') {
                    return;
                }
                let c = ch.to_ascii_lowercase();
                if c.is_ascii_alphabetic() {
                    let b = [c as u8 - b'a' + 1];
                    if let Some(p) = self.pty.as_mut() {
                        let _ = p.write(&b);
                    }
                    return;
                }
            }
        }
        let mut bytes = Vec::new();
        if self.mods.alt_key() {
            bytes.push(0x1b);
        }
        bytes.extend_from_slice(text.as_bytes());
        if let Some(p) = self.pty.as_mut() {
            let _ = p.write(&bytes);
        }
    }

    fn send_named(&mut self, event: &winit::event::KeyEvent) {
        let seq: &[u8] = match &event.logical_key {
            Key::Named(NamedKey::Enter) => b"\r",
            Key::Named(NamedKey::Tab) => {
                if self.mods.shift_key() {
                    b"\x1b[Z"
                } else {
                    b"\t"
                }
            }
            Key::Named(NamedKey::Backspace) => b"\x7f",
            Key::Named(NamedKey::Escape) => b"\x1b",
            Key::Named(NamedKey::ArrowUp) => b"\x1b[A",
            Key::Named(NamedKey::ArrowDown) => b"\x1b[B",
            Key::Named(NamedKey::ArrowRight) => b"\x1b[C",
            Key::Named(NamedKey::ArrowLeft) => b"\x1b[D",
            Key::Named(NamedKey::Home) => b"\x1b[H",
            Key::Named(NamedKey::End) => b"\x1b[F",
            Key::Named(NamedKey::Insert) => b"\x1b[2~",
            Key::Named(NamedKey::Delete) => b"\x1b[3~",
            Key::Named(NamedKey::PageUp) => b"\x1b[5~",
            Key::Named(NamedKey::PageDown) => b"\x1b[6~",
            Key::Named(NamedKey::F1) => b"\x1bOP",
            Key::Named(NamedKey::F2) => b"\x1bOQ",
            Key::Named(NamedKey::F3) => b"\x1bOR",
            Key::Named(NamedKey::F4) => b"\x1bOS",
            Key::Named(NamedKey::F5) => b"\x1b[15~",
            Key::Named(NamedKey::F6) => b"\x1b[17~",
            Key::Named(NamedKey::F7) => b"\x1b[18~",
            Key::Named(NamedKey::F8) => b"\x1b[19~",
            Key::Named(NamedKey::F9) => b"\x1b[20~",
            Key::Named(NamedKey::F10) => b"\x1b[21~",
            Key::Named(NamedKey::F11) => b"\x1b[23~",
            Key::Named(NamedKey::F12) => b"\x1b[24~",
            _ => b"",
        };
        if !seq.is_empty() {
            if let Some(p) = self.pty.as_mut() {
                let _ = p.write(seq);
            }
        }
    }
}

impl ApplicationHandler for App {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        if self.window.is_some() {
            return;
        }
        let attrs = Window::default_attributes()
            .with_title("GF TERMINAL")
            .with_inner_size(LogicalSize::new(1100.0, 720.0))
            .with_min_inner_size(LogicalSize::new(620.0, 380.0))
            .with_decorations(false)
            .with_transparent(true)
            .with_resizable(true);
        let created = match GlState::create(event_loop, attrs, self.opacity) {
            Ok(c) => c,
            Err(e) => {
                eprintln!("gf-term: {e}");
                event_loop.exit();
                return;
            }
        };
        let window = Rc::new(created.window);
        window.set_ime_allowed(true);
        self.size = window.inner_size();
        self.gl = Some(created.gl);
        self.window = Some(window.clone());
        self.create_session(self.size.width as usize, self.size.height as usize);
        window.request_redraw();
    }

    fn window_event(&mut self, event_loop: &ActiveEventLoop, _id: WindowId, event: WindowEvent) {
        match event {
            WindowEvent::CloseRequested => event_loop.exit(),
            WindowEvent::Resized(size) => {
                self.size = size;
                if let Some(w) = self.window.as_ref() {
                    if let Some(gl) = self.gl.as_mut() {
                        gl.resize(w);
                    }
                }
                self.resize_all();
                if let Some(w) = self.window.as_ref() {
                    w.request_redraw();
                }
            }
            WindowEvent::ScaleFactorChanged { .. } => {
                if let Some(w) = self.window.as_ref() {
                    self.size = w.inner_size();
                    if let Some(gl) = self.gl.as_mut() {
                        gl.resize(w);
                    }
                }
                self.resize_all();
                if let Some(w) = self.window.as_ref() {
                    w.request_redraw();
                }
            }
            WindowEvent::ModifiersChanged(m) => self.mods = m.state(),
            WindowEvent::KeyboardInput { event, .. } => {
                if event.state == ElementState::Pressed {
                    self.send_key(&event);
                }
            }
            WindowEvent::CursorMoved { position, .. } => {
                self.cursor = (position.x, position.y);
                let old = (self.settings_hover, self.hover_theme);
                self.settings_hover = render::settings_button_hit(position.x, position.y);
                self.hover_theme = if self.settings_open {
                    render::panel_theme_at(position.x, position.y)
                } else {
                    None
                };
                let width = self.window.as_ref().map(|w| w.inner_size().width).unwrap_or(0);
                let close = position.x > (width as f64 - 38.0)
                    && position.x < (width as f64 - 8.0)
                    && position.y < 32.0;
                self.close_hover = close;
                if self.dragging_opacity && self.settings_open {
                    if let Some(v) = render::panel_opacity_at(position.x, position.y) {
                        self.set_opacity(v);
                    }
                }
                if old != (self.settings_hover, self.hover_theme) || close {
                    if let Some(w) = self.window.as_ref() {
                        w.request_redraw();
                    }
                }
            }
            WindowEvent::MouseInput { state, button, .. } => {
                if button != MouseButton::Left {
                    return;
                }
                if state == ElementState::Released {
                    self.dragging_opacity = false;
                    return;
                }
                if state != ElementState::Pressed {
                    return;
                }
                let (x, y) = self.cursor;
                if render::settings_button_hit(x, y) {
                    self.settings_open = !self.settings_open;
                    self.dirty = true;
                    if let Some(w) = self.window.as_ref() {
                        w.request_redraw();
                    }
                    return;
                }
                if self.settings_open {
                    if let Some(i) = render::panel_theme_at(x, y) {
                        let key = theme::PRESET_KEYS[i];
                        self.set_theme(key);
                        return;
                    }
                    if let Some(v) = render::panel_opacity_at(x, y) {
                        self.dragging_opacity = true;
                        self.set_opacity(v);
                        return;
                    }
                    if render::panel_contains(x, y) {
                        return;
                    }
                    self.settings_open = false;
                }
                if let Some(w) = self.window.as_ref() {
                    let ww = w.inner_size().width as f64;
                    if self.close_hover {
                        event_loop.exit();
                    } else if y < 34.0 {
                        if x > ww - 72.0 && x < ww - 42.0 {
                            w.set_minimized(true);
                        } else {
                            let _ = w.drag_window();
                        }
                    }
                }
            }
            WindowEvent::MouseWheel { delta, .. } => {
                let d = match delta {
                    MouseScrollDelta::LineDelta(_, y) => y as i32 * 3,
                    MouseScrollDelta::PixelDelta(p) => (p.y / 20.0) as i32,
                };
                if let Some(t) = self.term.as_mut() {
                    t.scroll_view(d);
                }
                self.dirty = true;
                if let Some(w) = self.window.as_ref() {
                    w.request_redraw();
                }
            }
            WindowEvent::RedrawRequested => self.draw(),
            _ => {}
        }
    }

    fn about_to_wait(&mut self, event_loop: &ActiveEventLoop) {
        if let Some(p) = self.pty.as_mut() {
            let chunks = p.transfer();
            for c in chunks {
                if c.is_empty() {
                    break;
                }
                self.pending.extend_from_slice(&c);
            }
        }
        // Process output in bounded slices. A huge paste/image does not starve
        // the renderer; the next prompt is parsed only after the output queued
        // before it, so windows/prompts cannot be painted into half-drawn text.
        if !self.pending.is_empty() {
            let take = self.pending.len().min(256 * 1024);
            let chunk: Vec<u8> = self.pending.drain(..take).collect();
            self.feed(&chunk);
        }
        if self.dirty {
            self.dirty = false;
            if let Some(w) = self.window.as_ref() {
                w.request_redraw();
            }
        }
        let delay = if self.pending.is_empty() { 16 } else { 2 };
        event_loop.set_control_flow(ControlFlow::WaitUntil(
            Instant::now() + Duration::from_millis(delay),
        ));
    }
}

impl App {
    fn draw(&mut self) {
        let Some(window) = self.window.as_ref().cloned() else {
            return;
        };
        let Some(term) = self.term.as_ref() else {
            return;
        };
        let size = window.inner_size();
        if size.width == 0 || size.height == 0 {
            return;
        }
        let w = size.width as usize;
        let h = size.height as usize;
        let mut pixels = vec![0u32; w * h];
        {
            let mut canvas = Canvas {
                buf: &mut pixels,
                w,
                h,
            };
            self.renderer.draw(
                &mut canvas,
                term,
                &term.title,
                self.close_hover,
                &self.theme.name,
                self.settings_open,
                self.opacity,
                self.settings_hover,
                self.hover_theme,
            );
        }
        if let Some(gl) = self.gl.as_mut() {
            gl.draw(&pixels, w, h, self.opacity);
        }
        let title = if term.title.trim().is_empty() {
            "GF TERMINAL".to_string()
        } else {
            format!("GF TERMINAL — {}", term.title)
        };
        window.set_title(&title);
    }
}

fn main() -> Result<()> {
    let mut font_size = 15.0f32;
    let args: Vec<String> = std::env::args().skip(1).collect();
    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--font-size" if i + 1 < args.len() => {
                font_size = args[i + 1].parse().unwrap_or(15.0);
                i += 2;
            }
            "--help" | "-h" => {
                println!("GF TERMINAL — GF-shell themed terminal with Kitty graphics");
                println!("usage: gf-term [--font-size N]");
                println!("  CFG (top-left)  terminal theme and opacity");
                println!("  Ctrl+Shift+R    reload GF-shell theme");
                println!("  gf-img FILE     display an image inside the terminal");
                return Ok(());
            }
            "--version" | "-V" => {
                println!("gf-term {}", env!("CARGO_PKG_VERSION"));
                return Ok(());
            }
            _ => {
                i += 1;
            }
        }
    }
    let event_loop = EventLoop::new()?;
    event_loop.set_control_flow(ControlFlow::Wait);
    let mut app = App::new(font_size);
    event_loop.run_app(&mut app)?;
    Ok(())
}
