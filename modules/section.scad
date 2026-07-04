/*
DeskWare Next - modules/section.scad

storage_system(): a complete DeskWare system in one call - risers shared
between sections, backers, base and top plates, and drawers filling every
slide slot. All cross-part derivations (grid counts, HOK connector
spacings, drawer sizes, slot counts) are wired from the same width/depth/
height arguments, so any dimensions stay consistent across parts.

Intended for assembly display and as the reference for how parts compose;
print individual parts via their own modules (or examples/customizer.scad).

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//  sections     - number of core sections side by side
//  width        - width (mm) of one section, riser center to riser center
//  depth        - core depth (mm); plate depths derive from it
//  total_height - bottom of the risers to the top of the top plate
//  drawers      - fill every slide slot with a 1-unit drawer
//  fronts       - add drawer fronts (and printed handles per DRAWER_MOUNTING)
//  ends         - cap the outer sections with end pieces
//  end_style    - "Rounded", "Squared", or "Rounded Square"
//  explode      - lift the plate stack and slide drawers out, for display
module storage_system(
    sections = 1,
    width = PLATE_WIDTH,
    depth = PLATE_DEPTH,
    total_height = TOTAL_HEIGHT,
    drawers = true,
    fronts = true,
    ends = true,
    end_style = END_STYLE,
    slide_sides = "BOTH",
    explode = 0
){
    riser_h = core_section_height(total_height, TOP_PLATE_THICKNESS, BASE_PLATE_THICKNESS);
    riser_d = riser_depth(depth, RISER_SETBACK);
    bp_d = base_plate_depth(depth, BASEPLATE_DEPTH_EXTENSION);
    tp_d = top_plate_depth(bp_d, INTERFACE_CHAMFER, TOP_PLATE_CLEARANCE);
    drawer_w = drawer_outside_width(width, RISER_WIDTH);
    drawer_d = drawer_outside_depth(depth, BACKER_SIDE_CUTOUT_DEPTH, CLEARANCE, WALL_THICKNESS, GRIDFINITY_UNIT);
    n_slots = slide_count(riser_h, SLIDE_FROM_BOTTOM, SLIDE_HEIGHT, SLIDE_MIN_FROM_TOP, SLIDE_SEPARATION);

    //shared spacings so risers/backers always mate the plates above them
    hok_depth = hok_spacing_depth(baseplate_grid_depth_units(bp_d, GRID_SIZE, BASEPLATE_GRID_DEPTH_MARGIN), GRID_SIZE);
    hok_back = hok_spacing_back(baseplate_grid_width_units(width, GRID_SIZE, RISER_WIDTH), GRID_SIZE);

    //risers on every seam
    xcopies(spacing = width, n = sections + 1)
        riser(slide_sides = slide_sides, height = riser_h, depth = riser_d, hok_spacing = hok_depth);

    //backers
    back(riser_d/2 + BACKER_THICKNESS/2 - BACKER_SIDE_CUTOUT_DEPTH + CLEARANCE)
        xcopies(spacing = width, n = sections)
            backer(width = width, height = riser_h, hok_spacing = hok_back);

    //plate stack
    up(riser_h + CLEARANCE + explode)
        xcopies(spacing = width, n = sections)
            base_plate(width = width, depth = bp_d, anchor=BOT);
    up(riser_h + BASE_PLATE_THICKNESS + explode*2)
        xcopies(spacing = width, n = sections)
            top_plate(width = width, depth = tp_d, anchor=BOT);

    //end caps on the outer sections
    if(ends){
        up(riser_h + CLEARANCE + explode)
            xcopies(spacing = width * sections)
                base_plate_end(style = end_style, side = $idx == 0 ? LEFT : RIGHT,
                               depth = bp_d, hok_spacing = hok_depth, anchor=BOT+RIGHT);
        up(riser_h + BASE_PLATE_THICKNESS + explode*2)
            xcopies(spacing = width * sections + CLEARANCE*2)
                top_plate_end(style = end_style, side = $idx == 0 ? LEFT : RIGHT, depth = tp_d);
    }

    //drawers in every slot
    if(drawers && slide_sides == "BOTH" && n_slots > 0)
        up(DRAWER_SLIDE_MICROADJUST)
        fwd((riser_d - drawer_d)/2 + 1 + explode) //1mm proud of the riser face
            xcopies(spacing = width, n = sections)
                zcopies(spacing = SLIDE_SEPARATION, sp = 0, n = n_slots)
                    drawer(height_units = 1, width = drawer_w, depth = drawer_d, anchor=BOT)
                        if(fronts)
                            attach(FRONT, TOP)
                                drawer_front(height_units = 1, drawer_width = drawer_w)
                                    if(DRAWER_MOUNTING == "Handle - Printed")
                                        attach(BOT, BACK)
                                            drawer_handle();
}
