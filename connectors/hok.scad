/*
DeskWare Next - connectors/hok.scad

HOK ("Hands on Katie") connector: a printable double-sided clip that joins
DeskWare parts, plus the matching cutout (delete tool) that parts subtract
from themselves. The cutout profile is interop-critical - it must match
original DeskWare prints - so its point lists stay verbatim.

Placement spacing helpers live in core/math.scad (hok_spacing_depth /
hok_spacing_back).

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//The printable connector itself (from legacy/HOK Connector.scad).
//  side_depth      - depth (mm) of one clip side
//  pre_tab_width   - width (mm) of the connector before the tabs
//  total_thickness - overall thickness (mm), chamfers included
//  half            - print only one side (for part edges)
module hok_connector(side_depth = 15, pre_tab_width = 15, total_thickness = HOK_CONNECTOR_THICKNESS, half = false, col = PRIMARY_COLOR, spin = 0, orient = UP, anchor = CENTER){

    //Thickness of the chamfer for one side
    chamfer_thickness = 0.5;

    cutout_depth = side_depth - 1.5;
    distance_between_cutouts = pre_tab_width - 7;

    middle_thickness = total_thickness - chamfer_thickness*2;

    attachable(anchor, spin, orient, size=[half ? side_depth : side_depth*2, pre_tab_width, total_thickness]){
        recolor(col)
        translate([half ? -side_depth/2 : 0, pre_tab_width/2, -total_thickness/2])
        if(half)
            right_half()
                connector_full();
        else
            connector_full();
        children();
    }

    module connector_full(){
        diff(){
            force_tag("")
                chamfered_profile(profile = outside_profile_full, middle_thickness = middle_thickness, chamfer_thickness = chamfer_thickness);
            //cutouts
            force_tag("remove")
                translate([0,-pre_tab_width/2,0])
                down(0.01)
                    //copy top and bottom
                    xflip_copy(offset = 1 - 0.05)
                        //copy left and right
                        yflip_copy(offset = -distance_between_cutouts/2)
                            cutout();
            //cutout inside chamfer
            tag("keep")
                right(0.05)
                fwd(pre_tab_width/2)
                    cuboid([side_depth*2-1 - 0.05, distance_between_cutouts+2, total_thickness], chamfer=1, edges = [FRONT, BACK], anchor=BOT);
        }
    }

    module cutout(){
        linear_extrude(height = total_thickness + 0.02)
            polygon(inside_cutout_profile(cutout_depth));
    }

    //turtle points for half the outside profile (mirrored by concatenation)
    outside_profile_half_turtle = [
        "move", 5 - (15 - side_depth)/2, //middle to start of first tab
        "left", 45, //start first tab
        "move", 0.54,
        "arcright", 1, 45,
        "move", 1.86,
        "arcright", 1, 45,
        "move", 0.54,
        "left", 45, //end first tab
        "move", 3.156 - (15 - side_depth)/2, //top of first tab to start of curve inward
        "arcright", 2, 45,
        "move", 1.172,
        "arcright", 2, 45,
        "move", pre_tab_width - 5.657, //middle span (equals 9.343 at standard 15mm width)
        "arcright", 2, 45,
        "move", 1.172,
        "arcright", 2, 45,
        "move", 3.156 - (15 - side_depth)/2,
        "left", 45,
        "move", 0.54,
        "arcright", 1, 45,
        "move", 1.8,
        "arcright", 1, 45,
        "move", 0.54,
        "left", 45,
        "move", 5 - (15 - side_depth)/2,
    ];

    //join two turtle paths to effectively mirror
    outside_profile_full = turtle(concat(outside_profile_half_turtle, outside_profile_half_turtle));

    function inside_cutout_profile(cutout_depth) =
        turtle([
            "move", cutout_depth,
            "right", 90 + 45,
            "move", 3.474,
            "arcright", 1, 45,
            "move", 9.336 - (15 - side_depth),
            "arcright", 1, 90,
        ]);

    //take a profile and chamfer top and bottom
    module chamfered_profile(profile, middle_thickness, chamfer_thickness){
        total_thickness = middle_thickness + chamfer_thickness*2;

        intersection(){
            main_body();
            scope_body();
        }

        module main_body(){
            //top
            up(chamfer_thickness + middle_thickness)
                roof()
                    polygon(profile);
            //mid
            up(chamfer_thickness)
                linear_extrude(height = middle_thickness) polygon(profile);
            //bot
            up(chamfer_thickness)
                zflip()
                    roof()
                        polygon(profile);
        }
        module scope_body(){
            linear_extrude(height = total_thickness) polygon(profile);
        }
    }
}

//The cutout a part subtracts to receive an HOK connector (from
//HOKConnectorDeleteTool in legacy/deskware.scad). Profile is verbatim.
module hok_connector_cutout(width = HOK_CONNECTOR_WIDTH, thickness = HOK_CONNECTOR_THICKNESS, height = HOK_CONNECTOR_HEIGHT, anchor=CENTER, spin=0, orient=UP){
    chamfer = 0.5;

    attachable(anchor, spin, orient, size=[width, thickness, height]){
        down(height/2)xrot(90)
            skin(
                [mirrored_profile(cutout_path_chamfered()), mirrored_profile(cutout_path_full()), mirrored_profile(cutout_path_full()), mirrored_profile(cutout_path_chamfered())],
                z=[-thickness/2, -thickness/2+chamfer, thickness/2-chamfer, thickness/2],
                slices=0
            );
        children();
    }

    //outer profile of connector cutout (half; mirrored below)
    function cutout_path_full() = [
        [-7.9, 0],
        [-7.9, 4.875],
        [-8.9, 5.862],
        [-8.9, 8.084],
        [-7.9, 9.097],
        [-7.9, 13.083],
        [-5.783, 15.2],
        //[0, 15.2] midpoint
    ];

    //smaller profile used for the chamfered top/bottom layers
    function cutout_path_chamfered() = [
        [-7.4, 0],
        [-7.4, 5.084],
        [-8.4, 6.071],
        [-8.4, 7.879],
        [-7.4, 8.892],
        [-7.4, 12.876],
        [-5.576, 14.7],
        //[0, 14.7] midpoint
    ];

    function mirror_x(pt) = [-pt[0], pt[1]];

    //mirror in reverse index order so the final perimeter is a continuous loop
    function mirrored_profile(path_input) =
        concat(
            path_input,
            [for(i = [len(path_input)-1 : -1 : 0]) mirror_x(path_input[i])]
        );
}
