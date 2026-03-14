/*
 * Artifact — Label Placard Holder
 * =================================
 * Wall-mounted holder for 6"×3" (152.4mm × 76.2mm) printed labels.
 * Label slots in from the side (along Z) and rests on the 45° face.
 *
 * Coordinate system:
 *   X = depth from wall (0 = wall face, ramp = furthest point)
 *   Y = height          (0 = bottom, ramp = top)
 *   Z = length          (0 to holder_l, along the label's width)
 *
 * Mounting: two countersunk screws through the back face (X=0) into wall.
 *
 * Print: PLA/PETG, 20% infill, back face (X=0) flat on the bed, no supports.
 */

$fn = 60;

// ── Parameters ───────────────────────────────────────────────────────────────

label_w     = 152.4;  // label width (6 inches)
ramp        = 52;     // triangle leg — depth from wall and height (mm)
holder_l    = label_w + 22;  // total Z length (11mm overhang each end)

slot_t      = 2.5;   // slot opening thickness (cardstock ~0.5mm; laminate ~1.2mm)
slot_d      = 12;    // slot depth — must stay below: slot_pos (currently safe at 12<20)
slot_pos    = 20;    // distance along 45° face from lower tip to slot center
                      // increasing this moves the slot up the face

screw_d     = 3.5;   // screw shank diameter
cbore_d     = 7.5;   // countersink (screw head) diameter
cbore_h     = 3.5;   // countersink depth
screw_inset = 20;    // screw hole inset from each end

nfc_d       = 31;    // NFC recess diameter (30mm chip + clearance)
nfc_depth   = 1.2;   // NFC recess depth
nfc_face_pos = slot_pos + 9;  // along face from tip — lands in label's tap strip
nfc_z_from_end = 31; // from right end of holder — aligns with TAP circle on label

// ── Derived ──────────────────────────────────────────────────────────────────

s2 = 1 / sqrt(2);

// ── Assembly ─────────────────────────────────────────────────────────────────

difference() {
    body();
    label_slot();
    screw_holes();
    nfc_pocket();
}

// ── Body ─────────────────────────────────────────────────────────────────────
//
//   Y (height)
//   |
//   * [0, ramp]   ← wall, top
//   |\
//   | \           ← 45° face: label rests here
//   |  \
//   *───* ← [0,0] wall/floor     [ramp,0] front tip
//
//   Extruded along Z (label length direction).

module body() {
    linear_extrude(holder_l) {
        polygon([[0, 0], [ramp, 0], [0, ramp]]);
    }
}

// ── Label slot ───────────────────────────────────────────────────────────────
//
// A thin groove cut into the 45° face, running the full Z length.
// The label slides in from either end along Z.
//
// Method: translate to the slot center on the 45° face, rotate 135° around Z
// so that the cube's local +Y axis points in the inward face-normal direction
// [-s2, -s2, 0], then cut a cube of [slot_t × slot_d × holder_l].
//
//   rotate([0,0,135]):
//     local +X → world [-s2, +s2, 0]  (along face direction)
//     local +Y → world [-s2, -s2, 0]  (INTO body — inward normal ✓)

module label_slot() {
    // Center of slot on the 45° face in XY:
    cx = ramp - slot_pos * s2;   // ≈ 37.86 with defaults
    cy = slot_pos * s2;          // ≈ 14.14 with defaults

    translate([cx, cy, -1])
    rotate([0, 0, 135])
    translate([-slot_t / 2, -0.1, 0])  // center width; -0.1 ensures clean face cut
    cube([slot_t, slot_d + 0.1, holder_l + 2]);
}

// ── Screw holes ──────────────────────────────────────────────────────────────
//
// Countersunk holes in the back face (X=0).
// rotate([0, 90, 0]) → cylinder axis goes along +X (into the body).

module screw_holes() {
    screw_y = ramp * 0.42;
    for (z_pos = [screw_inset, holder_l - screw_inset]) {
        translate([-1, screw_y, z_pos])
        rotate([0, 90, 0]) {
            cylinder(d = screw_d, h = ramp * 0.6 + 2);
            cylinder(d = cbore_d, h = cbore_h + 1);
        }
    }
}

// ── NFC pocket ───────────────────────────────────────────────────────────────
//
// Circular recess on the 45° face. Same rotation as the slot (135° around Z),
// then tilt the cylinder to go along the inward normal (+Y local = inward).
// rotate([-90, 0, 0]) tilts the cylinder from +Z to +Y (local coords).

module nfc_pocket() {
    cx = ramp - nfc_face_pos * s2;
    cy = nfc_face_pos * s2;
    z_pos = holder_l - nfc_z_from_end;

    translate([cx, cy, z_pos])
    rotate([0, 0, 135])
    rotate([-90, 0, 0])
    translate([0, 0, -0.1])  // start slightly outside face for clean cut
    cylinder(d = nfc_d, h = nfc_depth + 0.2);
}
