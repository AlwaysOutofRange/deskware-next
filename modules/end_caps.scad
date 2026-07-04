/*
DeskWare Next - modules/end_caps.scad

The end pieces that cap the outer sections: tilted "squared" /
"rounded square" caps and half-round "rounded" caps, for both the base
plate level and the top plate level. Ported from baseplateEndSquared,
BasePlateEndRounded, TopPlateEndSquared, and TopPlateEndRoundNew in
legacy/deskware.scad; at default config values the output is dimensionally
interchangeable with original prints.

The base ends join the outer base plates with dovetail keys and share HOK
connector cutouts with the risers beneath; the top ends drop onto the base
ends' alignment tabs.

Note: like the originals, the top plate ends are not attachable modules -
they render half a cap (half = LEFT or RIGHT) centered on the origin.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//Dispatch helpers ----------------------------------------------------------

//A base-level end cap in the given style, for one side (LEFT or RIGHT).
module base_plate_end(style = END_STYLE, side = LEFT, depth = base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION), height = BASE_PLATE_THICKNESS, radius = CORNER_RADIUS, hok_spacing = undef, anchor = CENTER, spin = 0, orient = UP){
    if(style == "Rounded")
        base_plate_end_rounded(depth = depth, height = height, half = side, hok_spacing = hok_spacing);
    else
        zrot(side == LEFT ? 0 : 180)
            base_plate_end_squared(depth = depth, height = height,
                                   radius = style == "Squared" ? END_SQUARED_RADIUS : radius,
                                   hok_spacing = hok_spacing, anchor = anchor, spin = spin, orient = orient);
}

//A top-level end cap in the given style, for one side (LEFT or RIGHT).
module top_plate_end(style = END_STYLE, side = LEFT, depth = top_plate_depth(base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION), INTERFACE_CHAMFER, TOP_PLATE_CLEARANCE), thickness = TOP_PLATE_THICKNESS, radius = CORNER_RADIUS){
    if(style == "Rounded")
        top_plate_end_rounded(depth = depth, thickness = thickness, half = side);
    else
        top_plate_end_squared(depth = depth, thickness = thickness,
                              radius = style == "Squared" ? END_SQUARED_RADIUS : radius,
                              half = side);
}

//Base plate ends -----------------------------------------------------------

//Tilted end cap for the "Squared" and "Rounded Square" styles. Renders the
//LEFT-side cap; zrot(180) it for the right. anchor=BOT+RIGHT places its
//inner edge at the origin.
module base_plate_end_squared(
    depth = base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION),
    height = BASE_PLATE_THICKNESS,
    radius = CORNER_RADIUS,
    angle = END_ANGLE,
    angle_distance = END_ANGLE_DISTANCE,
    bevel = END_BEVEL,
    interface_chamfer = INTERFACE_CHAMFER,
    resting_surface = MIN_RESTING_SURFACE,
    tile_pocket = BASEPLATE_TILE_POCKET,
    grid_size = GRID_SIZE,
    top_support = ADDITIONAL_TOP_PLATE_SUPPORT,
    dovetail_spacing = DOVETAIL_SPACING,
    tab_protrusion = TAB_PROTRUSION,
    tab_edge_inset = TAB_EDGE_INSET,
    hok_inset = HOK_CONNECTOR_INSET,
    hok_thickness = HOK_CONNECTOR_THICKNESS,
    hok_spacing = undef,
    clearance = CLEARANCE,
    col = PRIMARY_COLOR,
    spin = 0, orient = UP, anchor = CENTER
){
    $fn = 150;
    lateral_width = cos(angle) * angle_distance;
    //x-extent of the slab that trims the tilted body (legacy default)
    scope_width = 120;
    hok_sp = first_defined([hok_spacing,
        hok_spacing_depth(baseplate_grid_depth_units(depth, grid_size, BASEPLATE_GRID_DEPTH_MARGIN), grid_size)]);

    color(col)
    diff("HOKConnectors", "k1")
        diff("r1", "keep HOKConnectors"){
            main_section(spin = spin, orient = orient, anchor = anchor){
                //top cutout
                tag("r1")
                attach(TOP, TOP, inside=true, shiftout=0.01)
                    intersection(){
                        translate([-lateral_width/2,-depth/2])
                            roof()
                                rect([lateral_width*2,depth], rounding = radius);
                        cube([lateral_width*2,depth, interface_chamfer], center=true);
                    }
                //inside deep cutout
                tag("r1")
                attach(TOP, TOP, inside=true, shiftout=0.01, align=RIGHT)
                    cuboid([angle_distance-resting_surface*3-radius/2, depth-resting_surface*2-interface_chamfer*2, height-tile_pocket+interface_chamfer],  chamfer = (height - tile_pocket), edges=BOT, except_edges=RIGHT);
                if(top_support)
                    //middle support
                    tag("keep")
                    down(interface_chamfer)
                    attach(TOP, TOP, inside=true, align=RIGHT)
                        cuboid([20,grid_size*4,height - 4], chamfer=height-tile_pocket, edges=TOP, except_edges=RIGHT)
                            tag("HOKConnectors")
                            attach(RIGHT, BOT, inside=true, shiftout = 0.01, align=TOP)
                                    xcopies(spacing = dovetail_spacing)
                                        dovetail_female();
                //top plate tabs
                tag("keep")
                attach(BOT, BOT, inside=true, shiftout=0.01, align=RIGHT, inset=tab_edge_inset)
                    alignment_tab(height = height + tab_protrusion);
                //HOK connector cutouts
                tag("HOKConnectors")
                attach(BOT, BOT, inside=true, shiftout=0.01, align=RIGHT, spin=90, inset = hok_inset-hok_thickness/2-clearance)
                    xcopies(spacing=hok_sp)
                        hok_connector_cutout();
                children();
            }
    }

    module main_section(spin = 0, orient = UP, anchor=CENTER){
        attachable(anchor, spin, orient, size=[lateral_width,depth,height+interface_chamfer]){
            //build base
            translate([lateral_width/2,0,-(height+interface_chamfer)/2])
            mirror([0, 0, 1])
            intersection(){
                tilt(); //tilt bevel stretched upward
                base(); //base bevel stretched upward
                //rest
                translate([-scope_width/2, 0])
                    linear_extrude((height+interface_chamfer)*2, center = true)
                    square([scope_width, depth], true);
            }
            children();
        }
    }

    //the lower chamfer section
    module base() {
        stretch()
        down(bevel)
        intersection(){
            roof()
            square([scope_width*2, depth], true);

            linear_extrude(bevel)
            square([scope_width*2, depth], true);
        }
    }

    module tilt() {
        stretch()
        rotate([0, -angle, 0])
        intersection(){
            roof()
            rounded_corners(radius)
            square([angle_distance*2, depth], true);

            linear_extrude(bevel/2)
            square([angle_distance*2, depth], true);
        }
    }

    //extrude a shape endlessly upward
    module stretch() {
        minkowski(){
            children();

            mirror([0, 0, 1])
            cylinder(r1 = 0, r2 = 0.001, h = 100);
        }
    }

    module rounded_corners(amount) {
        offset(r = amount)
        offset(delta = -amount)
        children();
    }
}

//Half-round end cap for the "Rounded" style. half = LEFT renders the
//left-side cap. style "Oct"/"Hex" give faceted variants (legacy bonus).
module base_plate_end_rounded(
    depth = base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION),
    height = BASE_PLATE_THICKNESS,
    half = LEFT,
    style = "Rounded",
    resolution = END_CURVE_RESOLUTION,
    bottom_chamfer = BASEPLATE_BOTTOM_CHAMFER,
    interface_chamfer = INTERFACE_CHAMFER,
    resting_surface = MIN_RESTING_SURFACE,
    tile_pocket = BASEPLATE_TILE_POCKET,
    grid_size = GRID_SIZE,
    top_support = ADDITIONAL_TOP_PLATE_SUPPORT,
    dovetail_spacing = DOVETAIL_SPACING,
    tab_width = TAB_WIDTH,
    tab_protrusion = TAB_PROTRUSION,
    tab_edge_inset = TAB_EDGE_INSET,
    hok_inset = HOK_CONNECTOR_INSET,
    hok_spacing = undef,
    clearance = CLEARANCE,
    col = PRIMARY_COLOR
){
    $fn =
        style == "Rounded" ? resolution :
        style == "Oct" ? 8 :
        style == "Hex" ? 6 :
        resolution;

    //adjust the diameter if a hexagon
    adjusted_diameter =
        style == "Hex" ? depth * sqrt(3) / 1.5 +1: depth;

    hok_sp = first_defined([hok_spacing,
        hok_spacing_depth(baseplate_grid_depth_units(depth, grid_size, BASEPLATE_GRID_DEPTH_MARGIN), grid_size)]);

    color(col)
    half_of(half, s = adjusted_diameter*2 + 5)
    diff("HOKConnectors Dovetails", "k1")
    diff("r1", "keep HOKConnectors Dovetails"){
        //main plate
        cyl(d=adjusted_diameter, h= height+interface_chamfer, anchor=BOT){
            //bot chamfer
            tag("r1")
            edge_profile([BOT])
                mask2d_chamfer(x=bottom_chamfer);
            //top chamfer
            tag("r1")
            attach(TOP, TOP, inside=true, shiftout=0.01)
                cyl(d=adjusted_diameter, h=interface_chamfer, chamfer1 = interface_chamfer);
            //inside cutout
            tag("r1")
            attach(TOP, TOP, inside=true, shiftout=0.02)
                cyl(d=depth-resting_surface*2-interface_chamfer*2, h=height-tile_pocket+interface_chamfer, chamfer1 = (height - tile_pocket));
            //top plate tabs
            tag("keep")
            right(half == LEFT ? -tab_edge_inset-tab_width/2 : tab_edge_inset+tab_width/2)
            attach(BOT, BOT, inside=true, shiftout=0.01)
                alignment_tab(height = height + tab_protrusion);
            //HOK connector cutouts
            tag("HOKConnectors")
            attach(BOT, BOT, inside=true, shiftout=0.01)
                grid_copies(spacing=[hok_inset*2-clearance*2,hok_sp])
                zrot(90)
                    hok_connector_cutout();
            if(top_support)
                //middle support
                tag("keep")
                down(interface_chamfer)
                attach(TOP, TOP, inside=true)
                    cuboid([grid_size*2.5-2,grid_size*4,height - 4], chamfer=height-tile_pocket, edges=[TOP])
                    //dovetails
                    right(half == LEFT ? -4.5 : 4.5)zrot(half == LEFT ? 90 : -90)
                    tag("Dovetails")
                        attach(TOP, BACK, inside=true, shiftout = 0.01)
                            xcopies(spacing = dovetail_spacing)
                                dovetail_female();
        }
    }
}

//Top plate ends ------------------------------------------------------------

//Top-level end cap for the "Squared" and "Rounded Square" styles.
module top_plate_end_squared(
    depth = top_plate_depth(base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION), INTERFACE_CHAMFER, TOP_PLATE_CLEARANCE),
    thickness = TOP_PLATE_THICKNESS,
    width = END_ANGLE_DISTANCE*2,
    radius = CORNER_RADIUS,
    recess = TOP_PLATE_RECESS,
    lip_width = TOP_PLATE_LIP_WIDTH,
    top_chamfer = TOP_PLATE_TOP_CHAMFER,
    interface_chamfer = INTERFACE_CHAMFER,
    tab_width = TAB_WIDTH,
    tab_protrusion = TAB_PROTRUSION,
    tab_edge_inset = TAB_EDGE_INSET,
    half = LEFT,
    col = TOP_PLATE_COLOR
){
    thickness_adjusted = thickness + recess;

    color(col)
    diff(){
        half_of(half, s = depth*2 + 5)
            top_plate_from_shape(total_height = thickness_adjusted, bottom_chamfer = interface_chamfer*2, top_chamfer = top_chamfer, top_inset = lip_width, top_recess = recess)
                rect([width,depth], rounding = [radius,radius,radius,radius]);
            tag("remove")
               up(tab_protrusion/2-0.01)
               xcopies(spacing = tab_width+tab_edge_inset*2)
                    alignment_tab(height = tab_protrusion, delete_tool = true);
    }
}

//Top-level end cap for the "Rounded" style.
module top_plate_end_rounded(
    depth = top_plate_depth(base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION), INTERFACE_CHAMFER, TOP_PLATE_CLEARANCE),
    thickness = TOP_PLATE_THICKNESS,
    recess = TOP_PLATE_RECESS,
    lip_width = TOP_PLATE_LIP_WIDTH,
    top_chamfer = TOP_PLATE_TOP_CHAMFER,
    interface_chamfer = INTERFACE_CHAMFER,
    tab_width = TAB_WIDTH,
    tab_protrusion = TAB_PROTRUSION,
    tab_edge_inset = TAB_EDGE_INSET,
    half = LEFT,
    col = TOP_PLATE_COLOR
){
    thickness_adjusted = thickness + recess;

    color(col)
    diff(){
        half_of(half, s = depth*2 + 5)
            top_plate_from_shape(total_height = thickness_adjusted, bottom_chamfer = interface_chamfer*2, top_chamfer = top_chamfer, top_inset = lip_width, top_recess = recess)
                ellipse(d=depth);
        tag("remove")
            up(tab_protrusion/2-0.01)
            xcopies(spacing = tab_width+tab_edge_inset*2)
                alignment_tab(height = tab_protrusion, delete_tool = true);
    }
}
