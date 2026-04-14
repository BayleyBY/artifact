/*
 * Artifact — Label Placard Holder
 * =================================
 * Wall-mounted holder for 6"×3" (152.4mm × 76.2mm) printed labels.
 * Label face sits at 35° from the wall. Label slides in from either end.
 * 30mm NFC chip recess on the label face.
 *
 * Coordinate system:
 *   X = depth from wall  (0 = wall surface)
 *   Y = height           (0 = bottom)
 *   Z = length           (label slides along this axis)
 *
 * Print: PLA/PETG, 20% infill, back face (X=0) flat on bed, no supports needed.
 * Mount: 2× wood screws or M3.5 through the back face.
 */

$fn = 60;

// ── Parameters ───────────────────────────────────────────────────────────────

label_w  = 127.0;  // 5 inches
tilt     = 35;     // degrees from vertical (wall) — label leans at this angle

holder_l = label_w + 20;  // Z length — label has 10mm overhang each side

plate_t  = 8;   // wall plate thickness (X)
arm_h    = 85;  // arm face length (mm along the face itself)

slot_t   = 1.5;  // slot opening thickness — tight fit for cardstock
slot_d   = 10;   // slot depth into body

screw_d  = 3.5;
cbore_d  = 7.5;
cbore_h  = 3.5;

nfc_d    = 31;   // NFC recess diameter (30mm chip + 0.5mm clearance)
nfc_dep  = 1.5;  // NFC recess depth

// NFC position:
nfc_along = 25;         // mm up the arm face from the bottom
nfc_z     = holder_l - 30;  // mm from Z=0 end (right side of label when mounted)

// ── Derived ──────────────────────────────────────────────────────────────────

s = sin(tilt);   // sin 35° ≈ 0.574
c = cos(tilt);   // cos 35° ≈ 0.819

body_h = arm_h * c;  // total height of holder

// ── Body cross-section (XY polygon, extruded along Z) ────────────────────────
//
// Viewed from the end:
//
//   Y (height)
//   |
//   *──────────────* [arm_h*s + plate_t, arm_h*c]   ← arm top
//   |              /
//   |             /  ← arm face at 35° from vertical (label rests here)
//   |            /
//   |           /
//   *──────────* [plate_t, 0]  ← bottom of arm face / front of wall plate
//   [0,0]
//
//   Back face (X=0): mounts flush to wall
//   Bottom (Y=0): horizontal floor of holder
//   Arm face: angled at 35° — this is where the label rests

module body() {
    linear_extrude(holder_l) {
        polygon([
            [0,              0      ],   // back-bottom
            [plate_t,        0      ],   // front-bottom (wall plate edge)
            [plate_t + arm_h*s, arm_h*c],   // arm top-front
            [0,              arm_h*c]    // back-top
        ]);
    }
}

// ── Label slot ───────────────────────────────────────────────────────────────
//
// A thin channel cut along the full Z length at the base of the arm face.
// The label's bottom edge slides into this channel from either end.
//
// The slot center is `slot_from_base` mm up the arm face from its bottom corner.
// Direction of cut: perpendicular to arm face = inward normal [-c, s, 0] in XY.
//
// We define the slot as a cube in the arm face's local coordinate frame:
//   - Local "depth" axis (into body):  [-c, s] in XY  → rotate 90°+tilt from X
//   - Local "width" axis (along face): [ s, c] in XY
//   - Local "length" axis:             Z (unchanged)
//
// rotate([0, 0, 90+tilt]) then rotate([0, 90, 0]) aligns local Z with inward [-c,s,0]

slot_from_base = 5;  // mm up the arm face from its bottom corner [plate_t, 0]

module label_slot() {
    // Center of slot on the arm face in XY:
    cx = plate_t + slot_from_base * s;
    cy =           slot_from_base * c;

    // Small outward nudge so the cutter cleanly breaks through the face:
    ox = 0.1 * c;
    oy = -0.1 * s;

    translate([cx + ox, cy + oy, -1])
    rotate([0, 0, 90 + tilt])   // align local Y with face direction [s, c]
    rotate([0, 90, 0])          // local Z → local X (depth axis = inward normal)
    translate([-slot_d, -slot_t/2, 0])
    cube([slot_d + 0.1, slot_t, holder_l + 2]);
}

// ── NFC recess ───────────────────────────────────────────────────────────────
//
// Circular pocket on the arm face. Same rotation as the slot.
// Placed at nfc_along mm up the face and nfc_z along Z.

module nfc_recess() {
    cx = plate_t + nfc_along * s;
    cy =           nfc_along * c;

    ox = 0.1 * c;
    oy = -0.1 * s;

    translate([cx + ox, cy + oy, nfc_z])
    rotate([0, 0, 90 + tilt])
    rotate([0, 90, 0])
    translate([0, 0, -0.1])
    cylinder(d = nfc_d, h = nfc_dep + 0.2);
}

// ── Screw holes ──────────────────────────────────────────────────────────────
//
// Two countersunk holes through the back face (X=0), one near each Z end.
// rotate([0, 90, 0]) → cylinder axis along +X (into the body toward the wall).

module screw_holes() {
    screw_y = body_h * 0.5;  // midpoint of back face height

    for (z_pos = [20, holder_l - 20]) {
        translate([-1, screw_y, z_pos])
        rotate([0, 90, 0]) {
            cylinder(d = screw_d, h = plate_t + 2);   // through hole
            cylinder(d = cbore_d, h = cbore_h + 1);   // countersink
        }
    }
}

// ── Assembly ─────────────────────────────────────────────────────────────────

difference() {
    body();
    label_slot();
    nfc_recess();
    screw_holes();
}
