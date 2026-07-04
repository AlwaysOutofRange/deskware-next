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

//---------- Drawer slides ----------

//How many drawer slides fit on a riser of the given height.
function slide_count(riser_height, from_bottom, slide_height, min_from_top, separation) =
    floor((riser_height - from_bottom - slide_height - min_from_top) / separation + 1);

//Distance from the top of the drawer body to the top of its rail.
function drawer_slide_from_top(separation, from_bottom, slide_height, slide_clearance, vertical_clearance, clearance) =
    separation - from_bottom - slide_height - slide_clearance - vertical_clearance + clearance;

//---------- Drawer dimensions ----------

//Outside width of the drawer box: it spans between the riser faces (the
//riser bodies and mating clearances cancel out to exactly this).
function drawer_outside_width(core_width, riser_width) =
    core_width - riser_width;

//Outside depth of the drawer box: the available depth in front of the
//backer, with the interior rounded down to whole Gridfinity units.
function drawer_outside_depth(core_depth, backer_cutout, clearance, wall, unit) =
    floor((core_depth - backer_cutout - clearance) / unit) * unit + wall * 2;

//Height of a drawer body of the given number of slide units.
function drawer_height(height_units, separation, vertical_clearance) =
    height_units * separation - vertical_clearance;

//---------- Splitting oversized parts ----------

//Number of printable pieces a span must be cut into.
function split_count(span, max_span) = max(1, ceil(span / max_span));

//Cut positions (centered offsets) dividing span into n equal pieces.
function split_positions(span, n) =
    n <= 1 ? [] : [for(i = [1:1:n-1]) -span/2 + i*span/n];

//---------- Connector placement ----------

//Evenly spread connector positions along a seam of the given span, keeping
//actual spacing at or below target_spacing. Returns a list of offsets
//centered on 0; a single centered connector if the seam is too small.
function connector_positions(span, target_spacing, edge_margin = 15) =
    let(usable = span - edge_margin*2)
    usable <= 0 ? [0] :
    let(n = max(2, ceil(usable / target_spacing) + 1),
        step = usable / (n - 1))
    [for(i = [0:n-1]) -usable/2 + i*step];

//---------- Dividers ----------

//Interior size of one compartment when `count` compartments share `span`
//separated by walls of `thickness`.
function compartment_size(span, count, thickness) =
    (span - (count - 1) * thickness) / count;

//---------- Backer grid ----------

//openGrid units that fit up a backer of the given height.
function backer_grid_height_units(backer_height, unit, bottom_margin, top_margin) =
    grid_units_fit(backer_height, unit, bottom_margin + top_margin);

//True when too little material remains above the grid field, so the HOK
//connector cutouts need reinforcement blocks behind the grid.
function backer_needs_hok_blocks(backer_height, grid_height_mm, bottom_margin, safe_clearance) =
    backer_height - grid_height_mm - bottom_margin < safe_clearance;
