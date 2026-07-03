/*
DeskWare Next - core/utilities.scad

Shared helpers: print-bed fit checking and diagnostic output.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

//True if a part footprint [w, d] fits the bed [w, d], allowing 90-degree rotation.
function fits_print_bed(size, bed) =
    (size.x <= bed.x && size.y <= bed.y) ||
    (size.x <= bed.y && size.y <= bed.x);

//Warn if a part footprint exceeds the print bed. Automatic splitting of
//oversized parts arrives in a later milestone; until then this is the guard.
module check_printable(size, name = "part", bed = [MAX_PRINT_WIDTH, MAX_PRINT_DEPTH]) {
    if (fits_print_bed(size, bed))
        debug_echo(str(name, " (", size.x, " x ", size.y, " mm) fits the print bed"));
    else
        echo(str("WARNING: ", name, " (", size.x, " x ", size.y,
                 " mm) exceeds the print bed (", bed.x, " x ", bed.y, " mm)"));
}

//Echo gated behind the VERBOSE config flag.
module debug_echo(msg, verbose = VERBOSE) {
    if (verbose) echo(msg);
}
