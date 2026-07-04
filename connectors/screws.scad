/*
DeskWare Next - connectors/screws.scad

Printed screw hardware for the drawer handle connection: the T-handled screw
and the female thread socket subtracted from handle pegs. Thread profile
constants live in core/constants.scad and are interop-critical.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//Female thread socket (subtract from parts; attach with inside=true).
module screw_socket_sm(length = 6, d = SCREW_SM_OUTER_DIAMETER, pitch = SCREW_SM_PITCH, flank_angle = SCREW_SM_FLANK_ANGLE, thread_depth = SCREW_SM_THREAD_DEPTH, anchor=TOP, orient=UP, spin=0){
    trapezoidal_threaded_rod(d=d, l=length, pitch=pitch, flank_angle=flank_angle, thread_depth=thread_depth,
                             $fn=50, internal=true, bevel2=true, teardrop=true, blunt_start=false, $slop=0.075,
                             anchor=anchor, orient=orient, spin=spin)
        children();
}

//Printable T-screw that fastens the drawer handle through the drawer front.
module t_screw(d = SCREW_SM_OUTER_DIAMETER, pitch = SCREW_SM_PITCH, flank_angle = SCREW_SM_FLANK_ANGLE, thread_depth = SCREW_SM_THREAD_DEPTH, col = PRIMARY_COLOR){
    color(col)
    up(2)yrot(90)left_half(x=2)right_half(x=-2)
    cuboid([4,14,2.5], chamfer=0.75, edges=[LEFT+FRONT, RIGHT+FRONT, RIGHT+BACK, LEFT+BACK], anchor=BOT){
        attach(TOP, BOT)
            trapezoidal_threaded_rod(d=d, l=10, pitch=pitch, flank_angle=flank_angle, thread_depth=thread_depth,
                                     $fn=50, bevel2=true, blunt_start=false);
    }
}
