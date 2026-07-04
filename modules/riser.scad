/*
DeskWare Next - modules/riser.scad

The riser: the vertical support the drawers slide into. Risers straddle the
seams between core sections; slide recesses on the chosen sides receive the
drawer rails, HOK cutouts on top and bottom connect to base plates and
stacked risers, and tab holes at the back receive the backer's tabs.
Ported from Riser / RiserSplit in legacy/deskware.scad.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//  slide_sides - "BOTH", "LEFT", "RIGHT", "NONE", or a list of side anchors
//  chamfer     - optional chamfer of the front vertical edges
//  hok_spacing - front-to-back spacing of the HOK cutouts; must match the
//                base plate the riser stacks against (default derives from
//                the same config dimensions)
module riser(
    slide_sides = "BOTH",
    width = RISER_WIDTH,
    depth = riser_depth(PLATE_DEPTH, RISER_SETBACK),
    height = core_section_height(TOTAL_HEIGHT, TOP_PLATE_THICKNESS, BASE_PLATE_THICKNESS),
    chamfer = 0,
    slide_separation = SLIDE_SEPARATION,
    slide_from_bottom = SLIDE_FROM_BOTTOM,
    slide_height = SLIDE_HEIGHT,
    slide_min_from_top = SLIDE_MIN_FROM_TOP,
    hok_spacing = hok_spacing_depth(baseplate_grid_depth_units(base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION), GRID_SIZE, BASEPLATE_GRID_DEPTH_MARGIN), GRID_SIZE),
    hok_inset = HOK_CONNECTOR_INSET,
    tab_width = TAB_WIDTH,
    backer_tab_inset = BACKER_TAB_INSET,
    backer_tab_depth = BACKER_TAB_DEPTH,
    clearance = CLEARANCE,
    col = PRIMARY_COLOR,
    anchor = BOT, spin = 0, orient = UP
){
    n_slides = slide_count(height, slide_from_bottom, slide_height, slide_min_from_top, slide_separation);

    sides =
        slide_sides == "BOTH"  ? [LEFT, RIGHT] :
        slide_sides == "LEFT"  ? [LEFT] :
        slide_sides == "RIGHT" ? [RIGHT] :
        slide_sides == "NONE"  ? [] :
        slide_sides;

    color(col)
    diff(){
        cuboid([width - clearance*2, depth, height], chamfer = chamfer, edges = [FRONT+LEFT, FRONT+RIGHT], anchor=anchor, orient=orient, spin=spin){
            //drawer slide recesses
            attach(sides, LEFT, inside=true, shiftout=0.01, align=BOT)
                ycopies(spacing = slide_separation, sp=[0, slide_from_bottom], n = n_slides)
                    drawer_slide(length = depth + 0.02, delete_tool = true);
            //HOK connector cutouts, top and bottom
            attach([TOP, BOT], BOT, inside=true, shiftout=0.01)
                grid_copies(spacing=[hok_inset*2 - clearance, hok_spacing])
                zrot(90)
                    hok_connector_cutout();
            //backer tab holes
            xcopies(spacing = tab_width + backer_tab_inset*2)
            attach(BACK, BOT, inside=true, shiftout=0.01)
                    alignment_tab(height = backer_tab_depth + clearance, delete_tool = true);
            children();
        }
    }
}

//A riser whose left and right halves have different heights, for stepping
//down between core sections of different total heights. The two printable
//pieces are the normal and reverse_sides=true variants.
module riser_split(
    slide_sides = "BOTH",
    height1 = core_section_height(TOTAL_HEIGHT, TOP_PLATE_THICKNESS, BASE_PLATE_THICKNESS),
    height2 = core_section_height(TOTAL_HEIGHT, TOP_PLATE_THICKNESS, BASE_PLATE_THICKNESS),
    chamfer = 0,
    reverse_sides = false,
    depth = riser_depth(PLATE_DEPTH, RISER_SETBACK)
){
    reversed =
        slide_sides == "BOTH"  ? "BOTH" :
        slide_sides == "LEFT"  ? "RIGHT" :
        slide_sides == "RIGHT" ? "LEFT" :
        "NONE";

    union(){
        left_half(s = depth*4)
            riser(slide_sides = reverse_sides ? reversed : slide_sides, chamfer = chamfer,
                  height = reverse_sides ? height2 : height1, depth = depth);
        right_half(s = depth*4)
            riser(slide_sides = reverse_sides ? reversed : slide_sides, chamfer = chamfer,
                  height = reverse_sides ? height1 : height2, depth = depth);
    }
}
