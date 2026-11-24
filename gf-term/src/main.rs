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
use winit::event_loop::{ActiveEventLoop, ControlFlow, EventLoop, OwnedDisplayHandle};
use winit::keyboard::{Key, ModifiersState, NamedKey};
use winit::window::{Window, WindowId};

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
    term: Option<Terminal>,
    pty: Option<PtySession>,
    window: Option<Rc<Window>>,
    surface: Option<softbuffer::Surface<OwnedDisplayHandle, Rc<Window>>>,
    context: Option<softbuffer::Context<OwnedDisplayHandle>>,
    size: PhysicalSize<u32>,
    mods: ModifiersState,
    close_hover: bool,
    cursor: (f64, f64),
    dirty: bool,
    font_size: f32,
}

impl App {
    fn new(font_size: f32) -> Self {
        let theme = Theme::load();
        let renderer = Renderer::new(theme.clone(), font_size);
        Self {
            theme,
            renderer,
            parser: vte::Parser::new(),
            splitter: ApcSplitter::default(),
            term: None,
            pty: None,
            window: None,
            surface: None,
            context: None,
            size: PhysicalSize::new(1100, 720),
            mods: ModifiersState::empty(),
            close_hover: false,
            cursor: (0.0, 0.0),
            dirty: true,
            font_size,
        }
    }

    fn create_session(&mut self, width: usize, height: usize) {
        let (cols, rows) = self.renderer.cols_rows(width, height);
        let mut term = Terminal::new(cols, rows, self.theme.clone(), "shell".into());
        term.theme = self.theme.clone();
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
                    if let Some(w) = self.window.as_ref() {
                        w.request_redraw();
                    }
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
            .with_min_inner_size(LogicalSize::new(560.0, 340.0))
            .with_decorations(false)
            .with_resizable(true);
        let window = match event_loop.create_window(attrs) {
            Ok(w) => Rc::new(w),
            Err(_) => {
                event_loop.exit();
                return;
            }
        };
        window.set_ime_allowed(true);
        let context = match softbuffer::Context::new(event_loop.owned_display_handle()) {
            Ok(c) => c,
            Err(_) => {
                event_loop.exit();
                return;
            }
        };
        let surface = match softbuffer::Surface::new(&context, window.clone()) {
            Ok(s) => s,
            Err(_) => {
                event_loop.exit();
                return;
            }
        };
        self.size = window.inner_size();
        self.context = Some(context);
        self.surface = Some(surface);
        self.window = Some(window.clone());
        self.create_session(self.size.width as usize, self.size.height as usize);
        window.request_redraw();
    }

    fn window_event(&mut self, event_loop: &ActiveEventLoop, _id: WindowId, event: WindowEvent) {
        match event {
            WindowEvent::CloseRequested => event_loop.exit(),
            WindowEvent::Resized(size) => {
                self.size = size;
                if let (Some(surface), Some(w)) = (self.surface.as_mut(), self.window.as_ref()) {
                    let _ = surface.resize(
                        w.inner_size().width.max(1).try_into().unwrap(),
                        w.inner_size().height.max(1).try_into().unwrap(),
                    );
                }
                self.resize_all();
                if let Some(w) = self.window.as_ref() {
                    w.request_redraw();
                }
            }
            WindowEvent::ScaleFactorChanged { .. } => {
                if let Some(w) = self.window.as_ref() {
                    self.size = w.inner_size();
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
                let w = self
                    .window
                    .as_ref()
                    .map(|w| w.inner_size().width)
                    .unwrap_or(0);
                let hover = position.x > (w as f64 - 38.0)
                    && position.x < (w as f64 - 8.0)
                    && position.y < 32.0;
                if hover != self.close_hover {
                    self.close_hover = hover;
                    if let Some(w) = self.window.as_ref() {
                        w.request_redraw();
                    }
                }
            }
            WindowEvent::MouseInput { state, button, .. } => {
                if state == ElementState::Pressed && button == MouseButton::Left {
                    if let Some(w) = self.window.as_ref() {
                        let ww = w.inner_size().width as f64;
                        if self.close_hover {
                            event_loop.exit();
                        } else if self.cursor.1 < 34.0 {
                            if self.cursor.0 > ww - 72.0 && self.cursor.0 < ww - 42.0 {
                                w.set_minimized(true);
                            } else {
                                let _ = w.drag_window();
                            }
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
            WindowEvent::RedrawRequested => {
                self.draw();
            }
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
                self.feed(&c);
            }
        }
        if self.dirty {
            self.dirty = false;
            if let Some(w) = self.window.as_ref() {
                w.request_redraw();
            }
        }
        event_loop.set_control_flow(ControlFlow::WaitUntil(
            Instant::now() + Duration::from_millis(16),
        ));
    }
}

impl App {
    fn draw(&mut self) {
        let Some(window) = self.window.as_ref().cloned() else {
            return;
        };
        let Some(surface) = self.surface.as_mut() else {
            return;
        };
        let Some(term) = self.term.as_ref() else {
            return;
        };
        let size = window.inner_size();
        if size.width == 0 || size.height == 0 {
            return;
        }
        let _ = surface.resize(
            size.width.max(1).try_into().unwrap(),
            size.height.max(1).try_into().unwrap(),
        );
        let Ok(mut buffer) = surface.buffer_mut() else {
            return;
        };
        let mut canvas = Canvas {
            buf: &mut buffer,
            w: size.width as usize,
            h: size.height as usize,
        };
        self.renderer.draw(
            &mut canvas,
            term,
            &term.title,
            self.close_hover,
            &self.theme.name,
        );
        let _ = buffer.present();
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
                println!("  Ctrl+Shift+R  reload GF-shell theme");
                println!("  gf-img FILE   display an image inside the terminal");
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
