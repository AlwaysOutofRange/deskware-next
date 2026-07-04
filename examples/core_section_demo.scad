/*
DeskWare Next - examples/core_section_demo.scad

A complete assembled core section: two risers, backer, base plate, top
plate, and two 1-unit drawers with fronts and printed handles. Every
placement below derives from the config dimensions - change PLATE_WIDTH or
TOTAL_HEIGHT in config.scad and the whole assembly follows.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

include <../deskware-next.scad>

riser_h = core_section_height(TOTAL_HEIGHT, TOP_PLATE_THICKNESS, BASE_PLATE_THICKNESS);
riser_d = riser_depth(PLATE_DEPTH, RISER_SETBACK);
drawer_d = drawer_outside_depth(PLATE_DEPTH, BACKER_SIDE_CUTOUT_DEPTH, CLEARANCE, WALL_THICKNESS, GRIDFINITY_UNIT);
n_slides = slide_count(riser_h, SLIDE_FROM_BOTTOM, SLIDE_HEIGHT, SLIDE_MIN_FROM_TOP, SLIDE_SEPARATION);

//risers on both section seams
xcopies(spacing = PLATE_WIDTH, n = 2)
    riser();

//backer, overlapping the riser backs by its side cutout depth
back(riser_d/2 + BACKER_THICKNESS/2 - BACKER_SIDE_CUTOUT_DEPTH + CLEARANCE)
    backer();

//plates on top
up(riser_h + CLEARANCE)
    base_plate(anchor=BOT);
up(riser_h + BASE_PLATE_THICKNESS)
    top_plate(anchor=BOT);

//a 1-unit drawer in every slide slot, with front panel and printed handle
up(DRAWER_SLIDE_MICROADJUST)
fwd((riser_d - drawer_d)/2 + 1) //drawer body sits 1mm proud of the riser face
    zcopies(spacing = SLIDE_SEPARATION, sp = 0, n = n_slides)
        drawer(height_units = 1, anchor=BOT)
            attach(FRONT, TOP)
                drawer_front(height_units = 1)
                    attach(BOT, BACK)
                        drawer_handle();
