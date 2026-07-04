/*
DeskWare Next - examples/compact_system.scad

A complete system scaled down to 140 x 140.5mm sections - every part
(base plate 151mm deep, riser 133mm, drawers 118 x 132mm) prints whole on
a small bed such as the configured 175mm one. The point of the exercise:
nothing here is a special "mini" variant, it is the same modules at
different arguments.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

include <../deskware-next.scad>

storage_system(
    sections = 2,
    width = 140,
    depth = 140.5,
    total_height = 107.5
);
