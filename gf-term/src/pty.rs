use std::io::{Read, Write};
use std::sync::mpsc::{self, Receiver, TryRecvError};
use std::thread;

use anyhow::{Context, Result};
use portable_pty::{native_pty_system, Child, CommandBuilder, MasterPty, PtySize};

pub struct PtySession {
    master: Box<dyn MasterPty + Send>,
    writer: Box<dyn Write + Send>,
    _child: Box<dyn Child + Send + Sync>,
    rx: Receiver<Vec<u8>>,
}

impl PtySession {
    pub fn spawn(cols: usize, rows: usize) -> Result<Self> {
        let shell = std::env::var("SHELL").unwrap_or_else(|_| "/bin/sh".into());
        let size = PtySize {
            rows: rows.max(2) as u16,
            cols: cols.max(2) as u16,
            pixel_width: 0,
            pixel_height: 0,
        };
        let pty_system = native_pty_system();
        let pair = pty_system.openpty(size).context("openpty")?;
        let mut cmd = CommandBuilder::new(&shell);
        cmd.env("TERM", "xterm-256color");
        cmd.env("COLORTERM", "truecolor");
        cmd.env("GF_TERMINAL", "gf-term");
        if let Ok(cwd) = std::env::current_dir() {
            cmd.cwd(cwd);
        }
        let child = pair.slave.spawn_command(cmd).context("spawn shell")?;
        drop(pair.slave);
        let mut reader = pair.master.try_clone_reader().context("pty reader")?;
        let writer = pair.master.take_writer().context("pty writer")?;
        let (tx, rx) = mpsc::channel();
        thread::spawn(move || {
            let mut buf = [0u8; 32 * 1024];
            loop {
                match reader.read(&mut buf) {
                    Ok(0) => break,
                    Ok(n) => {
                        if tx.send(buf[..n].to_vec()).is_err() {
                            break;
                        }
                    }
                    Err(_) => break,
                }
            }
        });
        Ok(Self {
            master: pair.master,
            writer,
            _child: child,
            rx,
        })
    }

    pub fn write(&mut self, bytes: &[u8]) -> Result<()> {
        self.writer.write_all(bytes)?;
        self.writer.flush()?;
        Ok(())
    }

    pub fn resize(&mut self, cols: usize, rows: usize) {
        let _ = self.master.resize(PtySize {
            rows: rows.max(2) as u16,
            cols: cols.max(2) as u16,
            pixel_width: 0,
            pixel_height: 0,
        });
    }

    pub fn transfer(&mut self) -> Vec<Vec<u8>> {
        let mut out = Vec::new();
        loop {
            match self.rx.try_recv() {
                Ok(v) => out.push(v),
                Err(TryRecvError::Empty) => break,
                Err(TryRecvError::Disconnected) => {
                    if out.is_empty() {
                        out.push(Vec::new());
                    }
                    break;
                }
            }
        }
        out
    }
}
