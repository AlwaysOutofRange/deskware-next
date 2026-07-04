/*
DeskWare Next - core/split.scad

Automatic split generation: cut a part that exceeds the print bed into
printable pieces, with mating seam connectors (see connectors/connectors.scad)
at every cut. Works on any child geometry.

    split_part(size = [420, 211, 9.5], gap = 20)
        top_plate(width = 420, anchor=BOT);

Modes:
- axis "x" or "y": cuts across one axis, loose-key connectors at each seam
- axis "both": grid split for parts exceeding the bed in both directions;
  connectors near seam crossings are dropped automatically (keepout)
- style "puzzle": interlocking glue seam through the whole cross-section
  (BOSL2 partition) - the only viable split for thin-walled parts like
  drawers; supports exactly 2 pieces on one axis, prints no loose keys

Convention: the child part must be centered on the origin in X and Y with
Z rising from 0 - i.e. rendered with anchor=BOT at the origin, which is how
every DeskWare Next part is generated.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//Cut children into printable pieces.
//  size        - [x, y, z] bounding box of the child part
//  axis        - "x", "y", or "both"
//  max_span    - bed limit override (default: the matching MAX_PRINT_*)
//  cuts        - explicit cut positions (single-axis modes only)
//  seam        - [width, height] of the seam cross-section; defaults to the
//                full part cross-section. Lower the height when the part is
//                thinner at the cut (e.g. a base plate's grid well).
//  style       - seam connector style (dovetail, dowel, magnet, puzzle)
//  keepout     - drop connectors closer than this to a crossing seam
//  gap         - explode distance between pieces (0 = assembled in place)
//  show_keys   - also render the loose connector keys at each seam
//  puzzle_cutsize - tooth size of puzzle seams
module split_part(
    size,
    axis = "x",
    max_span = undef,
    cuts = undef,
    seam = undef,
    style = CONNECTOR_STYLE,
    spacing = CONNECTOR_SPACING,
    edge_margin = 15,
    keepout = 15,
    gap = 0,
    show_keys = true,
    key_col = PRIMARY_COLOR,
    puzzle_cutsize = 10
){
    assert(axis == "x" || axis == "y" || axis == "both", "split_part axis must be \"x\", \"y\", or \"both\"");

    do_x = axis != "y";
    do_y = axis != "x";
    limit_x = first_defined([max_span, MAX_PRINT_WIDTH]);
    limit_y = first_defined([max_span, MAX_PRINT_DEPTH]);

    nx = !do_x ? 1 : (!is_undef(cuts) && axis == "x") ? len(cuts) + 1 : split_count(size.x, limit_x);
    ny = !do_y ? 1 : (!is_undef(cuts) && axis == "y") ? len(cuts) + 1 : split_count(size.y, limit_y);
    assert(is_undef(cuts) || axis != "both", "explicit cuts are only supported for single-axis splits");

    cx = do_x ? ((!is_undef(cuts) && axis == "x") ? cuts : split_positions(size.x, nx)) : [];
    cy = do_y ? ((!is_undef(cuts) && axis == "y") ? cuts : split_positions(size.y, ny)) : [];

    if(style == "puzzle"){
        assert(axis != "both" && (axis == "x" ? nx : ny) == 2,
               "puzzle splits support exactly 2 pieces on one axis");
        //Interlocking glue seam through the full cross-section. The teeth
        //are sized to tile the whole cut line (odd count, so the seam stays
        //symmetric): BOSL2's partition mask ends at the last tooth and
        //would otherwise eat any straight remainder of the cut line. The
        //mask spans size exactly, so pad it: +1 along the cut line (it also
        //shrinks by $slop) and a hair in z; pass a size.z that covers any
        //features poking above the part (e.g. a drawer front's keys).
        cutline = (axis == "x" ? size.y : size.x) + 1;
        teeth = let(r = round(cutline / (puzzle_cutsize*2))) is_odd(r) ? r : r + 1;
        $slop = CLEARANCE; //mating clearance at the seam
        up(size.z/2)
            partition(size = size + (axis == "x" ? [0, 1, 0.02] : [1, 0, 0.02]),
                      spread = max(gap, puzzle_cutsize*2),
                      cutsize = [cutline/teeth * (1 - 1e-9), puzzle_cutsize],
                      cutpath = "dovetail",
                      spin = axis == "x" ? -90 : 0)
                down(size.z/2)
                    children();
    }
    else split_grid() children();

    module split_grid(){
        //seam widths always span the part; only the height is overridable
        seam_h = is_undef(seam) ? size.z : seam.y;
        seam_x_sz = [size.y, seam_h]; //seams from x-cuts
        seam_y_sz = [size.x, seam_h]; //seams from y-cuts

        //connector layouts, dropping positions too close to a crossing seam
        pos_x = filter_positions(connector_positions(seam_x_sz.x, spacing, edge_margin), cy);
        pos_y = filter_positions(connector_positions(seam_y_sz.x, spacing, edge_margin), cx);

        px = size.x / nx;
        py = size.y / ny;
        if((do_x && px > limit_x) || (do_y && py > limit_y))
            echo(str("WARNING: split pieces are still ", px, " x ", py,
                     " mm (bed limit ", limit_x, " x ", limit_y, " mm) - add more cuts or use axis=\"both\""));
        debug_echo(str("split_part: ", nx, " x ", ny, " piece(s) of ~", px, " x ", py, " mm"));

        for(ix = [0:1:nx-1], iy = [0:1:ny-1]){
            xlo = ix == 0      ? -size.x/2 - 1 : cx[ix-1];
            xhi = ix == nx-1   ?  size.x/2 + 1 : cx[ix];
            ylo = iy == 0      ? -size.y/2 - 1 : cy[iy-1];
            yhi = iy == ny-1   ?  size.y/2 + 1 : cy[iy];
            translate([offset_along(ix, nx), offset_along(iy, ny), 0])
            difference(){
                intersection(){
                    children();
                    translate([(xlo+xhi)/2, (ylo+yhi)/2, size.z/2])
                        cube([xhi-xlo, yhi-ylo, size.z+2], center=true);
                }
                for(c = cx) if(c == xlo || c == xhi)
                    translate([c, 0, 0]) zrot(90)
                        seam_connector_cutouts(style=style, seam=seam_x_sz, positions=pos_x, spacing=spacing, edge_margin=edge_margin);
                for(c = cy) if(c == ylo || c == yhi)
                    translate([0, c, 0])
                        seam_connector_cutouts(style=style, seam=seam_y_sz, positions=pos_y, spacing=spacing, edge_margin=edge_margin);
            }
        }

        //loose keys, each following its (possibly exploded) piece pair
        if(show_keys){
            for(j = [0:1:len(cx)-1], p = pos_x)
                translate([(j + 0.5 - (nx-1)/2) * gap, offset_along(row_of(p, cy), ny), 0])
                    translate([cx[j], 0, 0]) zrot(90)
                        seam_connector_keys(style=style, seam=seam_x_sz, positions=[p], col=key_col);
            for(j = [0:1:len(cy)-1], p = pos_y)
                translate([offset_along(row_of(p, cx), nx), (j + 0.5 - (ny-1)/2) * gap, 0])
                    translate([0, cy[j], 0])
                        seam_connector_keys(style=style, seam=seam_y_sz, positions=[p], col=key_col);
        }
    }

    //explode offset of piece i out of n
    function offset_along(i, n) = (i - (n-1)/2) * gap;
    //which piece row/column a seam position falls into
    function row_of(p, cuts_list) = len([for(c = cuts_list) if(c < p) 1]);
    //drop connector positions within keepout of a perpendicular cut
    function filter_positions(ps, perp) =
        [for(p = ps) if(len([for(c = perp) if(abs(p - c) < keepout) 1]) == 0) p];
}
