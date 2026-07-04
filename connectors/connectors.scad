/*
DeskWare Next - connectors/connectors.scad

The seam joint system: one API that lays out connectors along a seam
between two parts, dispatching on CONNECTOR_STYLE (dovetail, dowel, magnet).
This is the foundation for automatic split generation (Milestone 7): cut an
oversized part, subtract seam_connector_cutouts() from both halves, print
seam_connector_keys() loose.

Seam frame convention: the seam is the XZ plane (Y = 0). X runs along the
seam width, Z is up with Z = 0 at the part bottom, and the two parts occupy
+Y and -Y. All cutouts are symmetric about the seam plane, so subtracting
the same set from both halves gives mating features.

Note: HOK connectors are not a seam style - they join STACKED parts through
vertically aligned slots and are already built into the plates and risers.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//Connector cutouts along a seam (subtract from BOTH halves).
//  seam      - [width, height] of the seam cross-section
//  positions - explicit X offsets, or undef to derive from spacing
module seam_connector_cutouts(
    style = CONNECTOR_STYLE,
    seam = [100, 19],
    positions = undef,
    spacing = CONNECTOR_SPACING,
    edge_margin = 15,
    dovetail_width = DOVETAIL_WIDTH,
    dovetail_height = DOVETAIL_HEIGHT,
    dovetail_depth = DOVETAIL_DEPTH,
    dowel_d = DOWEL_DIAMETER,
    dowel_length = DOWEL_LENGTH,
    magnet_d = MAGNET_DIAMETER,
    magnet_height = MAGNET_HEIGHT
){
    assert(in_list(style, ["dovetail", "dowel", "magnet"]),
           str("unknown seam connector style: ", style));
    pos = first_defined([positions, connector_positions(seam.x, spacing, edge_margin)]);

    for(x = pos){
        //dovetail: shallow socket pair open at the top surface; the key
        //drops in from above and locks the halves laterally
        if(style == "dovetail")
            translate([x, 0, seam.y - dovetail_depth/2 + 0.01])
                dovetail_socket_pair(width=dovetail_width, height=dovetail_height, depth=dovetail_depth);
        //dowel: through-seam hole at mid height
        else if(style == "dowel")
            translate([x, 0, seam.y/2])
                ycyl(d = dowel_d + 0.3, l = dowel_length + 0.6, $fn = 32);
        //magnet: flush pocket on each face
        else if(style == "magnet")
            translate([x, 0, seam.y/2])
                ycyl(d = magnet_d + 0.2, l = (magnet_height + 0.05)*2, $fn = 32);
    }
}

//The loose printed connectors for a seam, shown in their joined positions.
//Magnet seams have nothing to print (the magnets are the connectors).
module seam_connector_keys(
    style = CONNECTOR_STYLE,
    seam = [100, 19],
    positions = undef,
    spacing = CONNECTOR_SPACING,
    edge_margin = 15,
    dovetail_width = DOVETAIL_WIDTH,
    dovetail_height = DOVETAIL_HEIGHT,
    dovetail_depth = DOVETAIL_DEPTH,
    dowel_d = DOWEL_DIAMETER,
    dowel_length = DOWEL_LENGTH,
    col = PRIMARY_COLOR
){
    assert(in_list(style, ["dovetail", "dowel", "magnet"]),
           str("unknown seam connector style: ", style));
    pos = first_defined([positions, connector_positions(seam.x, spacing, edge_margin)]);

    if(style == "magnet")
        debug_echo("magnet seam: insert magnets in the pockets, nothing to print");

    for(x = pos){
        if(style == "dovetail")
            translate([x, 0, seam.y - (dovetail_depth - 0.6)/2])
                dovetail_male(width=dovetail_width, height=dovetail_height, depth=dovetail_depth, col=col);
        else if(style == "dowel")
            translate([x, 0, seam.y/2])
                dowel_pin(d=dowel_d, length=dowel_length, col=col, orient=BACK);
    }
}
