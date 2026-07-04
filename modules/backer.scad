/*
DeskWare Next - modules/backer.scad

The backer: the rear panel of a core section. Carries an openGrid field for
accessories, side cutouts that let the risers overlap it, tabs that engage
the risers, and HOK connector cutouts on top for the base plate above.
Ported from Backer in legacy/deskware.scad.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//  hok_spacing - spacing of the HOK cutouts across the top; must match the
//                base plate's back connectors (default derives from the same
//                config dimensions)
module backer(
    width = PLATE_WIDTH,
    height = core_section_height(TOTAL_HEIGHT, TOP_PLATE_THICKNESS, BASE_PLATE_THICKNESS),
    thickness = BACKER_THICKNESS,
    riser_width = RISER_WIDTH,
    grid_size = GRID_SIZE,
    grid_from_bottom = BACKER_GRID_FROM_BOTTOM,
    grid_top_margin = BACKER_GRID_TOP_MARGIN,
    side_cutout_depth = BACKER_SIDE_CUTOUT_DEPTH,
    tab_inset = BACKER_TAB_INSET,
    tab_depth = BACKER_TAB_DEPTH,
    hok_spacing = hok_spacing_back(baseplate_grid_width_units(PLATE_WIDTH, GRID_SIZE, RISER_WIDTH), GRID_SIZE),
    hok_inset = HOK_CONNECTOR_INSET,
    hok_thickness = HOK_CONNECTOR_THICKNESS,
    hok_safe_clearance = BACKER_HOK_SAFE_CLEARANCE,
    clearance = CLEARANCE,
    col = PRIMARY_COLOR,
    anchor = BOT, spin = 0, orient = UP
){
    grid_w_units = baseplate_grid_width_units(width, grid_size, riser_width);
    grid_h_units = backer_grid_height_units(height, grid_size, grid_from_bottom, grid_top_margin);
    grid_h_mm = grid_span(grid_h_units, grid_size);
    needs_hok_blocks = backer_needs_hok_blocks(height, grid_h_mm, grid_from_bottom, hok_safe_clearance);
    //the risers overlap the backer by half their width on each side
    side_cutout_width = riser_width/2 + clearance;

    check_printable([width, height], "backer");
    debug_echo(str("backer grid: ", grid_w_units, " x ", grid_h_units, " openGrid units",
                   needs_hok_blocks ? " (with HOK reinforcement blocks)" : ""));

    color(col)
    diff("HOKConnector", "k1")
    diff("remove", "keep HOKConnector"){
        cuboid([width - clearance*2, thickness, height], anchor=anchor, orient=orient, spin=spin){
            //pocket for the openGrid field
            up(grid_from_bottom)
                attach(BACK, BOT, inside=true, align=BOT, shiftout=0.01)
                    cuboid([grid_w_units*grid_size - 0.02,
                            grid_h_units > 0 ? grid_h_mm - 0.02 : height - grid_top_margin - grid_from_bottom,
                            thickness + 0.02]);
            //openGrid field
            tag("keep")
            up(grid_from_bottom)
            attach(BACK, BOT, inside=true, align=BOT)
                openGrid(grid_w_units, grid_h_units)
                    //reinforcement blocks behind the HOK cutouts when the
                    //grid leaves too little solid material above
                    if(needs_hok_blocks)
                    xcopies(spacing = hok_spacing)
                    attach(BOT, TOP, inside=true, align=BACK, shiftout=0.01)
                        cuboid([grid_size, grid_size, thickness - side_cutout_depth], chamfer=0.5, edges=BOT, except_edges=BACK);
            //cutouts for the risers
            attach(FRONT, FRONT, inside=true, shiftout=0.01, align=[LEFT, RIGHT])
                cuboid([side_cutout_width, side_cutout_depth, height + 0.02]);
            //HOK connector cutouts along the top
            tag("HOKConnector")
            attach(TOP, BOT, inside=true, shiftout=0.01, align=BACK)
                fwd(hok_inset - hok_thickness/2)
                xcopies(spacing = hok_spacing)
                    hok_connector_cutout(anchor=CENTER);
            //tabs that engage the risers
            tag("keep")
            attach(BACK, BOT, align=[LEFT, RIGHT], inset=tab_inset - clearance, inside=true)
                alignment_tab(height = thickness - side_cutout_depth + tab_depth);
            children();
        }
    }
}
