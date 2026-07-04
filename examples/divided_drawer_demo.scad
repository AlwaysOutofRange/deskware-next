/*
DeskWare Next - examples/divided_drawer_demo.scad

The divider system three ways:
- left:  drawer with built-in 2 x 3 compartments (the brief's design example)
- right: plain drawer with a floorless 3 x 2 divider_insert dropped in
- front: the insert alone, as printed

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

include <../deskware-next.scad>

drawer_w = drawer_outside_width(PLATE_WIDTH, RISER_WIDTH);
drawer_d = drawer_outside_depth(PLATE_DEPTH, BACKER_SIDE_CUTOUT_DEPTH, CLEARANCE, WALL_THICKNESS, GRIDFINITY_UNIT);

//drawer with built-in compartments
left(drawer_w/2 + 20)
    drawer(height_units = 1, rows = 2, columns = 3, anchor=BOT);

//plain drawer with a drop-in insert (lifted for visibility)
right(drawer_w/2 + 20){
    drawer(height_units = 1, anchor=BOT);
    up(BOTTOM_THICKNESS + 25)
        divider_insert(rows = 3, columns = 2, anchor=BOT);
}

//the insert alone
fwd(drawer_d/2 + 60)
    divider_insert(rows = 3, columns = 2, anchor=BOT);
