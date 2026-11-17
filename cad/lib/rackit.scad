// =====================================================================
//  RACKIT standard library  (cad/lib/rackit.scad)
//  Half-width 1U modules for 19" EIA-310 racks.
//
//  This file holds ONLY the standard: constants + modules, no geometry is
//  emitted. Entry files (cad/rackit_standard.scad, cad/devices/*.scad)
//  `include <...>` it and pick a PART to render.
//
//  DO NOT change values in the "standard" sections without bumping the
//  standard version in docs/STANDARD.md - every printed part depends on them.
//
//  Axes: X across the rack (0 = centre line), Y depth (0 = rail front
//  face, + toward the back), Z up (0 = bottom U line).
// =====================================================================

RACKIT_STANDARD_VERSION = "1.0";

/* [Rack] */
U        = 44.45;
U_GAP    = 0.5;
RAIL_HX  = 465.1/2;
OPEN_HX  = 450/2;            // rack opening edge (rail inner edge)
RAIL_HZ  = [6.35, 38.1];     // top + bottom hole of the U
RAIL_SLOT = [9, 5.3];        // sideways slot (length, width) for 10-32

/* [Ear] */
PLATE_T  = 5;                // front plate thickness (in front of the rail)
PLATE_OUT = 9;               // plate reaches this far past the rail hole
WALL_T   = 10;               // side wall (stiff spine of the ear)
WALL_CLEAR = 1;              // wall outer face this far inside the opening
DEPTH    = 160;              // ear length behind the rail face

/* [Ledge - the universal interface] */
LEDGE_W  = 18;               // how far it sticks out from the wall
LEDGE_T  = 4;                // thickness (bars sit on top of this)
CHAMFER  = 6;                // 45 deg chamfer in the inside corner
GRID_Y0  = 15;               // first insert
GRID_P   = 15;               // insert pitch along the depth
GRID_N   = 10;               // 15 .. 150
INS_D    = 4.0;              // hole for M3 x 3 (OD ~4.2-4.6) heat-set insert
INS_DEPTH = LEDGE_T + 0.02;  // through-hole: displaced plastic escapes downward, no bulge

/* [Print tuning] */
EF_CHAMFER  = 0.4;           // elephant-foot chamfer on bottom edges that mate
TOP_CHAMFER = 0.6;           // softened top edges on harnesses

/* [Extras] */
TAB      = false;            // optional pull tab (off: flat front)
LIGHTEN  = true;             // windows in the wall (keeps top & bottom chords)

$fn = 48;
eps = 0.01;

// ---------------- derived ----------------
ZB = U_GAP; ZT = U - U_GAP; H = ZT - ZB;
WALL_X1 = OPEN_HX - WALL_CLEAR;      // wall outer face
WALL_X0 = WALL_X1 - WALL_T;          // wall inner face
LEDGE_X0 = WALL_X0 - LEDGE_W;        // ledge inner edge
PLATE_X1 = RAIL_HX + PLATE_OUT;
LEDGE_TOP = ZB + LEDGE_T;
// insert column: centred in the flat part of the ledge (outside the chamfer)
INS_X = (LEDGE_X0 + (WALL_X0 - CHAMFER))/2;
GRID_Y = [for (i = [0:GRID_N-1]) GRID_Y0 + i*GRID_P];


// ---------------- rounding ----------------
R_PLATE = 4;     // top-outer corner of the front plate
C_PLATE = 3;     // bottom-outer chamfer of the front plate
R_WALL_TOP = 1.5;// top edges of the side wall
R_WALL_REAR = 8; // top-rear corner of the side wall
R_LEDGE = 5;     // plan corners at the ends of the ledge

// plate seen from the front (X right, Z up) - drawn in XZ, extruded along -Y
module plate_profile() {
    x0 = WALL_X0; x1 = PLATE_X1; c = C_PLATE; r = R_PLATE;
    hull() {
        translate([x0, ZB]) square([x1 - x0 - c, H - r]);
        translate([x0, ZB + c]) square([x1 - x0, H - r - c]);
        translate([x0, ZT - r]) square([0.01, r]);
        translate([x1 - r, ZT - r]) circle(r=r);
    }
}
// wall cross-section (X right, Z up) with rounded top edges
module wall_xz() {
    r = R_WALL_TOP;
    hull() {
        translate([WALL_X0, ZB]) square([WALL_T, H - r]);
        translate([WALL_X0 + r, ZT - r]) circle(r=r);
        translate([WALL_X0 + WALL_T - r, ZT - r]) circle(r=r);
    }
}
// wall side view (Y right, Z up) with the top-rear corner rounded
module wall_yz() {
    r = R_WALL_REAR;
    hull() {
        translate([-PLATE_T, ZB]) square([DEPTH + PLATE_T, H - r]);
        translate([-PLATE_T, ZB]) square([DEPTH + PLATE_T - r, H]);
        translate([DEPTH - r, ZT - r]) circle(r=r);
    }
}
// ledge plan (X right, Y back) with rounded inner corners at both ends
module ledge_xy() {
    r = R_LEDGE;
    hull() {
        translate([WALL_X0 - eps, -PLATE_T]) square([eps + 0.01, DEPTH + PLATE_T]);
        translate([LEDGE_X0 + r, -PLATE_T + r]) circle(r=r);
        translate([LEDGE_X0 + r, DEPTH - r]) circle(r=r);
        translate([WALL_X0 - 1, -PLATE_T]) square([1, DEPTH + PLATE_T]);
    }
}

// ---------------- the ear (built as the RIGHT ear, +X) ----------------
module ear_right() {
    difference() {
        union() {
            // front plate: rounded top-outer corner, 45 deg chamfer at the
            // bottom-outer corner (prints cleanly on the bed)
            translate([0, 0, 0]) rotate([90, 0, 0]) translate([0, 0, -eps])
                linear_extrude(PLATE_T + eps) plate_profile();
            // side wall: rounded top edges along its length, rounded top-rear corner
            intersection() {
                translate([0, DEPTH, 0]) rotate([90, 0, 0]) linear_extrude(DEPTH + PLATE_T)
                    wall_xz();
                translate([WALL_X0 - 1, 0, 0]) rotate([90, 0, 90]) linear_extrude(WALL_T + 2)
                    wall_yz();
            }
            // ledge: rounded corners in plan at the front and rear inner ends
            translate([0, 0, ZB]) linear_extrude(LEDGE_T) ledge_xy();
            // 45 deg chamfer in the ledge / wall corner (stops short of the rear rounding)
            translate([WALL_X0 + eps, -PLATE_T, LEDGE_TOP - eps]) rotate([-90, 0, 0])
                linear_extrude(DEPTH + PLATE_T)
                    polygon([[0, 0], [-CHAMFER, 0], [0, -CHAMFER]]);
            // pull tab between the rail screws (optional)
            if (TAB) translate([WALL_X0 + 1, -PLATE_T - 12, ZB + 14]) cube([WALL_T - 2, 12 + eps, 16]);
        }
        // elephant-foot chamfer along the ledge's inner bottom edge
        translate([LEDGE_X0 - eps, -PLATE_T - 1, ZB - eps]) rotate([-90, 0, 0])
            linear_extrude(DEPTH + PLATE_T + 2) polygon([[0, 0], [EF_CHAMFER + eps, 0], [0, -(EF_CHAMFER + eps)]]);
        // rail slots (sideways, +-1.85 mm)
        for (z = RAIL_HZ) hull() for (dx = [-1, 1]*(RAIL_SLOT[0] - RAIL_SLOT[1])/2)
            translate([RAIL_HX + dx, -PLATE_T - 1, z]) rotate([-90, 0, 0])
                cylinder(d=RAIL_SLOT[1], h=PLATE_T + 2);
        // finger hole in the tab
        if (TAB) translate([WALL_X0 + WALL_T/2, -PLATE_T - 6.5, ZB + 13]) cylinder(d=5.5, h=18);
        // vertical M3 heat-set insert holes in the ledge, with a small lead-in
        for (y = GRID_Y) translate([INS_X, y, LEDGE_TOP - INS_DEPTH]) {
            cylinder(d=INS_D, h=INS_DEPTH + eps);
            translate([0, 0, INS_DEPTH - 0.6]) cylinder(d1=INS_D, d2=INS_D + 1.2, h=0.6 + eps);
        }
        // lighten the wall: rounded windows between the chamfer and a 7 mm top chord
        if (LIGHTEN) for (y = [12 : 30 : DEPTH - 30]) {
            zlo = LEDGE_TOP + CHAMFER + 3; zhi = ZT - 7; r = 4;
            hull() for (yy = [y + r, y + 22 - r], zz = [zlo + r, zhi - r])
                translate([WALL_X0 - 1, yy, zz]) rotate([0, 90, 0]) cylinder(r=r, h=WALL_T + 2);
        }
        // grid numbers on the ledge edge? -> engraved index marks every 30 mm
        for (y = [GRID_Y0 : 2*GRID_P : GRID_Y0 + (GRID_N-1)*GRID_P])
            translate([LEDGE_X0 - eps, y - 0.4, LEDGE_TOP - 1.2]) cube([0.8, 0.8, 1.2 + eps]);
    }
}

module ear(side) {
    difference() {
        if (side > 0) ear_right(); else mirror([1, 0, 0]) ear_right();
        // engraved L / R on the front of the plate (reads correctly on both)
        translate([side*((WALL_X0 + PLATE_X1)/2 + 7), -PLATE_T + 0.6, ZB + H/2]) rotate([90, 0, 0])
            linear_extrude(0.6 + eps) text(side > 0 ? "R" : "L", size=7, halign="center", valign="center");
    }
}

// =====================================================================
//  HARNESS INTERFACE - how any device harness sits on the ledges
// =====================================================================
// A plain bar that rests on the ear ledge (and, at its other end, on the
// spine ledge - same profile, mirrored). It drops to full thickness between
// the ledges and steps up over each ledge, with a bevel that clears the
// chamfer. Two M3 countersunk screws per end go into the ledge inserts.
BAR_W      = 30;     // bar width (two grid positions = two screws per end)
BAR_TOP    = ZB + 7.35;   // top of the bar = device seat (7.85)
BAR_GAP    = 0.3;    // clearance to the ledge edge
BAR_BEVEL_GAP = 0.5; // clearance to the chamfer
M3_CLR     = 3.4;
M3_CSK     = 7.0;    // countersink head diameter (fits ISO 10642 and DIN 7991 flush; M3 x 6 MAX length)

// XZ profile of the right end of a bar, from x_in out to the ear
module bar_end_profile(x_in) {
    step_x  = LEDGE_X0 - BAR_GAP;                         // inner step face
    bev_x0  = WALL_X0 - CHAMFER - BAR_BEVEL_GAP*1.41;     // bevel at ledge top
    bev_x1  = bev_x0 + (BAR_TOP - LEDGE_TOP);             // bevel at bar top
    polygon([[x_in, ZB], [step_x - EF_CHAMFER, ZB], [step_x, ZB + EF_CHAMFER], [step_x, LEDGE_TOP],
             [bev_x0, LEDGE_TOP], [bev_x1, BAR_TOP], [x_in, BAR_TOP]]);
}

// bar spanning from x_in to the right ear; y0 = first grid position used
module harness_bar_right(x_in, y0) {
    yc = y0 + GRID_P/2;
    difference() {
        translate([0, yc + BAR_W/2, 0]) rotate([90, 0, 0])
            linear_extrude(BAR_W) bar_end_profile(x_in);
        for (y = [y0, y0 + GRID_P]) translate([INS_X, y, LEDGE_TOP - eps]) {
            cylinder(d=M3_CLR, h=BAR_TOP - LEDGE_TOP + 2*eps);
            translate([0, 0, BAR_TOP - LEDGE_TOP - (M3_CSK - M3_CLR)/2 + 2*eps])
                cylinder(d1=M3_CLR, d2=M3_CSK, h=(M3_CSK - M3_CLR)/2);
        }
    }
}

// context: brass inserts and M3 countersunk screws
module inserts_screws_right(y0, lift=0) {
    for (y = [y0, y0 + GRID_P]) {
        color("goldenrod") translate([INS_X, y, LEDGE_TOP - 3]) difference() {
            cylinder(d=4.4, h=3); translate([0,0,-1]) cylinder(d=3, h=5); }
        color("dimgray") translate([INS_X, y, BAR_TOP + lift]) mirror([0,0,1]) {
            cylinder(d1=M3_CSK - 0.2, d2=3, h=1.7); cylinder(d=3, h=6); }   // M3 x 6 flat head
    }
}

// spine-side constants (the spine's outer face mirrors the ear's inner face)
SPINE_FACE = 17.5;                                   // spine wall outer face (|x|)
S_LEDGE_X1 = SPINE_FACE + LEDGE_W;                   // spine ledge edge
S_INS_X    = SPINE_FACE + CHAMFER + (LEDGE_W - CHAMFER)/2;   // spine insert column (|x|)

// chamfer-clearing x at the bar top on each side, and the centre of a half
EAR_BEV_TOP   = WALL_X0 - CHAMFER - BAR_BEVEL_GAP*1.41 + (BAR_TOP - LEDGE_TOP);
SPINE_BEV_TOP = SPINE_FACE + CHAMFER + BAR_BEVEL_GAP*1.41 - (BAR_TOP - LEDGE_TOP);
HALF_CX = (SPINE_BEV_TOP + EAR_BEV_TOP)/2;   // centre line of the right half (= 115.75)

// XZ profile of a full-span harness bar: steps up onto the spine ledge and the ear ledge
module span_profile() {
    s_step = S_LEDGE_X1 + BAR_GAP;   s_bev = SPINE_FACE + CHAMFER + BAR_BEVEL_GAP*1.41;
    e_step = LEDGE_X0 - BAR_GAP;     e_bev = WALL_X0 - CHAMFER - BAR_BEVEL_GAP*1.41;
    c = EF_CHAMFER;
    polygon([[SPINE_BEV_TOP, BAR_TOP], [s_bev, LEDGE_TOP], [s_step, LEDGE_TOP], [s_step, ZB + c], [s_step + c, ZB],
             [e_step - c, ZB], [e_step, ZB + c], [e_step, LEDGE_TOP], [e_bev, LEDGE_TOP], [EAR_BEV_TOP, BAR_TOP]]);
}

// harness body: give it a 2D PLAN (children) of the frame for the RIGHT half.
// Result = plan extruded with a chamfered top edge, cut by the span profile,
// so every bar that reaches the ledges gets the correct stepped ends.
module harness_body() {
    intersection() {
        minkowski() {
            translate([0, 0, ZB - 1]) linear_extrude(BAR_TOP - ZB + 1 - TOP_CHAMFER) offset(delta=-TOP_CHAMFER) children();
            cylinder(r1=TOP_CHAMFER, r2=0, h=TOP_CHAMFER, $fn=8);
        }
        translate([0, 400, 0]) rotate([90, 0, 0]) linear_extrude(420) span_profile();
    }
}

// M3 countersunk holes for bars centred at y = each value in ROWS:
// two screws per bar end (grid positions y-7.5 / y+7.5), on BOTH ledges.
// Rows must be centred between two grid positions: 22.5, 37.5, 52.5 ... 142.5
module ledge_m3_holes(rows) {
    for (yr = rows, x = [INS_X, S_INS_X], dy = [-GRID_P/2, GRID_P/2])
        translate([x, yr + dy, LEDGE_TOP - eps]) {
            cylinder(d=M3_CLR, h=BAR_TOP - LEDGE_TOP + 2*eps);
            translate([0, 0, BAR_TOP - LEDGE_TOP - (M3_CSK - M3_CLR)/2 + 2*eps])
                cylinder(d1=M3_CLR, d2=M3_CSK, h=(M3_CSK - M3_CLR)/2);
        }
}

// place a RIGHT-half harness in either half. Harnesses are symmetric about
// HALF_CX, so the left half gets the same part SHIFTED (not mirrored).
module in_half(side) { if (side > 0) children(); else translate([-2*HALF_CX, 0, 0]) children(); }

// rounded rectangle block
module rounded_box(w, d, h, r) {
    rr = min(r, min(w, d)/2 - 0.3);
    linear_extrude(h) offset(r=rr) offset(delta=-rr) square([w, d]);
}

// usable space per half (for device design)
HALF_W_WALLS   = WALL_X0 - SPINE_FACE;          // 196.5 wall to wall
HALF_W_SEAT    = EAR_BEV_TOP - SPINE_BEV_TOP;   // ~191 between chamfers at the device seat
HALF_W_LEDGES  = LEDGE_X0 - S_LEDGE_X1;         // 160.5 between the ledge edges


// =====================================================================
//  SPINES (middle connector) - knuckle joint, #9 x 2-1/2" deck screws
// =====================================================================
J_Y0     = 10;     // joint zone front
J_SEGS   = 8;      // 4 knuckles per half (left = even, right = odd)
J_SEG_L  = 17.5;   // -> joint zone 10..150
KN       = 7;      // knuckles reach past the centre line
GAP_FACE = 0.3;    // knuckle-to-knuckle (tested)
GAP_TIP  = 0.5;    // knuckle tip to the other spine (tested)
KN_CHAMFER = 1.0;  // lead-in on knuckle tips
KN_FILLET  = 1.5;
SCREW_L    = 63.5;
SCREW_CLR  = 5.2;  // tested
SCREW_PIL  = 3.6;  // tested
SCREW_HEAD = 9.5;
ROW_Z      = [10.5, 33.95];
SP_X0      = KN + GAP_TIP;        // 7.5 spine inner face
SP_LEN0    = 0;                   // spine wall + ledge from y = 0 ...
SP_LEN1    = 160;                 // ... to y = 160 (matches the ear)
J_Y1       = J_Y0 + J_SEGS*J_SEG_L;

function seg_mine(side, i) = (side < 0) ? (i % 2 == 0) : (i % 2 == 1);

module hole_y(d, l) {   // horizontal hole along +Y, flat teardrop roof
    rotate([-90, 0, 0]) linear_extrude(l)
        hull() { circle(d=d); translate([-d*0.2, -d*0.6]) square([d*0.4, 0.01]); }
}

// spine wall + knuckles in plan (XY), built for any side
module spine_plan(side) {
    // wall from the inner face to the standard outer face
    translate([side > 0 ? SP_X0 : -SPINE_FACE, SP_LEN0]) square([SPINE_FACE - SP_X0, SP_LEN1 - SP_LEN0]);
    for (i = [0:J_SEGS-1]) if (seg_mine(side, i)) {
        y0 = J_Y0 + i*J_SEG_L + (i == 0 ? 0 : GAP_FACE/2);
        y1 = J_Y0 + (i+1)*J_SEG_L - (i == J_SEGS-1 ? 0 : GAP_FACE/2);
        c = KN_CHAMFER; tip = -side*KN; root = side*(SP_X0 + 1);
        polygon(side > 0
            ? [[tip, y0 + c], [tip + c, y0], [root, y0], [root, y1], [tip + c, y1], [tip, y1 - c]]
            : [[tip, y0 + c], [tip - c, y0], [root, y0], [root, y1], [tip - c, y1], [tip, y1 - c]]);
    }
}

// spine wall side view (Y, Z) with rounded top corners front and back
module spine_yz() {
    r = R_WALL_REAR;
    hull() {
        translate([SP_LEN0, ZB]) square([SP_LEN1 - SP_LEN0, H - r]);
        translate([SP_LEN0 + r, ZT - r]) circle(r=r);
        translate([SP_LEN1 - r, ZT - r]) circle(r=r);
    }
}

module spine(side) {
    s = side;
    difference() {
        union() {
            // wall + knuckles, top corners rounded in side view
            intersection() {
                translate([0, 0, ZB]) linear_extrude(H) offset(r=-KN_FILLET) offset(delta=KN_FILLET) spine_plan(side);
                translate([-50, 0, 0]) rotate([90, 0, 90]) linear_extrude(100) spine_yz();
            }
            // ledge on the outer face (mirror of the ear ledge), rounded plan ends
            translate([0, 0, ZB]) linear_extrude(LEDGE_T) hull() {
                translate([s > 0 ? SPINE_FACE - 1 : -SPINE_FACE, SP_LEN0]) square([1, SP_LEN1 - SP_LEN0]);
                translate([s*(S_LEDGE_X1 - R_LEDGE), SP_LEN0 + R_LEDGE]) circle(r=R_LEDGE);
                translate([s*(S_LEDGE_X1 - R_LEDGE), SP_LEN1 - R_LEDGE]) circle(r=R_LEDGE);
            }
            // 45 deg chamfer in the ledge / wall corner
            translate([s*SPINE_FACE, SP_LEN1, LEDGE_TOP - eps]) rotate([90, 0, 0]) linear_extrude(SP_LEN1 - SP_LEN0)
                polygon(s > 0 ? [[-eps, 0], [CHAMFER, 0], [-eps, CHAMFER]] : [[eps, 0], [-CHAMFER, 0], [eps, CHAMFER]]);
        }
        // deck-screw rows: clearance in the end knuckles, pilot in the middle
        for (z = ROW_Z) {
            translate([0, J_Y0 - eps, z]) hole_y(SCREW_PIL, J_Y1 - J_Y0 + 2*eps);
            translate([0, J_Y0 - eps, z]) hole_y(SCREW_CLR, J_SEG_L + eps);
            translate([0, J_Y1 - J_SEG_L, z]) hole_y(SCREW_CLR, J_SEG_L + eps);
            translate([0, J_Y0 - eps, z]) rotate([-90, 0, 0]) cylinder(d1=SCREW_HEAD, d2=SCREW_CLR, h=(SCREW_HEAD - SCREW_CLR)/2);
            translate([0, J_Y1 + eps, z]) rotate([90, 0, 0]) cylinder(d1=SCREW_HEAD, d2=SCREW_CLR, h=(SCREW_HEAD - SCREW_CLR)/2);
        }
        // M3 insert grid in the ledge (through, like the ear)
        for (y = GRID_Y) translate([s*S_INS_X, y, LEDGE_TOP - INS_DEPTH]) {
            cylinder(d=INS_D, h=INS_DEPTH + eps);
            translate([0, 0, INS_DEPTH - 0.6]) cylinder(d1=INS_D, d2=INS_D + 1.2, h=0.6 + eps);
        }
        // elephant-foot chamfer on the ledge outer bottom edge
        translate([s*S_LEDGE_X1, SP_LEN0 - 1, ZB - eps]) rotate([-90, 0, 0]) linear_extrude(SP_LEN1 - SP_LEN0 + 2)
            polygon(s > 0 ? [[eps, 0], [-(EF_CHAMFER + eps), 0], [eps, -(EF_CHAMFER + eps)]]
                          : [[-eps, 0], [EF_CHAMFER + eps, 0], [-eps, -(EF_CHAMFER + eps)]]);
        // index marks every 30 mm on the ledge edge
        for (y = [GRID_Y0 : 2*GRID_P : GRID_Y0 + (GRID_N-1)*GRID_P])
            translate([s > 0 ? S_LEDGE_X1 - 0.8 + eps : -S_LEDGE_X1 - eps, y - 0.4, LEDGE_TOP - 1.2]) cube([0.8, 0.8, 1.2 + eps]);
        // engraved L / R on top of the wall
        translate([s*(SP_X0 + SPINE_FACE)/2, SP_LEN1 - 22, ZT - 0.6]) linear_extrude(1)
            rotate(90) text(s > 0 ? "R" : "L", size=6, halign="center", valign="center");
    }
}

// the two deck screws per row, for previews
module deck_screws() {
    color("dimgray") for (z = ROW_Z) {
        translate([0, J_Y0, z]) rotate([-90, 0, 0]) { cylinder(d1=SCREW_HEAD - 0.5, d2=4.5, h=2.2); cylinder(d=4.5, h=SCREW_L - 4); translate([0, 0, SCREW_L - 4]) cylinder(d1=4.5, d2=0.5, h=4); }
        translate([0, J_Y1, z]) rotate([90, 0, 0])  { cylinder(d1=SCREW_HEAD - 0.5, d2=4.5, h=2.2); cylinder(d=4.5, h=SCREW_L - 4); translate([0, 0, SCREW_L - 4]) cylinder(d1=4.5, d2=0.5, h=4); }
    }
}
