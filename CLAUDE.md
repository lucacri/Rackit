# Rackit: instructions for Claude

Rackit is Luca's 3D-printed half-width 1U rack-mount system (chat code name: **Operation Slim Jim**).
Hardware: Bambu Lab P1S (256 mm bed), PETG, TecMojo 20U open-frame rack in a hot attic.

## Before doing anything

Read `docs/STANDARD.md` (the contract) and `docs/LESSONS.md` (why). Read
`docs/ADDING_A_DEVICE.md` before designing a new device.

## Rules

- **Never change the standard** (`cad/lib/rackit.scad`: rack, ear, ledge, spine, joint and
  harness-interface values) unless Luca asks explicitly. Parts are already printed against it.
  If a change is unavoidable, bump `RACKIT_STANDARD_VERSION` and say what breaks.
- A **new device = a new file** `cad/devices/<device>.scad` that does `include <../lib/rackit.scad>`.
  Build the right half only, symmetric about `HALF_CX`; use `harness_body()`,
  `ledge_m3_holes()` and `in_half()`. One harness part must fit either half.
- **Never assume mounting holes.** Get the real measurements from Luca, or a primary source
  (maker's accessory or setup guide), and mark assumptions with `(MEASURE)` in the code.
- Respect the 1U envelope (z 0.5 … 43.95), print orientation (harnesses seat face down,
  no supports) and hardware limits (M3 × 6 max, short M3 inserts).
- After any CAD change: run `tools/build.sh` and `python3 tools/check.py`. Everything must
  pass. Add new parts to `tools/parts.txt`, new pairs to `tools/check.py`, and a scene to
  `tools/render.py`.
- Propose a cheap test piece or template before any long print of a new interface.
- For a new device, also write `docs/devices/<device>.md`, add a README table row, and record new lessons in `docs/LESSONS.md`.
- Luca likes to discuss the approach first: don't start building until he says to.

## Layout

- `cad/lib/rackit.scad`: the standard (no output).
- `cad/rackit_standard.scad`: ears, spines, test pieces (`PART` switch).
- `cad/devices/*.scad`: device harnesses and accessories (`PART` switch; `"none"` renders nothing).
- `stl/`: generated, print-ready. `images/`: renders plus real photos.
- `tools/`: `build.sh`, `render.py`, `check.py`, `parts.txt`.
