/*
DeskWare Next - examples/split_demo.scad

Automatic split generation: a 420mm top plate - too wide for the configured
print bed - cut into printable pieces with mating seam connectors, shown
exploded with the loose keys floating at each seam.

- back:  dovetail keys (drop in from the top; visible in the recess, hidden
         under an insert material)
- front: dowel pins (fully invisible once assembled)

The seam position and cross-section can be steered per part with the
`cuts` and `seam` parameters - e.g. keep cuts out of a base plate's
openGrid field, or lower the seam height to its grid well.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

include <../deskware-next.scad>

BIG_WIDTH = 420;

tp_depth = top_plate_depth(base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION), INTERFACE_CHAMFER, TOP_PLATE_CLEARANCE);
tp_size = [BIG_WIDTH, tp_depth, TOP_PLATE_THICKNESS + TOP_PLATE_RECESS];

//dovetail split
back(tp_depth/2 + 30)
    split_part(size = tp_size, style = "dovetail", gap = 30)
        top_plate(width = BIG_WIDTH, anchor=BOT);

//dowel split
fwd(tp_depth/2 + 30)
    split_part(size = tp_size, style = "dowel", gap = 30)
        top_plate(width = BIG_WIDTH, anchor=BOT);
