/*
DeskWare Next - modules/base_plate.scad

The base plate: sits on top of the risers, carries an openGrid tile field on
its underside, HOK connector cutouts on its sides and back, alignment tabs
and dovetail sockets for joining sections and end caps. Ported from
basePlateBuilderPath in legacy/deskware.scad; at default config values the
output is dimensionally interchangeable with original prints.

Every internal placement is derived from width/depth via core/math.scad, so
any dimensions work - grid counts and connector positions adapt.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.

Note on arcs: when arc != 0 the part is generated along its sweep arc rather
than centered on the origin, and (as in the original) carries no openGrid
pocket or back connectors. Position curved parts manually.
*/

//  width  - section width (mm), riser center to riser center
//  depth  - front-to-back size (mm); default overhangs the core section
//  height - main plate thickness; the interface lip adds interface_chamfer
//  arc    - degrees of arc for curved sections (0 = straight)
//  arc_r  - centerline radius of the sweep when arc != 0
module base_plate(
    width = PLATE_WIDTH,
    depth = base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION),
    height = BASE_PLATE_THICKNESS,
    arc = 0,
    arc_r = riser_depth(PLATE_DEPTH, RISER_SETBACK)/2 + CURVE_RADIUS,
    clearance = CLEARANCE,
    grid_size = GRID_SIZE,
    riser_width = RISER_WIDTH,
    grid_depth_margin = BASEPLATE_GRID_DEPTH_MARGIN,
    bottom_chamfer = BASEPLATE_BOTTOM_CHAMFER,
    interface_chamfer = INTERFACE_CHAMFER,
    resting_surface = MIN_RESTING_SURFACE,
    tile_pocket = BASEPLATE_TILE_POCKET,
    tile_full = OPENGRID_TILE_THICKNESS,
    top_support = ADDITIONAL_TOP_PLATE_SUPPORT,
    hok_inset = HOK_CONNECTOR_INSET,
    dovetail_spacing = DOVETAIL_SPACING,
    tab_protrusion = TAB_PROTRUSION,
    tab_edge_inset = TAB_EDGE_INSET,
    tab_width = TAB_WIDTH,
    col = PRIMARY_COLOR,
    anchor = CENTER, spin = 0, orient = UP,
    $fn = 150
){
    total_height = height + interface_chamfer;

    grid_w_units = baseplate_grid_width_units(width, grid_size, riser_width);
    grid_d_units = baseplate_grid_depth_units(depth, grid_size, grid_depth_margin);
    grid_w_mm = grid_span(grid_w_units, grid_size);
    grid_d_mm = grid_span(grid_d_units, grid_size);
    hok_d_spacing = hok_spacing_depth(grid_d_units, grid_size);
    hok_b_spacing = hok_spacing_back(grid_w_units, grid_size);

    profile = base_plate_profile(depth, height, bottom_chamfer, interface_chamfer, resting_surface, tile_pocket);

    //alignment shift of the sweep, carried over from the original so the
    //openGrid field lines up across base plate, backer, and accessories
    sweep_shift = 0.5;

    check_printable([width, depth], "base plate");
    debug_echo(str("base plate grid: ", grid_d_units, " x ", grid_w_units, " openGrid units"));

    attachable(anchor, spin, orient, size = [width - clearance*2, depth, total_height]){
        down(total_height/2)
        color(col)
        {
            if(arc == 0)
                straight_body();
            else
                arc_body();
        }
        children();
    }

    module straight_body(){
        diff("HOKConnectors Dovetails", "k1")
        diff("r1", "keep HOKConnectors Dovetails")
        sweep_profile(profile, width, clearance = clearance, reverse = true, shift = sweep_shift){
            //alignment tabs the top plate drops onto
            attach(["start", "end"], BOT, inside=false)
                down(tab_width/2 + tab_edge_inset)
                xrot(-90) zrot(90)
                alignment_tab(height = height + tab_protrusion);
            //HOK connector cutouts, sides
            tag("HOKConnectors")
            attach(["start", "end"], BOT, inside=true)
                xcopies(spacing = hok_d_spacing)
                up(hok_inset - clearance)
                    xrot(-90) zrot(90) down(0.01)
                        hok_connector_cutout(spin=90);
            //HOK connector cutouts, back
            tag("HOKConnectors")
            down(total_height/2)
            attach(RIGHT, BOT, inside=true)
                xcopies(spacing = hok_b_spacing)
                up(hok_inset)
                    xrot(-90) zrot(90) down(0.01)
                        hok_connector_cutout(spin=90);
            //top plate support shelf at each end, with dovetail sockets
            tag("keep")
            attach(["start", "end"], BOT, inside=false)
                back(tile_full)
                down(grid_size*(top_support + 0.5)/2)
                xrot(-90) zrot(90)
                cuboid([grid_size*(top_support + 0.5), grid_size*(is_odd(grid_d_units) ? 3 : 4), height - tile_full],
                       chamfer=height-tile_pocket, edges=[TOP], except=LEFT){
                    tag("Dovetails")
                        attach(LEFT, BOT, inside=true, shiftout = 0.01, align=TOP)
                            xcopies(spacing = dovetail_spacing)
                            dovetail_female();
                }
            //openGrid tile pocket and tiles
            tag("r1")
            left(sweep_shift)
            attach(BOT, BOT, inside=true, shiftout=0.01)
                cuboid([grid_d_mm, grid_w_mm, tile_pocket+0.02]){
                    tag("keep")
                        openGrid(Board_Width = grid_d_units, Board_Height = grid_w_units, Tile_Thickness = tile_pocket);
                }
        }
    }

    module arc_body(){
        diff()
        sweep_profile(profile, arc = arc, arc_r = arc_r, reverse = true){
            //alignment tabs the top plate drops onto
            attach(["start", "end"], BOT, inside=false)
                down(tab_width/2 + tab_edge_inset)
                xrot(-90) zrot(90)
                alignment_tab(height = height + tab_protrusion);
            //HOK connector cutouts, sides
            attach(["start", "end"], BOT, inside=true)
                xcopies(spacing = hok_d_spacing)
                up(hok_inset - clearance)
                    xrot(-90) zrot(90) down(0.01)
                        hok_connector_cutout(spin=90);
            //top plate support shelf at each end, with dovetail sockets
            attach(["start", "end"], BOT, inside=false)
                down(18/2)
                xrot(-90) zrot(90)
                cuboid([18, grid_size*4, height], chamfer=height-tile_pocket, edges=[TOP], except=LEFT){
                    tag("remove")
                        attach(LEFT, BOT, inside=true, shiftout = 0.01, align=TOP)
                            xcopies(spacing = dovetail_spacing)
                            dovetail_female();
                }
        }
    }
}
