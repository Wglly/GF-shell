#!/usr/bin/env python3
"""Set the niri cursor theme in its config; niri auto-reloads on save."""
import argparse, os, re, shutil, subprocess, sys

def root_and_main():
    explicit = os.environ.get("NIRI_CONFIG", "")
    if explicit:
        return os.path.dirname(os.path.abspath(explicit)), os.path.abspath(explicit)
    base = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    p = os.path.join(base, "niri", "config.kdl")
    return os.path.dirname(p), p

def files(root):
    out = []
    main = os.path.join(root, "config.kdl")
    if os.path.isfile(main):
        out.append(main)
    d = os.path.join(root, "config.d")
    if os.path.isdir(d):
        out += [os.path.join(d, n) for n in sorted(os.listdir(d)) if n.endswith(".kdl")]
    return out

def block_bounds(lines):
    for i, line in enumerate(lines):
        if re.match(r'^\s*cursor\s*\{', line):
            depth = 0
            for j in range(i, len(lines)):
                depth += lines[j].count("{") - lines[j].count("}")
                if depth <= 0:
                    return i, j
    return None

def patch(path, theme, size):
    lines = open(path, encoding="utf-8").readlines()
    b = block_bounds(lines)
    if b:
        start, end = b
        inner = lines[start + 1:end]
        indent = (re.match(r'^(\s*)', lines[start]).group(1) or "") + "    "
        for key, val in [("xcursor-theme", '"' + theme + '"'), ("xcursor-size", str(size))]:
            pat = re.compile(r'^(\s*)' + re.escape(key) + r'\s+.*$')
            hit = False
            for i, ln in enumerate(inner):
                m = pat.match(ln)
                if m:
                    inner[i] = m.group(1) + key + " " + val + "\n"
                    hit = True
                    break
            if not hit:
                inner.append(indent + key + " " + val + "\n")
        lines[start + 1:end] = inner
    else:
        lines.append("\ncursor {\n    xcursor-theme \"" + theme + "\"\n    xcursor-size " + str(size) + "\n}\n")
    tmp = path + ".gf-tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.writelines(lines)
    os.replace(tmp, path)
    return True

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--theme", required=True)
    ap.add_argument("--size", type=int, required=True)
    args = ap.parse_args()
    root, main_cfg = root_and_main()
    cfgs = files(root)
    if not cfgs:
        print("niri config not found", file=sys.stderr)
        return 1
    target = next((p for p in cfgs if block_bounds(open(p, encoding="utf-8").readlines())), None)
    if target is None:
        target = next((p for p in cfgs if "input" in open(p, encoding="utf-8").read()), main_cfg)
    if not os.path.isfile(target):
        target = main_cfg
    for p in [target, main_cfg]:
        if p and os.path.isfile(p):
            bak = p + ".gf-backup"
            if not os.path.exists(bak):
                shutil.copy2(p, bak)
    patch(target, args.theme, args.size)
    if shutil.which("niri"):
        r = subprocess.run(["niri", "validate", "-c", main_cfg], capture_output=True, text=True)
        if r.returncode != 0:
            for p in [target, main_cfg]:
                bak = p + ".gf-backup"
                if os.path.exists(bak):
                    shutil.copy2(bak, p)
            print(r.stderr[-800:], file=sys.stderr)
            return 2
    return 0

if __name__ == "__main__":
    sys.exit(main())
