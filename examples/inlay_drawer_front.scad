/*
DeskWare Next - examples/inlay_drawer_front.scad

Multi-color drawer fronts: a front panel with DRAWER_FRONT_RECESS enabled
(printed face-down, so no dovetail keys - glue it to the drawer box) plus
the matching printable inlay plate, floating above its pocket here. Print
the inlay in a contrast color, or use the recess for veneer, cork, or any
sheet material.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

include <../deskware-next.scad>

UNITS = 1;

panel_w = drawer_outside_width(PLATE_WIDTH, RISER_WIDTH) + RISER_WIDTH - DRAWER_FRONT_LATERAL_CLEARANCE*2;
panel_h = drawer_height(UNITS, SLIDE_SEPARATION, DRAWER_VERTICAL_CLEARANCE);
//pocket dimensions from drawer_front's recess, minus a drop-in fit
inlay_w = panel_w - DRAWER_FRONT_CHAMFER*2 - DRAWER_FRONT_RECESS_INSET*2 - CLEARANCE*2;
inlay_h = panel_h - DRAWER_FRONT_CHAMFER*2 - DRAWER_FRONT_RECESS_INSET*2 - CLEARANCE*2;

//the recessed front, as printed (face down, recess up)
drawer_front(height_units = UNITS, recess = true, orient = DOWN, anchor = TOP);

//the inlay plate, hovering over its pocket
up(DRAWER_FRONT_THICKNESS + 8)
    color("#00cf30")
    cuboid([inlay_w, inlay_h, DRAWER_FRONT_RECESS_DEPTH], anchor=BOT);
