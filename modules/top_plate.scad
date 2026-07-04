/*
DeskWare Next - modules/top_plate.scad

The top plate: the work surface that seats onto one or more base plates.
Ported from topPlateBuilderPath in legacy/deskware.scad; at default config
values the output is dimensionally interchangeable with original prints.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.

Note on arcs: when arc != 0 the part is generated along its sweep arc rather
than centered on the origin; position curved parts manually.
*/

//  width          - section width (mm), riser center to riser center
//  depth          - front-to-back size (mm); default reaches over the base
//                   plate's interface chamfers minus seating clearance
//  thickness      - plate body thickness; the recess depth is added on top
//  recess         - depth of the top recess (insert material thickness)
//  lip_width      - width of the lip bordering the recess
//  arc            - degrees of arc for curved sections (0 = straight)
//  arc_r          - centerline radius of the sweep when arc != 0
module top_plate(
    width = PLATE_WIDTH,
    depth = top_plate_depth(base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION), INTERFACE_CHAMFER, TOP_PLATE_CLEARANCE),
    thickness = TOP_PLATE_THICKNESS,
    recess = TOP_PLATE_RECESS,
    lip_width = TOP_PLATE_LIP_WIDTH,
    top_chamfer = TOP_PLATE_TOP_CHAMFER,
    bottom_chamfer = INTERFACE_CHAMFER * 2,
    arc = 0,
    arc_r = riser_depth(PLATE_DEPTH, RISER_SETBACK)/2 + CURVE_RADIUS,
    clearance = CLEARANCE,
    tab_protrusion = TAB_PROTRUSION,
    tab_edge_inset = TAB_EDGE_INSET,
    tab_width = TAB_WIDTH,
    col = TOP_PLATE_COLOR,
    anchor = CENTER, spin = 0, orient = UP,
    $fn = 150
){
    total_height = thickness + recess;
    profile = top_plate_profile(depth, total_height, bottom_chamfer, top_chamfer, lip_width, recess);

    check_printable([width, depth], "top plate");

    attachable(anchor, spin, orient, size = [width - clearance*2, depth, total_height]){
        color(col)
        diff("tabs")
        down(total_height/2)
        sweep_profile(profile, width, arc = arc, arc_r = arc_r, clearance = clearance){
            //slots that drop onto the base plate's alignment tabs
            tag("tabs")
            attach(["start", "end"], BOT, inside=true)
                up(tab_width/2 + tab_edge_inset)
                xrot(-90) zrot(90) down(0.01)
                alignment_tab(height = tab_protrusion, delete_tool = true);
        }
        children();
    }
}
