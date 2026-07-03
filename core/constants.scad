/*
DeskWare Next - core/constants.scad

Fixed system constants. These are properties of external systems (openGrid,
Gridfinity) or interoperability-critical dimensions of the original DeskWare
design language. Parts generated with these values mate with original
DeskWare prints. They are NOT user configuration - see config.scad for that.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//---------- External grid systems ----------

//openGrid tile unit (design by David D)
OPENGRID_UNIT = 28;
//Full openGrid tile thickness
OPENGRID_TILE_THICKNESS = 6.8;
//openGrid Lite tile thickness
OPENGRID_LITE_TILE_THICKNESS = 4;

//Gridfinity base unit
GRIDFINITY_UNIT = 42;

//---------- HOK connector (profile fixed for interop) ----------

//Thickness of the printed HOK connector and its cutout
HOK_CONNECTOR_THICKNESS = 3.0;
//Total width of the HOK connector cutout across its mirror axis
HOK_CONNECTOR_WIDTH = 17.8;
//Height (sweep length) of the HOK connector cutout
HOK_CONNECTOR_HEIGHT = 15.2;
//Distance from a part edge to the center of an HOK connector cutout
HOK_CONNECTOR_INSET = 4.5;

//---------- Baseplate dovetails ----------

DOVETAIL_SPACING = 40;
DOVETAIL_DEPTH = 3.15;
DOVETAIL_WIDTH = 10;
DOVETAIL_HEIGHT = 9;
DOVETAIL_CHAMFER = 0.6;
DOVETAIL_SLOP = 0.1;

//---------- Alignment tabs (top plate / backer-to-riser) ----------

TAB_WIDTH = 3;
TAB_DEPTH = 20;
TAB_CHAMFER = 0.5;
//Distance from part outside edge to the tab (TabDistanceFromOutsideEdge)
TAB_EDGE_INSET = 6;
//How far the tab protrudes above its host part (TabProtrusionHeight)
TAB_PROTRUSION = 4;

//---------- Plate interface geometry (DeskWare design language) ----------

//Chamfer where the top plate seats onto the base plate (Top_Bot_Plates_Interface_Chamfer)
INTERFACE_CHAMFER = 3;
//Minimum flat surface the top plate rests on, excluding the chamfer (Minimum_Flat_Resting_Surface)
MIN_RESTING_SURFACE = 7.5;
//Chamfer at the bottom front/back of the base plate
BASEPLATE_BOTTOM_CHAMFER = 5;
//Depth of the openGrid tile pocket in the base plate underside (Tile_Thickness)
BASEPLATE_TILE_POCKET = 11.5;
//How much deeper the base plate is than the core section (front overhang)
BASEPLATE_DEPTH_EXTENSION = 10.5;
//Front/back margin around the openGrid pocket in the base plate (Grid_Min_Depth_Clearance)
BASEPLATE_GRID_DEPTH_MARGIN = 18;
//How much shallower the riser is than the core section
RISER_SETBACK = 7.5;

//---------- Small printed screw thread profile ----------

//Distance between threads
SCREW_SM_PITCH = 3;
//Diameter at the outer threads
SCREW_SM_OUTER_DIAMETER = 6.747;
//Angle of one side of the thread
SCREW_SM_FLANK_ANGLE = 60;
//Depth of the thread
SCREW_SM_THREAD_DEPTH = 0.5;
//Diameter of the hole down the middle of the screw
SCREW_SM_INNER_HOLE = 3.3;
