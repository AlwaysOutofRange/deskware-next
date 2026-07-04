/*
DeskWare Next - examples/test_print_200.scad

A complete test storage system: 200 mm wide, 200.5 mm deep, 107.5 mm tall,
two 1-unit drawers, squared ends - with every part pre-split for the print
bed configured in config.scad (MAX_PRINT_WIDTH x MAX_PRINT_DEPTH).

NOTE on height: 105.5 mm was the request, but two drawer slots physically
need a riser of at least 79 mm (11.75 bottom offset + 10.5 slide + 40
separation + 16.75 minimum top margin) and 105.5 total leaves only 78.
107.5 (the DeskWare standard height) keeps both slots with proper drawer
clearance; 106.5 would fit them too but leaves the top drawer only 0.15 mm
under the base plate.

Print list - select each via the Customizer "Part" dropdown and export:

  part                      prints  pieces per print / joint
  base plate                  1     2 x 2 grid, hidden dowels
  top plate                   1     2 x 2 grid, dovetail keys
  riser (print 2)             2     2, dovetail key
  backer                      1     2, puzzle glue seam
  drawer (print 2)            2     2, puzzle glue seam
  drawer front (print 2)      2     2, puzzle glue seam
  handles and screws          1     2 handles + 4 T-screws
  base plate end (print 2)    2     2, hidden dowels (same part both sides)
  top plate end (print 2)     2     2, dovetail keys (same part both sides)
  connector keys              1     every dovetail key and dowel pin

A plate can be wider than the bed once pieces are spread apart - use your
slicer's "split to objects" and arrange the pieces individually. Puzzle
seams are glue joints; dovetail keys drop in from the top after joining;
dowels press into one half before joining.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

/*[Part]*/
//Which print plate to generate
Part = "assembly"; //[assembly, base plate, top plate, riser (print 2), backer, drawer (print 2), drawer front (print 2), handles and screws, base plate end (print 2), top plate end (print 2), connector keys]
//Distance between split pieces on the plate
Gap = 20;

include <../deskware-next.scad>

//The test system
WIDTH = 200;
DEPTH = 200.5;
HEIGHT = 107.5; //not 105.5: two drawer slots need a 79mm riser (see header)
END = "Squared";

//derived exactly as storage_system() derives them
riser_h = core_section_height(HEIGHT, TOP_PLATE_THICKNESS, BASE_PLATE_THICKNESS);
riser_d = riser_depth(DEPTH, RISER_SETBACK);
bp_d = base_plate_depth(DEPTH, BASEPLATE_DEPTH_EXTENSION);
tp_d = top_plate_depth(bp_d, INTERFACE_CHAMFER, TOP_PLATE_CLEARANCE);
bp_h = BASE_PLATE_THICKNESS + INTERFACE_CHAMFER;
tp_h = TOP_PLATE_THICKNESS + TOP_PLATE_RECESS;
drawer_w = drawer_outside_width(WIDTH, RISER_WIDTH);
drawer_d = drawer_outside_depth(DEPTH, BACKER_SIDE_CUTOUT_DEPTH, CLEARANCE, WALL_THICKNESS, GRIDFINITY_UNIT);
drawer_h = drawer_height(1, SLIDE_SEPARATION, DRAWER_VERTICAL_CLEARANCE);
front_w = drawer_w + RISER_WIDTH - DRAWER_FRONT_LATERAL_CLEARANCE*2;

//shared HOK spacings so risers/backer/ends mate the plates above them
hok_depth = hok_spacing_depth(baseplate_grid_depth_units(bp_d, GRID_SIZE, BASEPLATE_GRID_DEPTH_MARGIN), GRID_SIZE);
hok_back = hok_spacing_back(baseplate_grid_width_units(WIDTH, GRID_SIZE, RISER_WIDTH), GRID_SIZE);

//keys a seam needs: connector layout, minus positions the keepout drops
//around a perpendicular cut through the middle (mirrors split_part)
function seam_keys(span, crossing = false) =
    len([for(p = connector_positions(span, CONNECTOR_SPACING)) if(!crossing || abs(p) >= 15) p]);

n_dovetail = seam_keys(tp_d, true) + seam_keys(WIDTH - CLEARANCE*2, true) //top plate
           + 2 * seam_keys(RISER_WIDTH - CLEARANCE*2)                     //risers
           + 2 * seam_keys(END_ANGLE_DISTANCE);                           //top ends
n_dowel = seam_keys(bp_d, true) + seam_keys(WIDTH - CLEARANCE*2, true)    //base plate
        + 2 * seam_keys(END_LATERAL_WIDTH);                               //base ends

if(Part == "assembly")
    storage_system(sections = 1, width = WIDTH, depth = DEPTH, total_height = HEIGHT, end_style = END);

//plates: too big for the bed in both directions - 2 x 2 grid splits.
//The base plate is thinner at the cuts (grid well), so its dowels sit in
//the solid floor below the tile pocket.
else if(Part == "base plate")
    split_part(size = [WIDTH - CLEARANCE*2, bp_d, bp_h], axis = "both",
               style = "dowel", seam = [0, BASEPLATE_TILE_POCKET], gap = Gap, show_keys = false)
        base_plate(width = WIDTH, depth = bp_d, anchor=BOT);
else if(Part == "top plate")
    split_part(size = [WIDTH - CLEARANCE*2, tp_d, tp_h], axis = "both",
               style = "dovetail", gap = Gap, show_keys = false)
        top_plate(width = WIDTH, depth = tp_d, anchor=BOT);

//riser: only the 193mm depth exceeds the bed
else if(Part == "riser (print 2)")
    split_part(size = [RISER_WIDTH - CLEARANCE*2, riser_d, riser_h], axis = "y",
               style = "dovetail", gap = Gap, show_keys = false)
        riser(height = riser_h, depth = riser_d, hok_spacing = hok_depth);

//thin-walled parts: puzzle glue seams (a loose key would not fit inside)
else if(Part == "backer")
    split_part(size = [WIDTH - CLEARANCE*2, BACKER_THICKNESS, riser_h], axis = "x",
               style = "puzzle", gap = Gap)
        backer(width = WIDTH, height = riser_h, hok_spacing = hok_back);
else if(Part == "drawer (print 2)")
    split_part(size = [drawer_w, drawer_d, drawer_h], axis = "x",
               style = "puzzle", gap = Gap)
        drawer(height_units = 1, width = drawer_w, depth = drawer_d, anchor=BOT);
else if(Part == "drawer front (print 2)")
    //size.z reaches over the dovetail keys on the panel's back
    split_part(size = [front_w, drawer_h, DRAWER_FRONT_THICKNESS + WALL_THICKNESS + 0.2], axis = "x",
               style = "puzzle", gap = Gap)
        drawer_front(height_units = 1, drawer_width = drawer_w, anchor=BOT);

else if(Part == "handles and screws"){
    ycopies(spacing = 40, n = 2)
        drawer_handle(anchor=BOT);
    fwd(60)
        xcopies(spacing = 15, n = 4)
            t_screw();
}

//end caps: left and right are the same print, rotated 180 at assembly
else if(Part == "base plate end (print 2)")
    split_part(size = [END_LATERAL_WIDTH, bp_d, bp_h], axis = "y",
               style = "dowel", seam = [0, 11], gap = Gap, show_keys = false)
        base_plate_end(style = END, side = LEFT, depth = bp_d, hok_spacing = hok_depth, anchor=BOT);
else if(Part == "top plate end (print 2)")
    split_part(size = [END_ANGLE_DISTANCE, tp_d, tp_h], axis = "y",
               style = "dovetail", gap = Gap, show_keys = false)
        right(END_ANGLE_DISTANCE/2) //recenter the half cap for splitting
            top_plate_end(style = END, side = LEFT, depth = tp_d);

else if(Part == "connector keys"){
    echo(str("connector keys: ", n_dovetail, " dovetail keys, ", n_dowel, " dowel pins"));
    //dovetail keys flat on the bed
    left(60)
        for(i = [0:1:n_dovetail-1])
            translate([(i % 4) * 16, floor(i / 4) * 24, 0])
                dovetail_male(anchor=BOT);
    //dowel pins standing
    right(40)
        for(i = [0:1:n_dowel-1])
            translate([(i % 4) * 10, floor(i / 4) * 10, 0])
                dowel_pin(anchor=BOT);
}
