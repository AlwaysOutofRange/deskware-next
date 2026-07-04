/*
DeskWare Next - examples/monitor_shelf.scad

A 300mm-wide, 140.5mm-deep monitor shelf: one wide section with no drawer
slides - just risers, backer, and the plate stack. 300mm parts exceed the
print bed, so the base plate, top plate, and backer are run through
split_part(), shown exploded with their dovetail keys. The risers and the
assembled view share one set of dimension variables, so resizing the shelf
re-derives everything.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

include <../deskware-next.scad>

WIDTH = 300;
DEPTH = 140.5;
HEIGHT = 107.5;   //shelf height including plates

riser_h = core_section_height(HEIGHT, TOP_PLATE_THICKNESS, BASE_PLATE_THICKNESS);
riser_d = riser_depth(DEPTH, RISER_SETBACK);
bp_d = base_plate_depth(DEPTH, BASEPLATE_DEPTH_EXTENSION);
tp_d = top_plate_depth(bp_d, INTERFACE_CHAMFER, TOP_PLATE_CLEARANCE);
hok_depth = hok_spacing_depth(baseplate_grid_depth_units(bp_d, GRID_SIZE, BASEPLATE_GRID_DEPTH_MARGIN), GRID_SIZE);
hok_back = hok_spacing_back(baseplate_grid_width_units(WIDTH, GRID_SIZE, RISER_WIDTH), GRID_SIZE);

//shelf structure: risers without slides, backer split like the plates
xcopies(spacing = WIDTH, n = 2)
    riser(slide_sides = "NONE", height = riser_h, depth = riser_d, hok_spacing = hok_depth);

back(riser_d/2 + BACKER_THICKNESS/2 - BACKER_SIDE_CUTOUT_DEPTH + CLEARANCE)
    split_part(size = [WIDTH, BACKER_THICKNESS, riser_h], seam = [BACKER_THICKNESS, riser_h], gap = 15)
        backer(width = WIDTH, height = riser_h, hok_spacing = hok_back);

//plate stack, split and exploded with dovetail keys at the seams
up(riser_h + CLEARANCE + 25)
    split_part(size = [WIDTH, bp_d, BASE_PLATE_THICKNESS + INTERFACE_CHAMFER],
               seam = [bp_d, BASEPLATE_TILE_POCKET], gap = 20)
        base_plate(width = WIDTH, depth = bp_d, anchor=BOT);

up(riser_h + BASE_PLATE_THICKNESS + 60)
    split_part(size = [WIDTH, tp_d, TOP_PLATE_THICKNESS + TOP_PLATE_RECESS], gap = 20)
        top_plate(width = WIDTH, depth = tp_d, anchor=BOT);
