/*
DeskWare Next - examples/plates_demo.scad

Two plate stacks side by side:
- left:  default dimensions from config.scad (196mm core, matches original DeskWare)
- right: arbitrary dimensions (250 x 220mm core) to show that grid pockets,
  connector spacing, and supports all derive from the parent dimensions.

Set EXPLODE to lift the top plates off the base plates.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

include <../deskware-next.scad>

//Lift the top plate off the base plate for a better look.
EXPLODE = 30;

//---------- default size ----------

base_plate(anchor=BOT);
up(BASE_PLATE_THICKNESS + CLEARANCE + EXPLODE)
    top_plate(anchor=BOT);

//---------- arbitrary size: 250 x 220 core ----------

demo_width = 250;
demo_core_depth = 220;
demo_bp_depth = base_plate_depth(demo_core_depth, BASEPLATE_DEPTH_EXTENSION);
demo_tp_depth = top_plate_depth(demo_bp_depth, INTERFACE_CHAMFER, TOP_PLATE_CLEARANCE);

right((PLATE_WIDTH + demo_width)/2 + 40){
    base_plate(width = demo_width, depth = demo_bp_depth, anchor=BOT);
    up(BASE_PLATE_THICKNESS + CLEARANCE + EXPLODE)
        top_plate(width = demo_width, depth = demo_tp_depth, anchor=BOT);
}
