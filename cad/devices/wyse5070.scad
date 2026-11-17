// =====================================================================
//  RACKIT device: Dell Wyse 5070 (slim chassis)
//  Lies flat on its RIGHT side (the face with the 4 x M4 mount holes,
//  75 x 75 mm square, assumed centred on the 184 x 184 face), vented side up.
//  One harness part fits the left OR the right half.
//
//  Parts:  harness       - plain harness (ladder frame)
//          harness_psu   - harness + 2 extensions behind the Wyse for the caddy
//          psu_caddy     - velcro tray for the Dell 65 W brick (bolts on)
//          template      - 1.5 mm hole template to check the pattern on a real unit
//  Print:  harnesses seat-face DOWN (the *_print parts), caddy + template flat.
// =====================================================================
include <../lib/rackit.scad>

/* [Render] */
PART = "harness_print"; // ["harness_print","harness_psu_print","psu_caddy_print","template","harness","harness_psu","psu_caddy","preview_unit","none"]

/* [Wyse 5070] */
WY_W = 184; WY_D = 184; WY_H = 35.6;
WY_PITCH   = 75;            // 75 x 75 hole square, assumed centred on the face (check with the template)
WY_ROW_Y   = [52.5, 127.5]; // hole rows = bar rows (grid pairs 45/60 and 120/135)
WY_FRONT_Y = (WY_ROW_Y[0] + WY_ROW_Y[1])/2 - WY_D/2;   // = -2: Wyse front ~flush with the ear plates
M4_HOLE    = 4.6;           // M4 clearance
M4_SLOT    = 2;             // +-1 mm slot along X (absorbs pattern tolerance)
M4_CSK     = 9.2;           // countersink from BELOW (screws go up into the Wyse)
TIE_W      = 14;            // front-to-back ties under the hole columns
FILLET_H   = 5;             // plan fillets where ties meet bars

WY_CX = HALF_CX;            // the Wyse is centred in its half
WY_HX = [WY_CX - WY_PITCH/2, WY_CX + WY_PITCH/2];

// ---------------- harness ----------------
module wyse_plan() {
    offset(r=-FILLET_H) offset(delta=FILLET_H) union() {
        for (y = WY_ROW_Y) translate([SPINE_BEV_TOP - 1, y - BAR_W/2]) square([EAR_BEV_TOP - SPINE_BEV_TOP + 2, BAR_W]);
        for (x = WY_HX) translate([x - TIE_W/2, WY_ROW_Y[0]]) square([TIE_W, WY_ROW_Y[1] - WY_ROW_Y[0]]);
    }
}
module m4_holes() {   // slotted along X, countersunk from below
    for (yr = WY_ROW_Y, x = WY_HX) translate([x, yr, ZB - eps]) {
        hull() for (dx = [-1, 1]*M4_SLOT/2) translate([dx, 0, 0]) cylinder(d=M4_HOLE, h=BAR_TOP - ZB + 2*eps);
        hull() for (dx = [-1, 1]*M4_SLOT/2) translate([dx, 0, 0]) cylinder(d1=M4_CSK, d2=M4_HOLE, h=(M4_CSK - M4_HOLE)/2);
    }
}
module harness_wyse_right() {
    difference() {
        harness_body() wyse_plan();
        ledge_m3_holes(WY_ROW_Y);
        m4_holes();
        translate([WY_CX, WY_ROW_Y[0], BAR_TOP - 0.6]) linear_extrude(1)
            text("WYSE 5070", size=4.5, halign="center", valign="center");
    }
}
module harness_wyse(side) { in_half(side) harness_wyse_right(); }

// ---------------- harness + PSU caddy ----------------
PSU_L = 108; PSU_W = 47; PSU_H = 28;   // Dell 65 W 4.5 mm adapter (measure yours)
PSU_CLEAR  = 1.0;
CABLE_GAP  = 40;        // free space behind the Wyse for plugs
EXT_W      = 16;        // tie extension width
EXT_END    = 250;       // extensions run back to here
EXT_INS_Y  = [230, 242];
CADDY_Y0   = WY_FRONT_Y + WY_D + CABLE_GAP - 3;   // = 219
CADDY_FLOOR = 3;
STRAP_W    = 20;        // velcro strap width
STRAP_SLOT = [STRAP_W + 2, 3.5];
STRAP_DX   = 17.5;      // straps at WY_CX +- this (between the extensions)

module psu_extensions() {   // low (below the Wyse ports), full bar thickness
    minkowski() {
        translate([0, 0, ZB]) linear_extrude(BAR_TOP - ZB - TOP_CHAMFER)
            offset(delta=-TOP_CHAMFER) offset(r=-FILLET_H) offset(delta=FILLET_H) union() {
                for (x = WY_HX) translate([x - EXT_W/2, WY_ROW_Y[1]]) square([EXT_W, EXT_END - WY_ROW_Y[1]]);
                translate([WY_HX[0] - EXT_W/2, WY_ROW_Y[1] - 1]) square([WY_HX[1] - WY_HX[0] + EXT_W, BAR_W/2 + 1]);
            }
        cylinder(r1=TOP_CHAMFER, r2=0, h=TOP_CHAMFER, $fn=8);
    }
}
module harness_wyse_psu_right() {
    difference() {
        union() { harness_wyse_right(); psu_extensions(); }
        for (x = WY_HX, y = EXT_INS_Y) translate([x, y, BAR_TOP - 4.5]) cylinder(d=INS_D, h=4.5 + eps);   // M3 inserts for the caddy
    }
}
module harness_wyse_psu(side) { in_half(side) harness_wyse_psu_right(); }

module psu_caddy() {   // symmetric -> one part for either half
    iw = PSU_L + 2*PSU_CLEAR; id = PSU_W + 2*PSU_CLEAR; wt = 3;
    x0 = WY_CX - iw/2 - wt; x1 = WY_CX + iw/2 + wt;
    y0 = CADDY_Y0;          y1 = y0 + id + 2*wt;
    zf = BAR_TOP + CADDY_FLOOR;
    fx0 = min(x0, WY_HX[0] - EXT_W/2); fx1 = max(x1, WY_HX[1] + EXT_W/2);
    fy1 = max(y1, EXT_END);
    difference() {
        union() {
            translate([fx0, y0, BAR_TOP]) rounded_box(fx1 - fx0, fy1 - y0, CADDY_FLOOR, 3);          // floor
            translate([x0, y0, BAR_TOP]) rounded_box(x1 - x0, wt, CADDY_FLOOR + 8, 1.5);              // front wall
            translate([x0, y0 + id + wt, BAR_TOP]) rounded_box(x1 - x0, wt, CADDY_FLOOR + 14, 1.5);   // rear wall
            for (x = [x0, x1 - wt]) translate([x, y0, BAR_TOP]) rounded_box(wt, id + 2*wt, CADDY_FLOOR + 10, 1.5);   // end walls
        }
        for (x = [x0 - 1, x1 - wt - 1]) translate([x, y0 + wt + id/2 - 7, zf + 2]) cube([wt + 2, 14, 20]);   // cable notches
        for (dx = [-STRAP_DX, STRAP_DX], yy = [y0 + wt + 0.2, y0 + wt + id - STRAP_SLOT[1] - 0.2])          // strap slots
            translate([WY_CX + dx - STRAP_SLOT[0]/2, yy, BAR_TOP - eps]) rounded_box(STRAP_SLOT[0], STRAP_SLOT[1], CADDY_FLOOR + 2*eps, 1);
        for (x = WY_HX, y = EXT_INS_Y) translate([x, y, BAR_TOP - eps]) {                                    // M3 countersunk
            cylinder(d=M3_CLR, h=CADDY_FLOOR + 2*eps);
            translate([0, 0, CADDY_FLOOR - (M3_CSK - M3_CLR)/2 + 2*eps]) cylinder(d1=M3_CLR, d2=M3_CSK, h=(M3_CSK - M3_CLR)/2);
        }
        for (x = [WY_CX - 40 : 16 : WY_CX + 40]) if (abs(x - WY_CX) > 8 && abs(abs(x - WY_CX) - STRAP_DX) > 14)   // air slots
            translate([x - 3, y0 + wt + 12, BAR_TOP - eps]) rounded_box(6, id - 24, CADDY_FLOOR + 2*eps, 2.9);
        translate([WY_CX, (EXT_INS_Y[0] + EXT_INS_Y[1])/2 + 4, zf - 0.6]) linear_extrude(1)
            text("PSU", size=5, halign="center", valign="center");
    }
}

// ---------------- hole template ----------------
module wyse_template() {
    rim = 6; c = WY_W/2;
    linear_extrude(1.5) difference() {
        union() {
            difference() { translate([-c, -c]) square([WY_W, WY_D]); translate([-c + rim, -c + rim]) square([WY_W - 2*rim, WY_D - 2*rim]); }
            intersection() { translate([-c, -c]) square([WY_W, WY_D]);
                for (a = [45, 135]) rotate(a) square([2*c*1.414, 8], center=true); }
            circle(d=14);
        }
        for (x = [-1, 1]*WY_PITCH/2, y = [-1, 1]*WY_PITCH/2) translate([x, y]) circle(d=M4_HOLE);
        circle(d=3);
    }
    translate([0, -WY_D/2 + 3, 1.5]) linear_extrude(0.6) text("FRONT", size=3.5, halign="center", valign="center");
}

// ---------------- previews / checks (not printed) ----------------
module wyse_dummy(side) { translate([side*WY_CX - WY_W/2, WY_FRONT_Y, BAR_TOP]) cube([WY_W, WY_D, WY_H]); }
module psu_dummy(side)  { translate([side*WY_CX - PSU_L/2, CADDY_Y0 + 3 + PSU_CLEAR, BAR_TOP + CADDY_FLOOR]) cube([PSU_L, PSU_W, PSU_H]); }

// ---------------- output ----------------
if (PART == "harness_print")          translate([0, 0, BAR_TOP]) rotate([180, 0, 0]) harness_wyse(+1);
else if (PART == "harness_psu_print") translate([0, 0, BAR_TOP]) rotate([180, 0, 0]) harness_wyse_psu(+1);
else if (PART == "psu_caddy_print")   translate([0, 0, -BAR_TOP]) psu_caddy();
else if (PART == "template")          wyse_template();
else if (PART == "harness")           harness_wyse(+1);
else if (PART == "harness_psu")       harness_wyse_psu(+1);
else if (PART == "psu_caddy")         psu_caddy();
else if (PART == "preview_unit") {    // full 1U: plain harness left, PSU harness right
    color("mediumpurple") { ear(-1); ear(+1); }
    color("orchid") spine(-1); color("plum") spine(+1); deck_screws();
    color("mediumseagreen") harness_wyse(-1); color("seagreen") harness_wyse_psu(+1);
    color("goldenrod") psu_caddy(); color("dimgray") psu_dummy(1);
    color("gray", 0.35) { wyse_dummy(-1); wyse_dummy(1); }
}
// PART = "none" renders nothing (used by tools/check.py)
