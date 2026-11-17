#!/usr/bin/env python3
"""Rackit checks: run after tools/build.sh.

1. Every STL in tools/parts.txt: one watertight body (test plates may have
   several), fits the printer bed, sits on z = 0.
2. Assembled position: every part stays inside its 1U (z 0.5 .. 43.95).
3. Interference: listed part pairs may touch but must not overlap.

Usage: python3 tools/check.py [--bed 256]
Needs: openscad, python3 with trimesh (pip install trimesh)
"""
import argparse, os, subprocess, sys, tempfile, warnings
warnings.filterwarnings("ignore")
import trimesh

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
U, U_GAP = 44.45, 0.5
Z_MIN, Z_MAX = U_GAP, U - U_GAP
TOL = 0.01          # mm / mm^3 tolerance

# parts that are allowed to have more than one body
MULTI_BODY = {"0_test_knuckle.stl", "0_test_ledge_plate.stl"}

# Assembled-position checks: (include file, module call) -> must stay in the 1U envelope
ENVELOPE = [
    ("cad/rackit_standard.scad", "ear(-1);"), ("cad/rackit_standard.scad", "ear(1);"),
    ("cad/rackit_standard.scad", "spine(-1);"), ("cad/rackit_standard.scad", "spine(1);"),
    ("cad/devices/wyse5070.scad", "harness_wyse(-1);"), ("cad/devices/wyse5070.scad", "harness_wyse(1);"),
    ("cad/devices/wyse5070.scad", "harness_wyse_psu(1);"), ("cad/devices/wyse5070.scad", "psu_caddy();"),
    ("cad/devices/wyse5070.scad", "wyse_dummy(1);"), ("cad/devices/wyse5070.scad", "psu_dummy(1);"),
]

# Interference pairs: (include file, a, b) -> overlap volume must be ~0 (touching is fine)
INTERFERENCE = [
    ("cad/rackit_standard.scad", "spine(-1)", "spine(1)"),
    ("cad/rackit_standard.scad", "ear(1)", "spine(1)"),
    ("cad/devices/wyse5070.scad", "ear(1)", "harness_wyse(1)"),
    ("cad/devices/wyse5070.scad", "spine(1)", "harness_wyse(1)"),
    ("cad/devices/wyse5070.scad", "ear(-1)", "harness_wyse(-1)"),
    ("cad/devices/wyse5070.scad", "spine(-1)", "harness_wyse(-1)"),
    ("cad/devices/wyse5070.scad", "harness_wyse(1)", "wyse_dummy(1)"),
    ("cad/devices/wyse5070.scad", "ear(1)", "wyse_dummy(1)"),
    ("cad/devices/wyse5070.scad", "spine(1)", "wyse_dummy(1)"),
    ("cad/devices/wyse5070.scad", "ear(1)", "harness_wyse_psu(1)"),
    ("cad/devices/wyse5070.scad", "spine(1)", "harness_wyse_psu(1)"),
    ("cad/devices/wyse5070.scad", "psu_caddy()", "harness_wyse_psu(1)"),
    ("cad/devices/wyse5070.scad", "psu_caddy()", "wyse_dummy(1)"),
    ("cad/devices/wyse5070.scad", "psu_caddy()", "psu_dummy(1)"),
]


def openscad_eval(include, body, tmp):
    """Render `body` with `include` loaded (PART forced to "none"); return mesh or None if empty."""
    scad = os.path.join(tmp, "t.scad")
    stl = os.path.join(tmp, "t.stl")
    if os.path.exists(stl):
        os.remove(stl)
    with open(scad, "w") as f:
        f.write(f'include <{os.path.join(ROOT, include)}>\nPART = "none";\n{body}\n')
    subprocess.run(["openscad", "-q", "-o", stl, scad], capture_output=True)
    if not os.path.exists(stl) or os.path.getsize(stl) == 0:
        return None
    try:
        m = trimesh.load(stl)
    except Exception:
        return None
    return m if len(m.faces) else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bed", type=float, default=256.0)
    args = ap.parse_args()
    problems = []

    print("== printable STLs")
    with open(os.path.join(ROOT, "tools/parts.txt")) as f:
        rows = [l.split() for l in f if l.strip() and not l.startswith("#")]
    for scad, part, out in rows:
        path = os.path.join(ROOT, out)
        if not os.path.exists(path):
            problems.append(f"{out}: missing (run tools/build.sh)"); print(f"  MISSING {out}"); continue
        m = trimesh.load(path)
        size = m.bounds[1] - m.bounds[0]
        bodies = len(m.split(only_watertight=False))
        ok = True
        if not m.is_watertight: problems.append(f"{out}: not watertight"); ok = False
        if bodies > 1 and os.path.basename(out) not in MULTI_BODY: problems.append(f"{out}: {bodies} bodies"); ok = False
        if max(size[0], size[1]) > args.bed or size[2] > args.bed: problems.append(f"{out}: too big for the bed {size.round(1)}"); ok = False
        if abs(m.bounds[0][2]) > TOL: problems.append(f"{out}: not on the bed (z min {m.bounds[0][2]:.2f})"); ok = False
        print(f"  {'ok ' if ok else 'BAD'} {out:48s} {size[0]:6.1f} x {size[1]:6.1f} x {size[2]:5.1f} mm  {m.volume/1000:6.1f} cm3")

    with tempfile.TemporaryDirectory() as tmp:
        print(f"== 1U envelope (z {Z_MIN} .. {Z_MAX})")
        for inc, body in ENVELOPE:
            m = openscad_eval(inc, body, tmp)
            if m is None:
                problems.append(f"{body}: renders empty"); print(f"  BAD {body} empty"); continue
            z0, z1 = m.bounds[0][2], m.bounds[1][2]
            ok = z0 >= Z_MIN - TOL and z1 <= Z_MAX + TOL
            if not ok: problems.append(f"{body}: z {z0:.2f}..{z1:.2f} outside the 1U envelope")
            print(f"  {'ok ' if ok else 'BAD'} {body:28s} z {z0:6.2f} .. {z1:6.2f}")

        print("== interference (touching is fine, overlap is not)")
        for inc, a, b in INTERFERENCE:
            m = openscad_eval(inc, f"intersection() {{ {a}; {b}; }}", tmp)
            vol = 0.0 if m is None else abs(m.volume)
            ok = vol <= TOL
            if not ok: problems.append(f"{a} x {b}: overlap {vol:.3f} mm3")
            print(f"  {'ok ' if ok else 'BAD'} {a:22s} x {b:22s} overlap {vol:.3f} mm3")

    print()
    if problems:
        print("FAILED:"); [print("  -", p) for p in problems]; sys.exit(1)
    print("All checks passed.")


if __name__ == "__main__":
    main()
