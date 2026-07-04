/*
DeskWare Next - examples/connector_fit_test.scad

Fit-test coupons for every seam connector style: two blocks joined at a
seam with seam_connector_cutouts() subtracted, and the matching loose keys
hovering above their joined positions. Print a coupon pair plus keys to
dial in fit before splitting a big part.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

include <../deskware-next.scad>

SEAM = [60, 19];    //seam cross-section [width, height]
BLOCK_DEPTH = 25;

//Each half is cut at the seam plane, then pulled apart by `gap` so the
//mating faces show and the coupons print as separate parts.
module seam_fit_test(style, gap = 10){
    back(gap/2)
        difference(){
            back(BLOCK_DEPTH/2) cuboid([SEAM.x, BLOCK_DEPTH, SEAM.y], anchor=BOT);
            seam_connector_cutouts(style = style, seam = SEAM, spacing = 40);
        }
    fwd(gap/2)
        difference(){
            fwd(BLOCK_DEPTH/2) cuboid([SEAM.x, BLOCK_DEPTH, SEAM.y], anchor=BOT);
            seam_connector_cutouts(style = style, seam = SEAM, spacing = 40);
        }
    //keys lifted above their joined positions
    up(SEAM.y + 12)
        seam_connector_keys(style = style, seam = SEAM, spacing = 40);
}

xdistribute(spacing = SEAM.x + 30){
    seam_fit_test("dovetail");
    seam_fit_test("dowel");
    seam_fit_test("magnet");
}
