# Adding a device

The frame (ears and spines) never changes. A new device only needs a new **harness** file in
`cad/devices/`. Follow these steps in order; each one exists because skipping it cost a
reprint at some point (see LESSONS).

## 1. Measure the real device

Write these down in the device file header:

- Width × depth × height (with feet), and the weight.
- **Mounting points.** VESA holes, keyholes or bracket screws, and which face they're on.
  Check the maker's accessory or setup guide; the figures usually show them even when the
  text doesn't. Never assume holes exist.
- **Ports and buttons:** which faces, and how close to the bottom edge.
- **Vents.** Which faces breathe. A face that sits on the harness or against a neighbour is a blocked face.
- **Power supply:** size, and where the cable leaves.
- Max operating temperature (spec sheet). The rack lives in an attic.

## 2. Pick an orientation and a mount style

Check the height against the 1U envelope (z 0.5 … 43.95). The usable space per half is in STANDARD.md.

| Style | When | Example |
|---|---|---|
| **A. Bolt-on harness** | The device has mounting holes on the face it lies on | Wyse 5070 (75 mm square, M4) |
| **B. Low cradle** | No holes and the device is ≤ ~40 mm tall: a thin floor between the ledges, cleats at the corners, a tall rib behind it | Beelink Mini S12 (planned) |
| **C. Feet pockets** | Taller than a cradle allows: pockets for its feet so it sits almost on the U floor | Beelink SEi8 (planned) |

Prefer letting the **device's case do the spanning** (style A). Printed plastic spanning
~190 mm sags, especially when warm.

## 3. Design the harness

Copy `cad/devices/wyse5070.scad` as a starting point. Its first line includes the standard:

```openscad
include <../lib/rackit.scad>
```

Rules:

1. **Build the right half only, symmetric about `HALF_CX` (115.75).** Use `in_half(side)` to place it.
   One part then fits both halves.
2. Draw the frame as a **2D plan** and pass it to `harness_body()`. That adds the stepped ends,
   the chamfer clearance and the top-edge chamfer automatically.
3. Put the bar rows **centred between grid positions** (y = 22.5, 37.5 … 142.5) and call
   `ledge_m3_holes([rows])`. Every bar end gets 2 × M3.
4. Screws into the device come **from below** and are countersunk, so the device sits flat.
   Slot them ±1 mm to absorb measuring error.
5. Keep ≥ 4 mm of plastic around holes, round inside corners, keep loads along the layers.
6. Add a `*_dummy(side)` box of the device for previews and checks.
7. Give the file a `PART` switch with `*_print` outputs, already oriented for the bed
   (harnesses seat face down), plus `PART = "none"` rendering nothing.

## 4. Register and check

1. Add the print parts to `tools/parts.txt`.
2. Add the new pairs to `ENVELOPE` and `INTERFERENCE` in `tools/check.py`: device vs ear, spine and harness, both halves.
3. Add a scene to `tools/render.py`.
4. Run:

```bash
tools/build.sh && python3 tools/check.py
```

Everything must say `ok`: on the bed, inside the 1U envelope, no overlaps.

## 5. Test before the big print

- If the device has mounting holes, print a **1.5 mm hole template** (see `wyse_template()`)
  and lay it on the real device.
- Anything new at the ledge or joint gets a **small test piece** first. It takes 10–30 minutes,
  where a full harness takes 2–3 hours.

## 6. Document

- `docs/devices/<device>.md`: measurements, sources, mount style, parts, hardware, what you checked.
- Add a row to the README device table. Add **photos of the real print** to `images/`.
- Anything learned that changes how future devices are designed goes in `docs/LESSONS.md`.
