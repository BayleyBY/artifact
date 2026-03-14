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
 *
 * NFC chip:
 *   A circular recess in the 45° face holds the NFC sticker flush.
 *   The label slides in front of it; the printed TAP circle aligns over it.
 *   Chip diameter: 30mm. Recess is 31mm wide × 1mm deep.
 *   Recess is positioned at the right end of the holder (see nfc_pocket below).
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

nfc_d          = 31;     // NFC recess diameter (30mm chip + 0.5mm clearance)
nfc_depth      = 1.2;    // recess depth (NFC stickers are ~0.4-0.8mm thick)
// NFC pocket position on the 45° face:
//   Along the face (from slot/label bottom edge): ~9mm up  ← center of tap strip
//   Along Y (from right end of label): ~22mm in           ← right side of tap zone
nfc_face_pos   = slot_from_tip + 9;   // mm along 45° face from lower tip
nfc_y_from_end = 22;                  // mm from the right end of the holder


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
    nfc_pocket();
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


// ── NFC pocket ───────────────────────────────────────────────────────────────
//
// Circular recess in the 45° face sized for the 30mm NFC sticker.
// The label slides in front of it, hiding the chip.
// The printed TAP circle on the label should align over this pocket.
//
// Position:
//   nfc_face_pos mm along the 45° face from the lower tip  (matches tap strip height)
//   nfc_y_from_end mm from the right end of the holder     (matches tap circle X)
//
// If alignment is off after printing, adjust nfc_face_pos and nfc_y_from_end.

module nfc_pocket() {
    // Center on 45° face in XZ:
    nfc_cx = ramp - nfc_face_pos * inv_sqrt2;
    nfc_cz = nfc_face_pos * inv_sqrt2;

    // Y position: right end of holder minus offset
    nfc_y = holder_l - nfc_y_from_end;

    translate([nfc_cx, nfc_y, nfc_cz])
    rotate([0, 135, 0])          // same inward-normal rotation as the slot
    rotate([0, 0, 0])
    cylinder(d = nfc_d, h = nfc_depth + 0.1);
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
