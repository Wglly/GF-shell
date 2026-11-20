#!/usr/bin/env python3
"""Patch niri layout settings from GF-shell; niri auto-reloads on save."""
import argparse, os, re, shutil, subprocess, sys

def config_root():
    explicit = os.environ.get("NIRI_CONFIG", "")
    if explicit:
        return os.path.dirname(os.path.abspath(explicit)), os.path.abspath(explicit)
    base = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    p = os.path.join(base, "niri", "config.kdl")
    return os.path.dirname(p), p

def kdl_files(root):
    out = []
    main = os.path.join(root, "config.kdl")
    if os.path.isfile(main):
        out.append(main)
    d = os.path.join(root, "config.d")
    if os.path.isdir(d):
        for name in sorted(os.listdir(d)):
            if name.endswith(".kdl"):
                out.append(os.path.join(d, name))
    return out

def block_bounds(lines, name):
    pat = re.compile(r'^(\s*)' + re.escape(name) + r'\s*\{')
    for i, line in enumerate(lines):
        if pat.match(line):
            depth = 0
            for j in range(i, len(lines)):
                depth += lines[j].count("{") - lines[j].count("}")
                if depth <= 0:
                    return i, j
            return i, len(lines) - 1
    return None

def patch_block(lines, name, values, enabled=None):
    b = block_bounds(lines, name)
    if not b:
        return False
    start, end = b
    indent = re.match(r'^(\s*)', lines[start]).group(1) + "    "
    inner = lines[start + 1:end]
    if enabled is not None:
        inner = [ln for ln in inner if ln.strip() != "off"]
        if not enabled:
            inner.insert(0, indent + "off\n")
    for key, val in values.items():
        if val is None:
            continue
        keypat = re.compile(r'^(\s*)' + re.escape(key) + r'\s+.*$')
        done = False
        for i, ln in enumerate(inner):
            m = keypat.match(ln)
            if m:
                inner[i] = m.group(1) + key + " " + str(val) + "\n"
                done = True
                break
        if not done:
            inner.append(indent + key + " " + str(val) + "\n")
    lines[start + 1:end] = inner
    return True

def write_lines(path, lines):
    data = "".join(lines)
    tmp = path + ".gf-tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(data)
    os.replace(tmp, path)

def patch(path, args):
    lines = open(path, encoding="utf-8").readlines()
    changed = False
    for i, ln in enumerate(lines):
        if re.match(r'^\s*gaps\s+\d+', ln):
            indent = re.match(r'^(\s*)', ln).group(1)
            new = indent + "gaps " + str(args.gaps) + "\n"
            if lines[i] != new:
                lines[i] = new
                changed = True
            break
    b = block_bounds(lines, "layout")
    if b:
        start, end = b
        layout_lines = lines[start:end + 1]
        for name, cmd, enabled in [
            ("focus-ring", "focus", args.focus_enabled),
            ("border", "border", args.border_enabled),
        ]:
            values = {}
            if cmd == "focus":
                values["width"] = args.focus_width
                values["active-color"] = '"' + args.active_color + '"'
                values["inactive-color"] = '"' + args.inactive_color + '"'
            else:
                values["width"] = args.border_width
                values["active-color"] = '"' + args.active_color + '"'
                values["inactive-color"] = '"' + args.inactive_color + '"'
            if patch_block(layout_lines, name, values, enabled):
                changed = True
        lines[start:end + 1] = layout_lines
    if changed:
        write_lines(path, lines)
    return changed

def patch_radius(files, radius):
    for path in files:
        text = open(path, encoding="utf-8").read()
        if not re.search(r'geometry-corner-radius\s+\d+', text):
            continue
        text2 = re.sub(r'(geometry-corner-radius\s+)\d+', r'\g<1>' + str(radius), text)
        if text2 != text:
            with open(path, "w", encoding="utf-8") as f:
                f.write(text2)
            return True
    # No global radius yet: append a managed global rule.
    target = next((p for p in files if "window-rule" in open(p, encoding="utf-8").read()),
                  files[0] if files else "")
    if not target:
        return False
    text = open(target, encoding="utf-8").read()
    marker = "// gf-shell: global corner radius\n"
    text = re.sub(r'// gf-shell: global corner radius\nwindow-rule \\{[^}]*\\}\n?', '', text)
    text = text.rstrip() + "\n\n" + marker
    text += "window-rule {\n    geometry-corner-radius " + str(radius) + "\n    clip-to-geometry true\n}\n"
    with open(target, "w", encoding="utf-8") as f:
        f.write(text)
    return True

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--gaps", type=int, required=True)
    ap.add_argument("--border-width", type=int, required=True)
    ap.add_argument("--focus-width", type=int, required=True)
    ap.add_argument("--radius", type=int, required=True)
    ap.add_argument("--active-color", required=True)
    ap.add_argument("--inactive-color", required=True)
    ap.add_argument("--border-enabled", type=int, required=True)
    ap.add_argument("--focus-enabled", type=int, required=True)
    args = ap.parse_args()
    root, main = config_root()
    files = kdl_files(root)
    if not files:
        print("niri config not found", file=sys.stderr)
        return 1
    layout_file = next((p for p in files if re.search(r'^\s*layout\s*\{', open(p, encoding="utf-8").read(), re.M)), "")
    if not layout_file:
        print("niri layout block not found", file=sys.stderr)
        return 1
    for p in [layout_file, main]:
        if p and os.path.isfile(p):
            backup = p + ".gf-backup"
            if not os.path.exists(backup):
                shutil.copy2(p, backup)
    args.border_enabled = bool(args.border_enabled)
    args.focus_enabled = bool(args.focus_enabled)
    patch(layout_file, args)
    patch_radius(files, args.radius)
    # Validate the root config if possible; restore backups on failure.
    if shutil.which("niri"):
        r = subprocess.run(["niri", "validate", "-c", main], capture_output=True, text=True)
        if r.returncode != 0:
            for p in files:
                bak = p + ".gf-backup"
                if os.path.exists(bak):
                    shutil.copy2(bak, p)
            print(r.stderr[-800:], file=sys.stderr)
            return 2
    return 0

if __name__ == "__main__":
    sys.exit(main())
