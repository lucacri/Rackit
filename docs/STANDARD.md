# Rackit standard (v1.0)

This is the contract every Rackit part follows. The numbers live in
`cad/lib/rackit.scad`. If one of them changes, every part printed before may stop fitting,
so treat a change as a new standard version.

## Coordinates

All CAD uses one frame of reference for a single 1U unit:

- **X** runs across the rack. 0 is the centre line; the right half is +X, the left half −X.
- **Y** is depth. 0 is the front face of the rails, and + goes toward the back.
- **Z** is up. 0 is the bottom U line.

Parts are modelled in their installed position. The print orientation is chosen when exporting.

## Rack (EIA-310)

| | Value |
|---|---|
| 1U | 44.45 mm |
| Rail hole centres | x = ±232.55 (465.1 apart) |
| Holes used | z = 6.35 and 38.1 (top and bottom hole of the U) |
| Rack opening | 450 mm (x = ±225) |
| **Envelope of a unit** | **z 0.5 … 43.95**: 0.5 mm kept clear at each U line, so units stack with no gaps |

## Ear (left and right are mirror images)

| Feature | Value |
|---|---|
| Front plate | 5 mm thick, in front of the rail (y −5 … 0), reaches x = 241.55 |
| Rail slots | 9 × 5.3 mm (10-32), sideways for ±1.85 mm of play. For M6 racks use `RAIL_SLOT = [9, 6.5]` |
| Side wall | x 214 … 224 (10 mm thick, 1 mm inside the opening), y −5 … 160 |
| **Ledge** | x 196 … 214, top at **z 4.5** (4 mm thick), full depth |
| Chamfer | 6 mm, 45°, in the corner between ledge and wall |
| **Insert grid** | x = 202, **y = 15, 30 … 150** (10 positions, 15 mm pitch). 4.0 mm through-holes for **short M3 inserts (3–4 mm)** |
| Edges | 0.4 mm elephant's-foot chamfer on mating bottom edges; rounded top edges and corners |

## Spine (left and right differ: their knuckles alternate)

| Feature | Value |
|---|---|
| Wall | inner face x = 7.5, **outer face x = 17.5**, y 0 … 160 |
| Ledge | x 17.5 … 35.5, top at z 4.5; same chamfer and insert grid as the ear (insert column x = 29.5) |
| Knuckle joint | y 10 … 150, **8 segments × 17.5 mm**. The left spine owns the even segments, the right spine the odd ones, so each has 4 knuckles |
| Knuckles | reach 7 mm past the centre line; tip chamfer 1 mm; fillets 1.5 mm |
| Clearances (tested) | **0.3 mm** between knuckle faces, **0.5 mm** from a knuckle tip to the other spine |
| Pins | 4 × #9 × 2½" bugle-head deck screws, at z = 10.5 and 33.95. Per row: one from the front through the left spine's front knuckle, one from the back through the right spine's rear knuckle |
| Holes (tested) | 5.2 mm clearance in the end knuckles, **3.6 mm pilot** in the inner ones, 9.5 mm countersink |

## Harness interface (how every device harness sits)

| Rule | Value |
|---|---|
| Seat | Bar ends **rest on the ledge top (z 4.5)**. Between the ledges the bar drops to the U floor |
| Device seat height | **z 7.85** (bar 7.35 mm thick) |
| Gaps | 0.3 mm from the bar step to the ledge edge; 0.5 mm from the bar bevel to the chamfer |
| Screws | **2 per bar end**, M3 × 6 flat head (DIN 7991 / ISO 10642) into the ledge inserts at neighbouring grid positions. Countersink 7.0 mm. **6 mm is the maximum length** |
| Bar rows | a bar is centred between two grid positions: y = 22.5, 37.5 … 142.5 |
| Symmetry | design every harness symmetric about the centre of its half (**x = 115.75**). Then **one part fits either half**: the left half gets the same part shifted, not mirrored |
| Print | **seat face down** (flipped): the stepped ends then face up and need no supports |

Use the library helpers `harness_body()`, `span_profile()`, `ledge_m3_holes(rows)` and
`in_half(side)` in `cad/lib/rackit.scad`. They already apply every rule above.

## Space available in one half

| Device sits… | Max width | Max height |
|---|---|---|
| on a harness (bottom at z 7.85) | ~189 mm (191 between the chamfers) | 36.1 mm |
| above the chamfers (bottom ≥ z 10.5) | ~194 mm (196.5 wall to wall) | 33.4 mm |
| low between the ledges (floor ~3 mm) | ~158 mm (160.5 between the ledge edges) | ~40 mm |

Depth isn't limited by the frame (160 mm deep); devices may overhang at the back.
Anything wider than ~194 mm needs a full-width module: the same ears, no spines.

## Printing

- **PETG**, 5 walls, 40 % gyroid for ears and spines, 30 % for harnesses, 100 % modifier around inserts. No supports.
- Ears and spines print as modelled, ledge on the bed. Harnesses print flipped, seat face down.
- Load always goes along the layers or presses into them, never pulls them apart (see LESSONS).
