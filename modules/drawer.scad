/*
DeskWare Next - modules/drawer.scad

The drawer box and its front panel. Ported from Drawer and DrawerFront in
legacy/deskware.scad; at default config values the output is dimensionally
interchangeable with original prints.

The drawer takes OUTSIDE dimensions. Width defaults to the span between the
riser faces; depth defaults to the space in front of the backer with the
interior rounded to whole Gridfinity units, so bins drop straight in.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//  height_units - drawer height in slide units (1 unit = SLIDE_SEPARATION mm)
//  width, depth - outside dimensions of the drawer box
//  slide_inset  - distance from the top of the box to the top of the rail
module drawer(
    height_units = 1,
    width = drawer_outside_width(PLATE_WIDTH, RISER_WIDTH),
    depth = drawer_outside_depth(PLATE_DEPTH, BACKER_SIDE_CUTOUT_DEPTH, CLEARANCE, WALL_THICKNESS, GRIDFINITY_UNIT),
    wall = WALL_THICKNESS,
    bottom = BOTTOM_THICKNESS,
    slide_separation = SLIDE_SEPARATION,
    vertical_clearance = DRAWER_VERTICAL_CLEARANCE,
    slide_inset = drawer_slide_from_top(SLIDE_SEPARATION, SLIDE_FROM_BOTTOM, SLIDE_HEIGHT, SLIDE_CLEARANCE, DRAWER_VERTICAL_CLEARANCE, CLEARANCE) + DRAWER_SLIDE_MICROADJUST,
    mounting = DRAWER_MOUNTING,
    pull_screw_diameter = DRAWER_PULL_SCREW_DIAMETER,
    pull_screw_spacing = DRAWER_PULL_SCREW_SPACING,
    pull_height_adjust = DRAWER_PULL_HEIGHT_ADJUST,
    handle_screw_spacing = HANDLE_SCREW_SPACING,
    dovetail_width = DRAWER_DOVETAIL_WIDTH,
    dovetail_height = DRAWER_DOVETAIL_HEIGHT,
    front_height_reduction = DRAWER_FRONT_HEIGHT_REDUCTION,
    screw_d = SCREW_SM_OUTER_DIAMETER,
    clearance = CLEARANCE,
    col = PRIMARY_COLOR,
    anchor = CENTER, orient = UP, spin = 0
){
    inside = width - wall*2;
    height = drawer_height(height_units, slide_separation, vertical_clearance);
    //dovetail centers sit 14mm inside each interior wall (matches original)
    front_dovetail_spacing = inside - 28;
    pull_hole_count =
        mounting == "Screw Holes - Single" ? 1 :
        mounting == "Screw Holes - Double" ? 2 :
        0;

    check_printable([width, depth], "drawer");
    debug_echo(str("drawer inside is ", inside % GRIDFINITY_UNIT == 0 ? "" : "NOT ",
                   "a Gridfinity fit (", inside, " mm wide, ", inside % GRIDFINITY_UNIT, " mm extra)"));

    tag_scope()
    recolor(col)
    diff()
    rect_tube(size = [width, depth], h = height, wall = wall, anchor=anchor, orient=orient, spin=spin){
        //rails that ride in the riser slides
        attach([LEFT, RIGHT], LEFT, align=TOP, overlap=0.01, inset=slide_inset)
            drawer_slide(length = depth);
        //drawer floor
        tag("keep")
        attach(BOT, BOT, inside=true)
            cuboid([width-0.01, depth-0.01, bottom]);
        //slots for the front panel's dovetail keys
        xcopies(spacing=front_dovetail_spacing)
        attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP, inset=-0.01)
            cuboid([dovetail_width+wall*2, wall+0.02, dovetail_height*height_units+front_height_reduction],
                   chamfer=wall, edges=[FRONT+LEFT, FRONT+RIGHT]);
        //front wall height reduction (the front panel overlaps this)
        attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP, inset=-0.01)
            cuboid([width+0.02, wall+0.02, front_height_reduction]);
        //front pull opening
        attach(FRONT, FRONT, inside=true, shiftout=0.01, align=TOP, inset=front_height_reduction-0.02)
            cuboid([50, wall+0.02, 20], rounding = 5, edges=[LEFT+BOT, RIGHT+BOT])
                edge_profile_asym([TOP+LEFT, TOP+RIGHT], corner_type="round") xflip() mask2d_roundover(2);
        //back cable port
        attach(BACK, FRONT, inside=true, shiftout=0.01, align=TOP, inset=-0.01)
            cuboid([20, wall+0.02, 15], rounding = 5, edges=[LEFT+BOT, RIGHT+BOT])
                edge_profile_asym(TOP, corner_type="round") xflip() mask2d_roundover(3);
        //back cable port, lower opening
        attach(BACK, FRONT, inside=true, shiftout=0.01, align=TOP, inset=20)
            cuboid([20, wall+0.02, 10], rounding = 2, edges=[LEFT+BOT, RIGHT+BOT, TOP+LEFT, TOP+RIGHT]);
        //hardware pull screw hole(s)
        if(pull_hole_count > 0)
        tag("remove")
            up(pull_height_adjust)
            xcopies(spacing = pull_screw_spacing, n = pull_hole_count)
            attach(FRONT, BOT, inside = true, shiftout=0.01)
                cyl(d=pull_screw_diameter, h = wall + 0.02, $fn = 25);
        //printed handle screw recesses
        if(mounting == "Handle - Printed")
            tag("remove")
            xcopies(spacing = handle_screw_spacing)
                attach(FRONT, TOP, inside=true, shiftout=0.01)
                    cyl(d=screw_d+0.25, h=wall-2.5, $fn=25)
                        attach(BOT, TOP, overlap=0.01)
                            cyl(d=15, h=wall, $fn=25);
        children();
    }
}

//The drawer front panel, generated lying flat (Y = panel height) for
//printing. Dovetail keys mate the slots in the drawer box; with
//recess=true the keys are dropped (print orientation) and the panel gets an
//inlay recess instead - glue it to the box.
module drawer_front(
    height_units = 1,
    drawer_width = drawer_outside_width(PLATE_WIDTH, RISER_WIDTH),
    riser_width = RISER_WIDTH,
    wall = WALL_THICKNESS,
    thickness = DRAWER_FRONT_THICKNESS,
    chamfer = DRAWER_FRONT_CHAMFER,
    lateral_clearance = DRAWER_FRONT_LATERAL_CLEARANCE,
    slide_separation = SLIDE_SEPARATION,
    vertical_clearance = DRAWER_VERTICAL_CLEARANCE,
    mounting = DRAWER_MOUNTING,
    pull_screw_diameter = DRAWER_PULL_SCREW_DIAMETER,
    pull_screw_spacing = DRAWER_PULL_SCREW_SPACING,
    pull_height_adjust = DRAWER_PULL_HEIGHT_ADJUST,
    handle_screw_spacing = HANDLE_SCREW_SPACING,
    dovetail_width = DRAWER_DOVETAIL_WIDTH,
    dovetail_height = DRAWER_DOVETAIL_HEIGHT,
    front_height_reduction = DRAWER_FRONT_HEIGHT_REDUCTION,
    recess = DRAWER_FRONT_RECESS,
    recess_depth = DRAWER_FRONT_RECESS_DEPTH,
    recess_inset = DRAWER_FRONT_RECESS_INSET,
    screw_d = SCREW_SM_OUTER_DIAMETER,
    clearance = CLEARANCE,
    col = DRAWER_FRONT_COLOR,
    anchor = CENTER, orient = UP, spin = 0
){
    inside = drawer_width - wall*2;
    panel_width = drawer_width + riser_width - lateral_clearance*2;
    height = drawer_height(height_units, slide_separation, vertical_clearance);
    front_dovetail_spacing = inside - 28;
    pull_hole_count =
        mounting == "Screw Holes - Single" ? 1 :
        mounting == "Screw Holes - Double" ? 2 :
        0;

    tag_scope()
    recolor(col)
    diff()
    cuboid([panel_width, height, thickness], chamfer = chamfer, edges=BOT, anchor=anchor, orient=orient, spin=spin){
        //dovetail keys that slide into the drawer box
        if(!recess)
        xcopies(spacing=front_dovetail_spacing)
        attach(TOP, FRONT, overlap=0.01, align=BACK, inset=front_height_reduction)
            cuboid([dovetail_width+wall*2-clearance*2, wall+0.02, dovetail_height*height_units - clearance],
                   chamfer=wall, edges=[FRONT+LEFT, FRONT+RIGHT]);
        //hardware pull screw hole(s)
        if(pull_hole_count > 0)
        tag("remove")
            back(pull_height_adjust)
            xcopies(spacing = pull_screw_spacing, n = pull_hole_count)
            attach(TOP, BOT, inside = true, shiftout=0.01)
                cyl(d=pull_screw_diameter, h = thickness + 0.03, $fn = 25);
        //printed handle screw pass-throughs and T-screw recesses
        if(mounting == "Handle - Printed"){
            tag("remove")
                xcopies(spacing = handle_screw_spacing)
                    attach(BOT, TOP, inside=true, shiftout=0.01)
                        cyl(d=screw_d+0.25, h=thickness + wall + 0.03, $fn=25);
            tag("remove")
                xcopies(spacing = handle_screw_spacing)
                    attach(TOP, TOP, inside=false, shiftout=0.01)
                        cyl(d=screw_d+0.25, h=wall-2.5, $fn=25)
                            attach(BOT, TOP, overlap=0.01)
                                cyl(d=15, h=wall, $fn=25);
        }
        //inlay recess
        if(recess)
            tag("remove")
            attach(BOT, TOP, overlap=recess_depth)
                cuboid([panel_width - chamfer*2 - recess_inset*2, height - chamfer*2 - recess_inset*2, recess_depth+0.01]);
        children();
    }
}
