/*
DeskWare Next - config.scad

User-facing configuration. Every value here is a default: part modules take
these as parameter defaults, so any single part can be generated at other
dimensions by passing arguments explicitly.

Expects core/constants.scad to be included first (deskware-next.scad does
this in the right order).

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

/*[Core Dimensions]*/
//Width (mm) of one core section, riser center to riser center. Any value - no longer locked to 84mm increments.
PLATE_WIDTH = 196;
//Depth (mm) from the front of the riser to the rear of the backer.
PLATE_DEPTH = 196.5;
//Total height (mm) from the bottom of the riser to the top of the top plate.
TOTAL_HEIGHT = 107.5;

/*[Print Bed]*/
//Maximum printable width (mm) of your printer.
MAX_PRINT_WIDTH = 256;
//Maximum printable depth (mm) of your printer.
MAX_PRINT_DEPTH = 256;

/*[Walls and Fit]*/
//Wall thickness (mm) of drawers and boxes.
WALL_THICKNESS = 3;
//Floor thickness (mm) of drawers and boxes.
BOTTOM_THICKNESS = 2;
//Clearance (mm) between mating parts.
CLEARANCE = 0.15;
//Wall thickness (mm) of drawer compartment dividers.
DIVIDER_THICKNESS = 2;
//Corner radius (mm) for rounded-square end pieces.
CORNER_RADIUS = 50;

/*[Top Plate]*/
//Thickness (mm) of the top plate body (recess depth is added on top).
TOP_PLATE_THICKNESS = 8.5;
//Depth (mm) of the recess in the top of the top plate. Match your insert material thickness for a flush top.
TOP_PLATE_RECESS = 1; //0.1
//Width (mm) of the top lip bordering the recess.
TOP_PLATE_LIP_WIDTH = 0.5;
//Chamfer (mm) at the top edge of the top plate.
TOP_PLATE_TOP_CHAMFER = 2;
//Lateral clearance (mm) between the top plate and the base plate.
TOP_PLATE_CLEARANCE = 1;

/*[Connectors]*/
//Joint style for seams between split or side-by-side parts. (HOK connectors handle stacking and are built into the parts themselves.)
CONNECTOR_STYLE = "dovetail"; //[dovetail, dowel, magnet]
//Target spacing (mm) between connectors along a seam.
CONNECTOR_SPACING = 50;
//Magnet diameter (mm) for magnet-style connections.
MAGNET_DIAMETER = 6;
//Magnet height (mm) for magnet-style connections.
MAGNET_HEIGHT = 2;
//Dowel pin diameter (mm) for dowel-style connections.
DOWEL_DIAMETER = 4;
//Dowel pin length (mm), split evenly across the seam.
DOWEL_LENGTH = 16;

/*[Drawers]*/
//Mounting method of the drawer pull (printed handle vs hardware screws).
DRAWER_MOUNTING = "Handle - Printed"; //[Screw Holes - Single, Screw Holes - Double, Handle - Printed]
//Chamfer (mm) of the drawer front edges.
DRAWER_FRONT_CHAMFER = 1;
//Screw diameter (mm) when using hardware drawer pulls (5mm is common).
DRAWER_PULL_SCREW_DIAMETER = 5;
//Distance (mm) between screw hole centers for double-screw pulls.
DRAWER_PULL_SCREW_SPACING = 75;
//Move the drawer pull holes up (positive) or down (negative) in mm.
DRAWER_PULL_HEIGHT_ADJUST = 0;
//Recess the drawer front for an inlay. Removes the dovetails (print orientation); glue the front to the box.
DRAWER_FRONT_RECESS = false;
//Depth (mm) of the front inlay recess.
DRAWER_FRONT_RECESS_DEPTH = 0.5;
//Inset (mm) of the front inlay recess from the front edges.
DRAWER_FRONT_RECESS_INSET = 0.4;

/*[Curve Sections]*/
//Inner radius (mm) of curved (arc) sections, measured from the riser face.
CURVE_RADIUS = 50;

/*[Colors]*/
PRIMARY_COLOR = "#dadada"; // color
TOP_PLATE_COLOR = "#dadada"; // color
DRAWER_FRONT_COLOR = "#dadada"; // color
DRAWER_HANDLE_COLOR = "#dadada"; // color

/*[Advanced]*/
//Thickness (mm) of the base plate.
BASE_PLATE_THICKNESS = 19;
//Width (mm) of the risers. Grid fit and drawer width derive from this.
RISER_WIDTH = 22;
//Extra reach of the top plate support built into the base plate, in grid units.
ADDITIONAL_TOP_PLATE_SUPPORT = 1; //[1:1:8]
//Echo extra diagnostic output while rendering.
VERBOSE = false;

/*[Hidden]*/
//Grid unit used for placement math. Alias of the openGrid unit from core/constants.scad.
GRID_SIZE = OPENGRID_UNIT;
