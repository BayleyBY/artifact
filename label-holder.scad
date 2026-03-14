/*
 * Artifact — Label Placard Holder
 * =================================
 * Wall-mounted holder for 6"×3" (152.4mm × 76.2mm) printed labels.
 * Label slots in from the side and rests on the 45° face — no screws,
 * no clips, just gravity and friction.
 *
 * Mounting: two countersunk screws through the back face into the wall.
 *
 * Print settings:
 *   - PLA or PETG
 *   - 20% infill
 *   - No supports needed (print with back face on the bed)
 *   - Layer height: 0.2mm
 */

$fn = 60;

// ── Parameters ───────────────────────────────────────────────────────────────

label_w        = 152.4;  // label width (6 inches)
// label_h     = 76.2    // label height (3 inches) — reference only

ramp           = 52;     // triangle leg size — controls depth/height of holder
                          // 52mm ≈ 2" — enough to support a 3" label at 45°

holder_l       = label_w + 22;  // total length (11mm overhang each side)

slot_thickness = 2.2;    // slot opening width — fits cardstock/laminate (~0.5-1mm)
                          // increase to 3.0 for heavier stock
slot_depth     = 16;     // how far into the body the slot cuts
slot_from_tip  = 14;     // mm along 45° face from lower tip to slot center
                          // (lower = label angles more steeply forward)

screw_d        = 3.5;    // screw shank diameter (M3.5 or #6 wood screw)
cbore_d        = 7.5;    // counterbore diameter (fits screw head flush)
cbore_h        = 3.5;    // counterbore depth
screw_inset    = 20;     // distance from ends to screw hole centers


// ── Derived values ────────────────────────────────────────────────────────────

inv_sqrt2 = 1 / sqrt(2);

// Slot center position on the 45° face in the XZ plane:
// The lower tip of the face is at [ramp, 0].
// Moving slot_from_tip along the face (unit dir: [-inv_sqrt2, inv_sqrt2]).
slot_cx = ramp - slot_from_tip * inv_sqrt2;
slot_cz = slot_from_tip * inv_sqrt2;


// ── Assembly ──────────────────────────────────────────────────────────────────

difference() {
    holder_body();
    label_slot();
    screw_holes();
}


// ── Body ──────────────────────────────────────────────────────────────────────
//
// Right-angle triangular prism viewed from the side:
//
//   Z (up)
//   |
//   *  ← back-top [0, ramp]        against wall, upper
//   |\
//   | \   ← 45° face (label rests here)
//   |  \
//   |   \
//   *────* ← [0,0] back-bottom     [ramp, 0] front-bottom
//           against wall, floor        ↑
//                                 holder protrudes this far from wall
//
// X=0 face: mounts flush to wall
// Z=0 face: faces down (bottom of holder)
// 45° face: hypotenuse, holds the label

module holder_body() {
    linear_extrude(holder_l) {
        polygon([
            [0,    0   ],   // back-bottom
            [ramp, 0   ],   // front-bottom
            [0,    ramp]    // back-top
        ]);
    }
}


// ── Label slot ────────────────────────────────────────────────────────────────
//
// A thin groove cut perpendicular to the 45° face, running the full Y length.
// The label slides in from either end.
//
// Rotation note: rotate([0, 135, 0]) aligns the local +Z with the inward
// normal of the 45° face (pointing from the face surface into the body).

module label_slot() {
    translate([slot_cx, -1, slot_cz])
    rotate([0, 135, 0])
    translate([-slot_thickness / 2, 0, 0])
    cube([slot_thickness, holder_l + 2, slot_depth]);
}


// ── Screw holes ───────────────────────────────────────────────────────────────
//
// Two countersunk holes through the back face (X=0) for wall mounting.
// rotate([0, 90, 0]) orients the cylinder along +X (into the body).

module screw_holes() {
    screw_z = ramp * 0.42;   // vertical position in back face

    for (y_pos = [screw_inset, holder_l - screw_inset]) {
        translate([-1, y_pos, screw_z])
        rotate([0, 90, 0]) {
            // Through hole
            cylinder(d = screw_d, h = ramp * 0.6 + 2);
            // Counterbore (recessed screw head)
            cylinder(d = cbore_d, h = cbore_h + 1);
        }
    }
}
