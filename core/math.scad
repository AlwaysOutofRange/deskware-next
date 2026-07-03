/*
DeskWare Next - core/math.scad

Pure functions for derived dimensions. Everything takes explicit inputs and
returns a value - no geometry, no globals. These port the file-scope
calculation block of the original deskware.scad so that any parent dimension
change propagates naturally.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//---------- Generic grid fitting ----------

//Number of whole grid units that fit in `span` after reserving `margin` total.
function grid_units_fit(span, unit, margin = 0) =
    max(0, floor((span - margin) / unit));

//Physical span (mm) of `units` grid units.
function grid_span(units, unit) = units * unit;

function is_odd(n) = n % 2 != 0;

//---------- Base plate grid pockets ----------

//openGrid units that fit across a base plate width. Each side reserves half
//a riser width (the riser straddles the seam between sections).
function baseplate_grid_width_units(width, unit, riser_width) =
    grid_units_fit(width, unit, riser_width);

//openGrid units that fit along a base plate depth.
function baseplate_grid_depth_units(depth, unit, depth_margin) =
    grid_units_fit(depth, unit, depth_margin * 2);

//---------- HOK connector placement ----------

//Center-to-center spacing of HOK connector cutouts along a part's depth.
//Odd grid depths sit connectors 2 units apart, even depths 3 units apart,
//so cutouts always land between grid cells.
function hok_spacing_depth(grid_depth_units, unit) =
    is_odd(grid_depth_units) ? unit * 2 : unit * 3;

//Center-to-center spacing of HOK connector cutouts across a part's back.
function hok_spacing_back(grid_width_units, unit) =
    min(unit * (grid_width_units - 1),
        is_odd(grid_width_units) ? unit * 4 : unit * 3);

//---------- Stack heights ----------

//Height of the core section (risers, backer, drawers) for a given total.
function core_section_height(total_height, top_plate_thickness, base_plate_thickness) =
    total_height - top_plate_thickness - base_plate_thickness;

//---------- Companion part dimensions ----------

//The base plate overhangs the core section at the front.
function base_plate_depth(core_depth, front_extension) =
    core_depth + front_extension;

//The top plate reaches out over the base plate's interface chamfers, minus
//lateral clearance so it can seat.
function top_plate_depth(base_plate_depth, interface_chamfer, lateral_clearance) =
    base_plate_depth + interface_chamfer * 2 - lateral_clearance * 2;

//The riser is set back from the core section depth.
function riser_depth(core_depth, setback) = core_depth - setback;
