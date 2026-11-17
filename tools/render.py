#!/usr/bin/env python3
"""Render preview images to images/.

Each component is exported to STL first, then the scene is drawn from those
STLs in OpenSCAD preview mode (fast, coloured, no CSG preview artefacts).
Usage: python3 tools/render.py        (needs openscad; xvfb-run on headless Linux)
"""
import os, shutil, subprocess, sys, tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STD = "cad/rackit_standard.scad"
WY = "cad/devices/wyse5070.scad"

PURPLE, ORCHID, PLUM = "mediumpurple", "orchid", "plum"
GREEN, GREEN2, GOLD, GREY = "mediumseagreen", "seagreen", "goldenrod", "dimgray"

FRAME = [(STD, "ear(-1);", PURPLE, 1), (STD, "ear(1);", PURPLE, 1),
         (STD, "spine(-1);", ORCHID, 1), (STD, "spine(1);", PLUM, 1), (STD, "deck_screws();", GREY, 1)]
UNIT = FRAME + [(WY, "harness_wyse(-1);", GREEN, 1), (WY, "harness_wyse_psu(1);", GREEN2, 1),
                (WY, "psu_caddy();", GOLD, 1), (WY, "psu_dummy(1);", GREY, 0.8),
                (WY, "wyse_dummy(-1);", "gray", 0.3), (WY, "wyse_dummy(1);", "gray", 0.3)]

# name, camera "rx,ry,rz" (OpenSCAD --camera rotation), components
SCENES = [
    ("unit_wyse_front", "58,0,25", UNIT),
    ("unit_wyse_back", "55,0,160", UNIT),
    ("frame", "55,0,25", FRAME),
    ("ear_left", "60,0,140", [(STD, "ear(-1);", PURPLE, 1)]),
    ("spines_joined", "55,0,330", [(STD, "spine(-1);", ORCHID, 1), (STD, "spine(1);", PLUM, 1), (STD, "deck_screws();", GREY, 1)]),
    ("test_knuckle", "55,0,330", [(STD, "test_knuckle();", ORCHID, 1)]),
    ("test_ledge_plate", "55,0,30", [(STD, 'PART="test_ledge_plate";', PURPLE, 1)]),
    ("wyse_harness", "50,0,30", [(WY, "harness_wyse(1);", GREEN, 1)]),
    ("wyse_harness_psu", "50,0,200", [(WY, "harness_wyse_psu(1);", GREEN2, 1), (WY, "psu_caddy();", GOLD, 1),
                                      (WY, "psu_dummy(1);", GREY, 0.7), (WY, "wyse_dummy(1);", "gray", 0.3)]),
    ("wyse_half_assembled", "55,0,215", [(STD, "ear(1);", PURPLE, 1), (STD, "spine(1);", PLUM, 1),
                                         (WY, "harness_wyse(1);", GREEN, 1), (WY, "wyse_dummy(1);", "gray", 0.35)]),
]


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)


def export(tmp, cache, scad, call):
    key = (scad, call)
    if key in cache:
        return cache[key]
    path = os.path.join(tmp, f"c{len(cache)}.stl")
    src = os.path.join(tmp, f"c{len(cache)}.scad")
    with open(src, "w") as f:
        if call.startswith("PART="):      # render a PART of the entry file itself
            f.write(f'include <{os.path.join(ROOT, scad)}>\n{call}\n')
        else:
            f.write(f'include <{os.path.join(ROOT, scad)}>\nPART = "none";\n{call}\n')
    run(["openscad", "-q", "-o", path, src])
    cache[key] = path
    return path


def main():
    xvfb = [] if sys.platform == "darwin" or not shutil.which("xvfb-run") else ["xvfb-run", "-a"]
    os.makedirs(os.path.join(ROOT, "images"), exist_ok=True)
    cache = {}
    with tempfile.TemporaryDirectory() as tmp:
        for name, cam, comps in SCENES:
            lines = []
            for scad, call, color, alpha in comps:
                stl = export(tmp, cache, scad, call)
                lines.append(f'color("{color}", {alpha}) import("{stl}");')
            view = os.path.join(tmp, f"view_{name}.scad")
            with open(view, "w") as f:
                f.write("\n".join(lines) + "\n")
            out = os.path.join(ROOT, "images", f"{name}.png")
            r = run(xvfb + ["openscad", "-q", "--colorscheme=Tomorrow", "--imgsize=1400,850", "--viewall", "--autocenter",
                            f"--camera=0,0,0,{cam},0", "-o", out, view])
            print(f"  {'ok ' if r.returncode == 0 else 'BAD'} images/{name}.png")


if __name__ == "__main__":
    main()
