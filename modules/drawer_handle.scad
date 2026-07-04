/*
DeskWare Next - modules/drawer_handle.scad

The printed drawer handle: a bar with two pegs that pass through the drawer
front and box wall, fastened from inside with t_screw()s (see
connectors/screws.scad). Ported from DrawerHandle in legacy/deskware.scad.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//  outside_width - total width of the handle bar
//  inside_depth  - how far the bar stands off the drawer front
//  thickness     - bar cross-section (square)
module drawer_handle(
    outside_width = 100,
    inside_depth = 15,
    thickness = 10,
    handle_screw_spacing = HANDLE_SCREW_SPACING,
    col = DRAWER_HANDLE_COLOR,
    spin = 0, orient = UP, anchor = CENTER
){
    attachable(anchor, spin, orient, size=[outside_width, inside_depth + thickness, thickness]){
        recolor(col)
        fwd(-thickness/2 + (thickness+inside_depth)/2)
        diff("thread"){
            //handle bar
            cuboid([outside_width, thickness, thickness]);
            //pegs with threaded sockets, fixed at standard spacing
            back(inside_depth/2+thickness/2-0.01)
            xcopies(spacing = handle_screw_spacing)
                cuboid([thickness, inside_depth, thickness])
                    tag("thread")
                    attach(BACK, BOT, inside=true, shiftout=0.01)
                        screw_socket_sm();
        }
        children();
    }
}
