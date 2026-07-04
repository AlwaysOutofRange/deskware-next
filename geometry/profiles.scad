/*
DeskWare Next - geometry/profiles.scad

2D cross-section profiles as pure functions returning point lists. These are
the DeskWare design language: sweep them across any width (see
geometry/extrusions.scad) and the part keeps the original look at any size.

Point lists are ported verbatim from legacy/deskware.scad with globals
replaced by parameters.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//Cross-section of the top plate, front-to-back. X spans [-depth/2, depth/2],
//Y spans [0, total_height].
//  total_height   - base of the plate to the top of the lip
//  bottom_chamfer - chamfer where the plate seats onto the base plate
//  top_chamfer    - chamfer at the top outside edges
//  top_inset      - width of the lip bordering the top recess
//  top_recess     - depth of the top recess (insert material thickness)
function top_plate_profile(depth, total_height, bottom_chamfer, top_chamfer, top_inset, top_recess) =
    let(middle = total_height - bottom_chamfer - top_chamfer)
    [
        [-depth/2 + bottom_chamfer, 0], //starting bottom front
        [-depth/2, bottom_chamfer],
        [-depth/2, bottom_chamfer + middle],
        [-depth/2 + top_chamfer, bottom_chamfer + middle + top_chamfer], //top of lip outside
        [-depth/2 + top_chamfer + top_inset, bottom_chamfer + middle + top_chamfer], //top of lip inside
        [-depth/2 + top_chamfer + top_inset, bottom_chamfer + middle + top_chamfer - top_recess], //bottom of recess
        [ depth/2 - top_chamfer - top_inset, bottom_chamfer + middle + top_chamfer - top_recess], //bottom of recess
        [ depth/2 - top_chamfer - top_inset, bottom_chamfer + middle + top_chamfer], //top of lip inside
        [ depth/2 - top_chamfer, bottom_chamfer + middle + top_chamfer], //top of lip outside
        [ depth/2, bottom_chamfer + middle],
        [ depth/2, bottom_chamfer],
        [ depth/2 - bottom_chamfer, 0],
    ];

//Cross-section of the base plate, front-to-back. X spans [-depth/2, depth/2],
//Y spans [0, height + interface_chamfer]. The front (negative X) carries the
//bottom chamfer; the interface lips at both ends locate the top plate.
//  height            - main plate thickness (lip adds interface_chamfer on top)
//  bottom_chamfer    - chamfer at the bottom front edge
//  interface_chamfer - chamfer of the lip the top plate seats against
//  resting_surface   - minimum flat shelf the top plate rests on
//  tile_pocket       - depth of the openGrid tile pocket (sets the well floor)
function base_plate_profile(depth, height, bottom_chamfer, interface_chamfer, resting_surface, tile_pocket) =
    let(well = height - tile_pocket)
    [
        [-depth/2 + bottom_chamfer, 0], //bottom front, bottom of chamfer
        [-depth/2, bottom_chamfer], //bottom front, top of chamfer
        [-depth/2, height + interface_chamfer], //top of front (including lip)
        [-depth/2 + interface_chamfer, height], //top of front (behind lip)
        [-depth/2 + interface_chamfer + resting_surface, height], //top front shelf
        [-depth/2 + interface_chamfer + resting_surface + well, height - well], //front chamfer down to tiles
        [ depth/2 - interface_chamfer - resting_surface - well, height - well], //back chamfer down to tiles
        [ depth/2 - interface_chamfer - resting_surface, height], //top back shelf
        [ depth/2 - interface_chamfer, height], //top of back (behind lip)
        [ depth/2, height + interface_chamfer], //top of back (including lip)
        [ depth/2, 0], //bottom back (no chamfer, matches original)
    ];
