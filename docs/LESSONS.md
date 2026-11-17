# Lessons: why Rackit looks the way it does

Each decision is listed with the reason behind it. Read this before changing the standard.

## Material and heat

- **PLA failed.** Earlier rack prints in PLA bent and broke. PLA softens around 55–60 °C,
  and an attic in summer gets close to that, so loaded parts creep. **PETG** (softens around
  80 °C) is the default. Use ASA if the attic gets hotter still.
- The Wyse 5070's rated maximum ambient is 40 °C (104 °F). Spacing units apart won't fix a hot attic.
  Stack units directly, leave one free U above the top unit, monitor CPU temperature over a
  whole summer, and add a slow fan if it climbs.

## Structure

- **Plastic grips, metal carries.** A printed floor spanning about 440 mm sags around 10 mm
  (estimate) and creeps. Every design since lets something stiff do the spanning: the
  device's own case (bolted at its mounting holes), or deck screws through the joint.
- **Half-width modules.** Each device gets a half from the rail to the centre line. The two
  halves joined in the middle behave like one beam fixed at both rails.
- **Load along the layers.** Parts print flat, so layers are horizontal. Bending runs
  along the layers (strong); nothing relies on layers sticking together in tension.
  Fillets go in every inside corner.

## Things we tried and dropped

- **Steel L brackets (50 × 87 mm, slotted):**
  - The 4.5 mm slot is too narrow for a 10-32 rail screw.
  - A single screw in a sideways slot lets the bracket pivot.
  - They needed cutting to length.
  - Dropped for printed ears with 2 rail screws.
- **3.5 mm steel rods as stiffeners:** about 30× less stiff than a 5 × 40 mm PETG wall. Useless
  as beams, fine as alignment pins only.
- **Steel flat bars inside the floor:** they worked on paper, but the device case does the same job for free.
- **Grip channels without screws:** replaced once Dell's own accessory guide confirmed the
  Wyse has 4 mounting holes. Check the maker's guides before designing around "no holes".
- **Bowtie key in the centre:** sensitive to print tolerance. The knuckle joint with deck screws won.
- **Pull tab on the ear:** stuck out 12 mm, could snap, and caught cables. Removed.

## The centre joint

- **Knuckles + deck screws.** #9 × 2½" Grip-Rite exterior screws are cheap and you have
  plenty. The bugle head pulls the end knuckle in while the threads pull the inner ones out,
  so the stack clamps itself and has no play. Two rows about 24 mm apart make it rigid,
  where one row would be a hinge.
- **8 segments, not 7.** With 7, one side gets 4 knuckles and the other 3. 8 gives
  4 + 4 and makes the two spines symmetric (front screw head on the left, rear on the right).
- **Tested, and it printed perfectly:** 0.3 mm face gap, 0.5 mm tip gap, 1 mm lead-in
  chamfer, 3.6 mm pilot, 5.2 mm clearance, flat-roofed (teardrop) horizontal holes.

## The ledge interface

- **The L-ledge beats an insert grid on the walls.** With a ledge, the harness rests on plastic
  and the weight presses straight down into it, so the screws only locate it. Inserts go in
  vertically, the best direction for heat-set inserts. The chamfer in the corner keeps the
  ledge from cracking off the wall.
- **Short inserts only.** The ledge is 4 mm thick. Common M3 inserts are 5.7 mm long and would poke into the U below.
- **Insert holes go all the way through.** A 0.5 mm floor could bulge or break when pressing
  the insert. With a through-hole, the displaced plastic escapes downward.
- **Printed pegs shear off.** A peg printed standing up breaks along its layer lines. Use steel screws as pins.
- **M3 × 6 is the maximum.** 7 mm bottoms out in the hole; 8 mm pokes below the U line.
- **Countersinks: 7.0 mm for M3, 9.2 mm for M4.** Standard ISO flat heads otherwise stood
  about 0.2 mm proud and could rock the device.
- **Tested:** the ledge test plate printed and fitted well.

## Printing

- **Harnesses print seat face down.** Printed the other way up, the stepped bar ends are
  flat ceilings 4 mm above the bed, and that's exactly the face that has to sit flat on the
  ledge. An independent review caught this before the first harness was printed.
- **Elephant's foot:** 0.4 mm chamfer on bottom edges that mate with something, because
  the gaps are only 0.3 mm.
- **Test pieces first.** Every new interface gets a 10–30 minute test print before a 2–3 hour part.
- **One symmetric harness, not left/right copies.** A mirrored copy also mirrored the
  engraved label, so it read backwards. Harnesses are symmetric about their half's centre,
  and the left one is the same part shifted.

## Process

- Measure the real device, and read the maker's accessory guide. The Wyse's mounting holes
  only showed up in Dell's figures, not in the text.
- Check every change with `tools/check.py` (bed fit, 1U envelope, overlaps) before printing.
- For anything high-stakes, have a second, independent review of the files before printing.
