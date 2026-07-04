/*
DeskWare Next - connectors/slides.scad

The drawer slide: the interface between drawer and riser. The same module
produces the rail on the drawer sides and, with delete_tool=true, the
full-size recess subtracted from the riser. Profiles live in
geometry/profiles.scad.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

module drawer_slide(length, delete_tool = false, width = SLIDE_WIDTH, height = SLIDE_HEIGHT, slide_clearance = SLIDE_CLEARANCE, anchor=CENTER, spin=0, orient=UP){
    attachable(anchor, spin, orient, size=[width, length, height]){
        move([-width/2, length/2, -height/2])
            xrot(90)
                linear_sweep(delete_tool ? drawer_slide_cutout_profile(width, height)
                                         : drawer_slide_profile(width, height, slide_clearance),
                             height = length);
        children();
    }
}
