/*
DeskWare Next - examples/customizer.scad

Open this file in OpenSCAD and use the Customizer panel to generate any
part - or the whole assembly - at any dimensions. This is the interactive
entry point to the framework: pick the part, set the dimensions, export.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

/*[Part]*/
//Which part to generate (assembly = display view of everything)
Part = "assembly"; //[assembly, base plate, top plate, riser, backer, drawer, drawer front, drawer handle, divider insert]

/*[Dimensions]*/
//Width (mm) of one section, riser center to riser center
Section_Width = 196;
//Core depth (mm), riser front to backer rear
Section_Depth = 196.5;
//Total height (mm) including plates
Height = 107.5;
//Number of sections (assembly only)
Sections = 1;

/*[Drawer Options]*/
//Drawer height in slide units (40mm each)
Drawer_Units = 1;
//Compartments front-to-back
Drawer_Rows = 1;
//Compartments left-to-right
Drawer_Columns = 1;

include <../deskware-next.scad>

riser_h = core_section_height(Height, TOP_PLATE_THICKNESS, BASE_PLATE_THICKNESS);
bp_d = base_plate_depth(Section_Depth, BASEPLATE_DEPTH_EXTENSION);
tp_d = top_plate_depth(bp_d, INTERFACE_CHAMFER, TOP_PLATE_CLEARANCE);
drawer_w = drawer_outside_width(Section_Width, RISER_WIDTH);
drawer_d = drawer_outside_depth(Section_Depth, BACKER_SIDE_CUTOUT_DEPTH, CLEARANCE, WALL_THICKNESS, GRIDFINITY_UNIT);
hok_depth = hok_spacing_depth(baseplate_grid_depth_units(bp_d, GRID_SIZE, BASEPLATE_GRID_DEPTH_MARGIN), GRID_SIZE);
hok_back = hok_spacing_back(baseplate_grid_width_units(Section_Width, GRID_SIZE, RISER_WIDTH), GRID_SIZE);

if(Part == "assembly")
    storage_system(sections = Sections, width = Section_Width, depth = Section_Depth, total_height = Height);
else if(Part == "base plate")
    base_plate(width = Section_Width, depth = bp_d, anchor=BOT);
else if(Part == "top plate")
    top_plate(width = Section_Width, depth = tp_d, anchor=BOT);
else if(Part == "riser")
    riser(height = riser_h, depth = riser_depth(Section_Depth, RISER_SETBACK), hok_spacing = hok_depth);
else if(Part == "backer")
    backer(width = Section_Width, height = riser_h, hok_spacing = hok_back);
else if(Part == "drawer")
    drawer(height_units = Drawer_Units, width = drawer_w, depth = drawer_d,
           rows = Drawer_Rows, columns = Drawer_Columns, anchor=BOT);
else if(Part == "drawer front")
    drawer_front(height_units = Drawer_Units, drawer_width = drawer_w, anchor=BOT);
else if(Part == "drawer handle")
    drawer_handle(anchor=BOT);
else if(Part == "divider insert")
    divider_insert(rows = max(Drawer_Rows, 2), columns = max(Drawer_Columns, 2),
                   height_units = Drawer_Units,
                   size = [drawer_w - WALL_THICKNESS*2, drawer_d - WALL_THICKNESS*2,
                           drawer_height(Drawer_Units, SLIDE_SEPARATION, DRAWER_VERTICAL_CLEARANCE) - BOTTOM_THICKNESS],
                   anchor=BOT);
