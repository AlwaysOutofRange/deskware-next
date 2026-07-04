/*
DeskWare Next - connectors/dowel.scad

Printable dowel pins and their holes, for aligning and joining parts across
a seam. The hole is oversized by `fit` per side; the pin is nominal.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//Printable dowel pin (print vertically).
module dowel_pin(d = DOWEL_DIAMETER, length = DOWEL_LENGTH, chamfer = 0.5, col = PRIMARY_COLOR, anchor=CENTER, spin=0, orient=UP){
    color(col)
    cyl(d = d, h = length, chamfer = chamfer, $fn = 32, anchor=anchor, spin=spin, orient=orient)
        children();
}

//Hole for one side of a dowel joint (subtract; attach with inside=true).
//Depth is half the pin length plus seating room.
module dowel_hole(d = DOWEL_DIAMETER, length = DOWEL_LENGTH, fit = 0.15, anchor=CENTER, spin=0, orient=UP){
    cyl(d = d + fit*2, h = length/2 + fit*2, $fn = 32, anchor=anchor, spin=spin, orient=orient)
        children();
}
