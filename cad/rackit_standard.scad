// =====================================================================
//  RACKIT - standard parts (print once per 1U unit, any devices)
//  Pick a PART and export, or run tools/build.sh to export everything.
// =====================================================================
include <lib/rackit.scad>

/* [Render] */
PART = "ear_left"; // ["ear_left","ear_right","spine_left","spine_right","basic_bar","test_knuckle","test_ledge_plate","preview_frame"]

// ---------------- test pieces ----------------
// Knuckle-joint test: the front half of the centre joint (2 knuckles per
// side, one front screw per row). Same geometry as the full spines.
module test_knuckle() {
    for (s = [-1, 1]) intersection() {
        spine(s);
        translate([-SPINE_FACE - 0.01, 0, 0]) cube([2*SPINE_FACE + 0.02, J_Y0 + 4*J_SEG_L + 2, U]);
    }
}
// Ledge test: a 45 mm slice of the right ear (ledge, chamfer, inserts at
// y 45/60/75) + a basic bar end that seats on it (printed seat-face down).
TEST_Y0 = 37.5; TEST_Y1 = 82.5; TEST_ZTOP = 16;
module test_ledge_ear() {
    intersection() { ear(+1); translate([LEDGE_X0 - 2, TEST_Y0, 0]) cube([WALL_X1 - LEDGE_X0 + 4, TEST_Y1 - TEST_Y0, TEST_ZTOP]); }
}
module test_ledge_bar() { harness_bar_right(168, 45); }   // bar end, screws at y 45 / 60

// ---------------- output ----------------
// print parts are dropped by ZB so they sit on the bed (z = 0)
if (PART == "ear_left")          translate([0, 0, -ZB]) ear(-1);
else if (PART == "ear_right")    translate([0, 0, -ZB]) ear(+1);
else if (PART == "spine_left")   translate([0, 0, -ZB]) spine(-1);
else if (PART == "spine_right")  translate([0, 0, -ZB]) spine(+1);
// a plain bar between ear and spine ledges is device-specific (see devices/);
// basic_bar = a bar end on the RIGHT EAR only, for experiments
else if (PART == "basic_bar")    translate([0, 0, BAR_TOP]) rotate([180, 0, 0]) harness_bar_right(40, 60);
else if (PART == "test_knuckle") translate([0, 0, -ZB]) test_knuckle();
else if (PART == "test_ledge_plate") {
    translate([-180, -TEST_Y0, -ZB]) test_ledge_ear();
    translate([-170, 117.5, BAR_TOP]) rotate([180, 0, 0]) test_ledge_bar();   // seat face down
}
else if (PART == "preview_frame") {   // ears + spines of one 1U unit, for renders
    color("mediumpurple") { ear(-1); ear(+1); }
    color("orchid") spine(-1); color("plum") spine(+1);
    deck_screws();
}
