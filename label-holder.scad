/*
 * Artifact — Label Placard Holder
 * =================================
 * Wall-mounted holder for 6"×3" (152.4mm × 76.2mm) printed labels.
 * Label slots in from the side and rests on the 45° face — no screws,
 * no clips, just gravity and friction.
 *
 * Coordinate system (important for modifications):
 *   X = depth from wall (0 = wall, ramp = furthest from wall)
 *   Y = height           (0 = bottom, ramp = top)
 *   Z = length           (along label width, 0 to holder_l)
 *
 * Mounting: two countersunk screws through the back face (X=0) into wall.
 *
 * NFC chip:
 *   31mm circular recess on the 45° face (fits 30mm sticker).
 *   Label slides in front, printed TAP circle aligns over the chip.
 *   Adjust nfc_face_pos and nfc_z_from_end after first test print.
 *
 * Print settings:
 *   - PLA or PETG, 20% infill
 *   - Place back face (X=0) flat on the print bed
 *   - No supports needed
 */

$fn = 60;

// ── Parameters ───────────────────────────────────────────────────────────────

label_w        = 152.4;       // label width (6 inches)

ramp           = 52;          // triangle leg — controls depth & height of holder
                               // 52mm ≈ 2"; the face diagonal is ramp×√2 ≈ 73.5mm

holder_l       = label_w + 22;// total Z length (11mm overhang each side of label)

slot_t         = 2.2;         // slot thickness (cardstock fits at ~0.5mm; laminate ~1.2mm)
slot_d         = 12;          // slot depth into body
                               // must be < slot_pos (or the slot cuts through the bottom face)
slot_pos       = 20;          // mm along 45° face from lower tip [ramp,0] to slot center
                               // at slot_pos=20, body depth at that point is ~20mm — slot_d=12 fits safely
                               // smaller → label tips further forward; don't go below ~18

screw_d        = 3.5;         // screw shank diameter (M3.5 or #6 wood screw)
cbore_d        = 7.5;         // counterbore diameter (screw head sits flush)
cbore_h        = 3.5;         // counterbore depth
screw_inset    = 20;          // screw hole distance from each end

nfc_d          = 31;          // NFC recess diameter (30mm chip + 0.5mm clearance)
nfc_depth      = 1.2;         // recess depth (stickers are ~0.4–0.8mm)
nfc_face_pos   = slot_pos + 9;// mm along face from tip — places pocket in bottom label strip
nfc_z_from_end = 31;          // mm from right end of holder — aligns with TAP circle


// ── Derived ──────────────────────────────────────────────────────────────────

s2 = 1 / sqrt(2);            // 1/√2 ≈ 0.7071

// 45° face geometry (in XY plane):
//   Face runs from [ramp, 0] (front-bottom tip) to [0, ramp] (back-top corner)
//   Along-face unit vector:  fd = [-s2,  s2]
//   Inward-normal unit vector: nd = [-s2, -s2]  (pointing toward origin = into body)


// ── Assembly ─────────────────────────────────────────────────────────────────

difference() {
    body();
    label_slot();
    screw_holes();
    nfc_pocket();
}


// ── Body ─────────────────────────────────────────────────────────────────────
//
//  Y (height)
//  |
//  * [0, ramp]   ← back-top, against wall at top
//  |\
//  | \           ← 45° face: label rests here
//  |  \
//  |   \
//  *────* ← [0,0] back-bottom (wall/floor)   [ramp,0] front-bottom tip
//
//  linear_extrude goes along Z (label width direction)

module body() {
    linear_extrude(holder_l) {
        polygon([
            [0,    0   ],   // back-bottom
            [ramp, 0   ],   // front-bottom tip
            [0,    ramp]    // back-top
        ]);
    }
}


// ── Label slot ───────────────────────────────────────────────────────────────
//
// A thin groove perpendicular to the 45° face, extruded full Z length.
// Defined as a 2D parallelogram in the XY plane, extruded along Z.
//
// Slot center on face:
//   cx = ramp - slot_pos * s2
//   cy = slot_pos * s2
//
// Four corners of the slot cross-section (XY):
//   Along-face (fd): [-s2,  s2]
//   Into-body (nd):  [-s2, -s2]
//   Half-thickness along fd: slot_t/2

module label_slot() {
    cx = ramp - slot_pos * s2;
    cy = slot_pos * s2;

    // unit vectors
    fdx =  -s2;  fdy =  s2;   // along face (toward back-top)
    ndx =  -s2;  ndy = -s2;   // into body  (inward normal)

    ht = slot_t / 2;

    translate([0, 0, -1])
    linear_extrude(holder_l + 2) {
        polygon([
            [cx + ht*fdx,            cy + ht*fdy           ],
            [cx - ht*fdx,            cy - ht*fdy           ],
            [cx - ht*fdx + slot_d*ndx, cy - ht*fdy + slot_d*ndy],
            [cx + ht*fdx + slot_d*ndx, cy + ht*fdy + slot_d*ndy]
        ]);
    }
}


// ── Screw holes ──────────────────────────────────────────────────────────────
//
// Countersunk holes in the back face (X=0), going in +X direction.
// rotate([0, 90, 0]) aligns the cylinder along +X.

module screw_holes() {
    screw_y = ramp * 0.42;   // height up the back face

    for (z_pos = [screw_inset, holder_l - screw_inset]) {
        translate([-1, screw_y, z_pos])
        rotate([0, 90, 0]) {
            cylinder(d = screw_d, h = ramp * 0.6 + 2);   // through hole
            cylinder(d = cbore_d, h = cbore_h + 1);       // countersink at face
        }
    }
}


// ── NFC pocket ───────────────────────────────────────────────────────────────
//
// Circular recess on the 45° face, perpendicular to the face.
// The cylinder axis is oriented along the inward face normal [-s2, -s2, 0].
//
// Rotation chain (applied inner-first):
//   1. rotate([0, 90, 0])   — cylinder (Z) → +X axis
//   2. rotate([0, 0, -135]) — +X rotates in XY to direction [-s2, -s2, 0] (inward normal)

module nfc_pocket() {
    cx = ramp - nfc_face_pos * s2;
    cy = nfc_face_pos * s2;
    z_pos = holder_l - nfc_z_from_end;

    // Tiny outward offset ensures the cutter starts just outside the face surface
    off = 0.2 * s2;

    translate([cx + off, cy + off, z_pos])
    rotate([0, 0, -135])
    rotate([0, 90, 0])
    cylinder(d = nfc_d, h = nfc_depth + 0.3);
}
