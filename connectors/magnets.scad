/*
DeskWare Next - connectors/magnets.scad

Magnet pockets for magnet-aligned joints. A pocket on each side of a seam
holds a disc magnet flush with the mating face; the magnets are the
"connector". Press-fit by default.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//Pocket for one disc magnet (subtract; attach with inside=true).
//  fit - radial clearance per side; 0.1 gives a press fit in most printers
module magnet_pocket(d = MAGNET_DIAMETER, height = MAGNET_HEIGHT, fit = 0.1, anchor=CENTER, spin=0, orient=UP){
    cyl(d = d + fit*2, h = height + fit, $fn = 32, anchor=anchor, spin=spin, orient=orient)
        children();
}
