use std::ffi::CString;

use anyhow::{anyhow, Result};
use glutin::config::{ConfigTemplateBuilder, GlConfig};
use glutin::context::{ContextAttributesBuilder, PossiblyCurrentContext};
use glutin::display::{Display, GetGlDisplay};
use glutin::prelude::*;
use glutin::surface::{Surface, WindowSurface};
use glutin_winit::{DisplayBuilder, GlWindow};
use glow::HasContext;
use raw_window_handle::HasWindowHandle;
use winit::event_loop::ActiveEventLoop;
use winit::window::Window;

const VS: &str = r#"#version 330 core
out vec2 v_uv;
void main() {
    vec2 p = vec2(float((gl_VertexID << 1) & 2), float(gl_VertexID & 2));
    v_uv = vec2(p.x, 1.0 - p.y);
    gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
}
"#;

const FS: &str = r#"#version 330 core
in vec2 v_uv;
out vec4 frag;
uniform sampler2D tex;
uniform float alpha;
void main() {
    vec4 c = texture(tex, v_uv);
    frag = vec4(c.rgb * alpha, alpha);
}
"#;

pub struct GlState {
    _display: Display,
    context: PossiblyCurrentContext,
    surface: Surface<WindowSurface>,
    gl: glow::Context,
    program: glow::Program,
    texture: glow::Texture,
    vao: glow::VertexArray,
    alpha_loc: Option<glow::UniformLocation>,
}

pub struct CreatedWindow {
    pub window: Window,
    pub gl: GlState,
}

fn shader(gl: &glow::Context, ty: u32, src: &str) -> Result<glow::Shader> {
    unsafe {
        let s = gl.create_shader(ty).map_err(|e| anyhow!(e))?;
        gl.shader_source(s, src);
        gl.compile_shader(s);
        if !gl.get_shader_compile_status(s) {
            let log = gl.get_shader_info_log(s);
            return Err(anyhow!("shader compile: {log}"));
        }
        Ok(s)
    }
}

impl GlState {
    pub fn create(
        event_loop: &ActiveEventLoop,
        attrs: winit::window::WindowAttributes,
        opacity: f32,
    ) -> Result<CreatedWindow> {
        let _ = opacity;
        let template = ConfigTemplateBuilder::new()
            .with_alpha_size(8)
            .with_transparency(true)
            .with_depth_size(0)
            .with_stencil_size(0);
        let (window, config) = DisplayBuilder::new()
            .with_window_attributes(Some(attrs))
            .build(event_loop, template, |configs| {
                configs
                    .max_by_key(|c| {
                        (
                            c.supports_transparency().unwrap_or(false) as u8,
                            c.alpha_size(),
                            c.srgb_capable() as u8,
                        )
                    })
                    .expect("no OpenGL config")
            })
            .map_err(|e| anyhow!("OpenGL display: {e}"))?;
        let window = window.ok_or_else(|| anyhow!("no window"))?;
        let display = config.display().clone();
        let raw = window.window_handle()?.as_raw();
        let ctx_attrs = ContextAttributesBuilder::new().build(Some(raw));
        let not_current = unsafe { display.create_context(&config, &ctx_attrs)? };
        let surface_attrs = window.build_surface_attributes(Default::default())?;
        let surface = unsafe { display.create_window_surface(&config, &surface_attrs)? };
        let context = not_current.make_current(&surface)?;
        let gl = unsafe {
            glow::Context::from_loader_function(|s| {
                let cs = CString::new(s).expect("gl proc");
                display.get_proc_address(&cs)
            })
        };

        let (program, texture, vao, alpha_loc) = unsafe {
            let vs = shader(&gl, glow::VERTEX_SHADER, VS)?;
            let fs = shader(&gl, glow::FRAGMENT_SHADER, FS)?;
            let program = gl.create_program().map_err(|e| anyhow!(e))?;
            gl.attach_shader(program, vs);
            gl.attach_shader(program, fs);
            gl.link_program(program);
            if !gl.get_program_link_status(program) {
                return Err(anyhow!("program link: {}", gl.get_program_info_log(program)));
            }
            gl.detach_shader(program, vs);
            gl.detach_shader(program, fs);
            gl.delete_shader(vs);
            gl.delete_shader(fs);

            let texture = gl.create_texture().map_err(|e| anyhow!(e))?;
            gl.bind_texture(glow::TEXTURE_2D, Some(texture));
            gl.tex_parameter_i32(glow::TEXTURE_2D, glow::TEXTURE_MIN_FILTER, glow::LINEAR as i32);
            gl.tex_parameter_i32(glow::TEXTURE_2D, glow::TEXTURE_MAG_FILTER, glow::LINEAR as i32);
            gl.tex_parameter_i32(glow::TEXTURE_2D, glow::TEXTURE_WRAP_S, glow::CLAMP_TO_EDGE as i32);
            gl.tex_parameter_i32(glow::TEXTURE_2D, glow::TEXTURE_WRAP_T, glow::CLAMP_TO_EDGE as i32);
            gl.pixel_store_i32(glow::UNPACK_ALIGNMENT, 1);
            let vao = gl.create_vertex_array().map_err(|e| anyhow!(e))?;
            gl.bind_vertex_array(Some(vao));
            gl.use_program(Some(program));
            let tex_loc = gl.get_uniform_location(program, "tex");
            if let Some(loc) = &tex_loc { gl.uniform_1_i32(Some(loc), 0); }
            let alpha_loc = gl.get_uniform_location(program, "alpha");
            (program, texture, vao, alpha_loc)
        };

        Ok(CreatedWindow {
            window,
            gl: Self { _display: display, context, surface, gl, program, texture, vao, alpha_loc },
        })
    }

    pub fn resize(&mut self, window: &Window) {
        window.resize_surface(&self.surface, &self.context);
    }

    pub fn draw(&mut self, pixels: &[u32], w: usize, h: usize, alpha: f32) {
        if w == 0 || h == 0 || pixels.len() < w * h { return; }
        let mut rgba = Vec::with_capacity(w * h * 4);
        for &p in &pixels[..w * h] {
            rgba.push(((p >> 16) & 0xff) as u8);
            rgba.push(((p >> 8) & 0xff) as u8);
            rgba.push((p & 0xff) as u8);
            rgba.push(255);
        }
        unsafe {
            let gl = &self.gl;
            gl.viewport(0, 0, w as i32, h as i32);
            gl.disable(glow::BLEND);
            gl.disable(glow::SCISSOR_TEST);
            gl.clear_color(0.0, 0.0, 0.0, 0.0);
            gl.clear(glow::COLOR_BUFFER_BIT);
            gl.active_texture(glow::TEXTURE0);
            gl.bind_texture(glow::TEXTURE_2D, Some(self.texture));
            gl.tex_image_2d(
                glow::TEXTURE_2D,
                0,
                glow::RGBA8 as i32,
                w as i32,
                h as i32,
                0,
                glow::RGBA,
                glow::UNSIGNED_BYTE,
                glow::PixelUnpackData::Slice(Some(&rgba)),
            );
            gl.use_program(Some(self.program));
            gl.bind_vertex_array(Some(self.vao));
            if let Some(loc) = &self.alpha_loc { gl.uniform_1_f32(Some(loc), alpha.clamp(0.2, 1.0)); }
            gl.draw_arrays(glow::TRIANGLES, 0, 3);
        }
        if let Err(e) = self.surface.swap_buffers(&self.context) {
            eprintln!("gf-term: swap buffers: {e}");
        }
    }
}
