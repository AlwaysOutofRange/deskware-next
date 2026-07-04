/*
DeskWare Next - connectors/dovetail.scad

Dovetail pair used to join base plate sections. Wraps BOSL2's dovetail()
with the DeskWare interop dimensions from core/constants.scad.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//Printable double-ended male dovetail key.
module dovetail_male(width = DOVETAIL_WIDTH, height = DOVETAIL_HEIGHT, depth = DOVETAIL_DEPTH, chamfer = DOVETAIL_CHAMFER, col = PRIMARY_COLOR, anchor=CENTER, spin = 0, orient = UP){
    //male sits 0.6 shallower than the female socket so the joint pulls tight
    slide = depth - 0.6;
    attachable(anchor, spin, orient, size=[width, height*2, slide]){
        recolor(col)
        mirror_copy([0,1,0])
            dovetail("male", slide=slide, width=width, height=height, chamfer=chamfer, taper = -3, slope = 4, anchor=BOT, orient=FRONT);
        children();
    }
}

//Female socket, subtracted from parts (attach with inside=true).
module dovetail_female(width = DOVETAIL_WIDTH, height = DOVETAIL_HEIGHT, depth = DOVETAIL_DEPTH, chamfer = DOVETAIL_CHAMFER, anchor=BOT, spin = 0, orient = DOWN){
    dovetail("female", slide=depth, width=width, height=height, chamfer=chamfer, slope = 4, taper = -3, $slop = 0, anchor=anchor, spin=spin, orient=orient)
        children();
}

//Mirrored pair of female sockets spanning a seam (subtract from both
//halves at once): the negative that dovetail_male() drops into. Mirrors
//the male's construction so the pair always mates.
module dovetail_socket_pair(width = DOVETAIL_WIDTH, height = DOVETAIL_HEIGHT, depth = DOVETAIL_DEPTH, chamfer = DOVETAIL_CHAMFER, anchor=CENTER, spin = 0, orient = UP){
    attachable(anchor, spin, orient, size=[width, height*2, depth]){
        mirror_copy([0,1,0])
            dovetail("female", slide=depth, width=width, height=height, chamfer=chamfer, taper = -3, slope = 4, $slop = 0, anchor=BOT, orient=FRONT);
        children();
    }
}
