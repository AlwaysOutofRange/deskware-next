/*
DeskWare Next - connectors/tabs.scad

Alignment tab (from TopPlateTab in legacy/deskware.scad). The same shape
serves as the positive tab on base plates/backers and, with delete_tool=true,
as the slightly enlarged slot subtracted from top plates and risers.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

module alignment_tab(height = 19, delete_tool = false, width = TAB_WIDTH, depth = TAB_DEPTH, chamfer = TAB_CHAMFER, clearance = CLEARANCE, anchor=CENTER, spin=0, orient=UP){
    cuboid([delete_tool ? width + clearance*2 : width,
            delete_tool ? depth + clearance*2 : depth,
            delete_tool ? height + clearance : height],
           chamfer=chamfer, except=BOT, anchor=anchor, spin=spin, orient=orient)
        children();
}
