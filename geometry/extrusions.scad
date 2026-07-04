/*
DeskWare Next - geometry/extrusions.scad

Sweep helpers shared by the plate generators. The original monolith carried
duplicated straight/arc path_sweep branches in every builder module; this is
that logic, once.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//Sweep a 2D cross-section across a part's width - straight when arc == 0,
//otherwise along an arc of `arc` degrees with centerline radius `arc_r`.
//Children attach to the underlying path_sweep (anchors "start"/"end" give
//the two swept end faces).
//  profile   - 2D point list (see geometry/profiles.scad)
//  width     - straight span (mm); ignored when arc != 0
//  clearance - shaved off each end of a straight sweep
//  reverse   - sweep in the opposite direction (flips which profile side
//              faces front; the base plate needs this)
//  shift     - lateral offset of the profile within the sweep (the original
//              base plate carries a 0.5mm alignment shift)
module sweep_profile(profile, width, arc = 0, arc_r = 0, clearance = 0, reverse = false, shift = 0){
    if(arc == 0)
        zrot(90)
            right(shift)
            path_sweep(profile, reverse ? [[0, width/2 - clearance], [0, -width/2 + clearance]]
                                        : [[0, -width/2 + clearance], [0, width/2 - clearance]])
                children();
    else
        zrot(reverse ? 90 + arc/2 : 90 - arc/2)
            right(shift)
            path_sweep(profile, arc(r = arc_r, angle = reverse ? -arc : arc))
                children();
}

//Build a top plate from any 2D shape (passed as children). Used for end
//pieces: the shape is typically split down the middle afterwards to produce
//symmetrical caps. Ported from topPlateBuilderShape in legacy/deskware.scad.
//  total_height - base of the plate to the top of the lip
//  top_recess   - depth of the top cutout (insert material thickness)
module top_plate_from_shape(total_height = 9.5, bottom_chamfer = 6, top_chamfer = 1, top_inset = 0.5, top_recess = 1, $fn = 150){
    middle_height = total_height - bottom_chamfer - top_chamfer;

    translate([0,0,bottom_chamfer])
    difference(){
        chamfered_body() children();
        top_cutout() children();
    }

    module chamfered_body(){
        middle_section() children();
        top_chamfer_section() children();
        bottom_chamfer_section() children();
    }

    module top_cutout(){
        translate([0,0,middle_height+top_chamfer-top_recess+0.001])
        linear_extrude(top_recess+0.01)
            offset(delta=-top_inset-top_chamfer)
                children();
    }

    module middle_section()
        linear_extrude(total_height-top_chamfer - bottom_chamfer)
            children();

    module top_chamfer_section()
        intersection(){
            scope_body() children();
            translate([0,0,middle_height])
                roof()
                    children();
        }

    module scope_body()
        translate([0,0,-bottom_chamfer])
            linear_extrude(total_height)
                children();

    module bottom_chamfer_section()
        intersection(){
            mirror([0,0,1])
                roof()
                    children();
            scope_body() children();
        }
}
