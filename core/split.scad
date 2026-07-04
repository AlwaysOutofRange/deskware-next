/*
DeskWare Next - core/split.scad

Automatic split generation: cut a part that exceeds the print bed into
printable pieces, with mating seam connectors (see connectors/connectors.scad)
at every cut. Works on any child geometry.

Usage:

    split_part(size = [420, 211, 9.5], gap = 20)
        top_plate(width = 420, anchor=BOT);

Convention: the child part must be centered on the origin in X and Y with
Z rising from 0 - i.e. rendered with anchor=BOT at the origin, which is how
every DeskWare Next part is generated.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//Cut children into printable pieces along one axis.
//  size        - [x, y, z] bounding box of the child part
//  axis        - "x" or "y": the axis to cut across
//  max_span    - bed limit for the cut axis (default: the matching MAX_PRINT_*)
//  cuts        - explicit cut positions (centered offsets), or undef to
//                divide evenly into as few pieces as fit. Use this to steer
//                cuts away from features like openGrid fields.
//  seam        - [width, height] of the seam cross-section; defaults to the
//                full part cross-section. Lower the height when the part is
//                thinner at the cut (e.g. a base plate's grid well).
//  style       - seam connector style (dovetail, dowel, magnet)
//  gap         - explode distance between pieces (0 = assembled in place)
//  show_keys   - also render the loose connector keys at each seam
module split_part(
    size,
    axis = "x",
    max_span = undef,
    cuts = undef,
    seam = undef,
    style = CONNECTOR_STYLE,
    spacing = CONNECTOR_SPACING,
    edge_margin = 15,
    gap = 0,
    show_keys = true,
    key_col = PRIMARY_COLOR
){
    assert(axis == "x" || axis == "y", "split_part axis must be \"x\" or \"y\"");
    a = axis == "x" ? 0 : 1;
    span = size[a];
    limit = first_defined([max_span, axis == "x" ? MAX_PRINT_WIDTH : MAX_PRINT_DEPTH]);

    n = first_defined([is_undef(cuts) ? undef : len(cuts) + 1, split_count(span, limit)]);
    cut_list = first_defined([cuts, split_positions(span, n)]);
    seam_sz = first_defined([seam, [size[1-a], size.z]]);

    piece_span = span / n;
    if(piece_span > limit)
        echo(str("WARNING: split pieces are still ", piece_span, " mm across the cut axis (bed limit ", limit, " mm) - add more cuts"));
    debug_echo(str("split_part: ", n, " piece(s) of ~", piece_span, " mm, cuts at ", cut_list));

    //offset of piece i along the cut axis when exploded
    function piece_offset(i) = (i - (n-1)/2) * gap;

    for(i = [0:1:n-1]){
        lo = i == 0     ? -span/2 - 1 : cut_list[i-1];
        hi = i == n-1   ?  span/2 + 1 : cut_list[i];
        translate(axis == "x" ? [piece_offset(i), 0, 0] : [0, piece_offset(i), 0])
        difference(){
            intersection(){
                children();
                translate(axis == "x" ? [(lo+hi)/2, 0, size.z/2] : [0, (lo+hi)/2, size.z/2])
                    cube(axis == "x" ? [hi-lo, size.y+2, size.z+2] : [size.x+2, hi-lo, size.z+2], center=true);
            }
            //connector cutouts at this piece's seams
            for(c = cut_list)
                if(c == lo || c == hi)
                    seam_at(c)
                        seam_connector_cutouts(style=style, seam=seam_sz, spacing=spacing, edge_margin=edge_margin);
        }
    }

    //loose keys, floating at each (possibly exploded) seam
    if(show_keys)
        for(j = [0:1:len(cut_list)-1])
            translate(axis == "x" ? [(j + 0.5 - (n-1)/2) * gap, 0, 0] : [0, (j + 0.5 - (n-1)/2) * gap, 0])
                seam_at(cut_list[j])
                    seam_connector_keys(style=style, seam=seam_sz, spacing=spacing, edge_margin=edge_margin, col=key_col);

    //places children in the seam frame of a cut at offset c
    module seam_at(c){
        if(axis == "x")
            translate([c, 0, 0]) zrot(90) children();
        else
            translate([0, c, 0]) children();
    }
}
