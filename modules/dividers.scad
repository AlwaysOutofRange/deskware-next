/*
DeskWare Next - modules/dividers.scad

The divider system. divider_grid() is the reusable wall lattice: drawer()
embeds it for built-in compartments (rows/columns parameters), and
divider_insert() wraps it in a friction-fit frame that drops into an
already-printed drawer. Compartment sizes derive from the parent dimensions
via compartment_size() in core/math.scad.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//A lattice of divider walls filling `size`, splitting it into
//rows (front-to-back) x columns (left-to-right) compartments.
//Generates nothing when rows and columns are both 1.
module divider_grid(size, rows = 1, columns = 1, thickness = DIVIDER_THICKNESS, anchor=CENTER, spin=0, orient=UP){
    assert(rows >= 1 && columns >= 1, "divider_grid needs at least 1 row and 1 column");
    comp_w = compartment_size(size.x, columns, thickness);
    comp_d = compartment_size(size.y, rows, thickness);
    assert(comp_w > thickness && comp_d > thickness,
           str("compartments would be smaller than the dividers themselves (",
               comp_w, " x ", comp_d, " mm)"));

    attachable(anchor, spin, orient, size=size){
        union(){
            if(columns > 1)
                xcopies(spacing = comp_w + thickness, n = columns - 1)
                    cuboid([thickness, size.y, size.z]);
            if(rows > 1)
                ycopies(spacing = comp_d + thickness, n = rows - 1)
                    cuboid([size.x, thickness, size.z]);
        }
        children();
    }
}

//A drop-in divider tray for an existing drawer: a perimeter frame around a
//divider_grid, sized to the drawer interior minus a friction-fit clearance.
//By default it is floorless (the drawer floor is the compartment floor);
//set floor_thickness to add one.
//  height_units    - the drawer it drops into (sets default size)
//  size            - [width, depth, height] override; defaults to the
//                    interior of a default-config drawer
module divider_insert(
    rows = 2,
    columns = 2,
    height_units = 1,
    size = undef,
    thickness = DIVIDER_THICKNESS,
    floor_thickness = 0,
    fit_clearance = CLEARANCE,
    wall = WALL_THICKNESS,
    bottom = BOTTOM_THICKNESS,
    col = PRIMARY_COLOR,
    anchor = BOT, spin = 0, orient = UP
){
    inner_size = first_defined([size,
        [drawer_outside_width(PLATE_WIDTH, RISER_WIDTH) - wall*2,
         drawer_outside_depth(PLATE_DEPTH, BACKER_SIDE_CUTOUT_DEPTH, CLEARANCE, WALL_THICKNESS, GRIDFINITY_UNIT) - wall*2,
         drawer_height(height_units, SLIDE_SEPARATION, DRAWER_VERTICAL_CLEARANCE) - bottom]]);
    fitted = [inner_size.x - fit_clearance*2, inner_size.y - fit_clearance*2, inner_size.z];

    debug_echo(str("divider insert: ", fitted.x, " x ", fitted.y, " x ", fitted.z, " mm, compartments ",
                   compartment_size(fitted.x - thickness*2, columns, thickness), " x ",
                   compartment_size(fitted.y - thickness*2, rows, thickness), " mm"));

    color(col)
    attachable(anchor, spin, orient, size=fitted){
        union(){
            //perimeter frame
            rect_tube(size = [fitted.x, fitted.y], h = fitted.z, wall = thickness, anchor=CENTER);
            //divider lattice inside the frame
            divider_grid([fitted.x - thickness*2, fitted.y - thickness*2, fitted.z],
                         rows = rows, columns = columns, thickness = thickness);
            //optional floor
            if(floor_thickness > 0)
                up(-fitted.z/2 + floor_thickness/2)
                    cuboid([fitted.x - 0.01, fitted.y - 0.01, floor_thickness]);
        }
        children();
    }
}
