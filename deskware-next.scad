/*
DeskWare Next
A modular, fully parameterized fork of DeskWare.

Original design by Hands on Katie, OpenSCAD by BlackjackDuck (Andy),
openGrid by David D. Licensed CC-BY-NC-SA 4.0 - see LICENSE.md.

Include this file to get the whole framework:

    include <deskware-next.scad>

    base_plate();                       // default dimensions from config.scad
    top_plate(width = 250, depth = 220); // or any dimensions you like
*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/joiners.scad>
include <BOSL2/threading.scad>

include <core/constants.scad>
include <config.scad>
include <core/math.scad>
include <core/utilities.scad>
include <core/split.scad>

include <geometry/profiles.scad>
include <geometry/extrusions.scad>

include <connectors/hok.scad>
include <connectors/dovetail.scad>
include <connectors/dowel.scad>
include <connectors/magnets.scad>
include <connectors/tabs.scad>
include <connectors/slides.scad>
include <connectors/screws.scad>
include <connectors/connectors.scad>

include <vendor/opengrid.scad>

include <modules/base_plate.scad>
include <modules/top_plate.scad>
include <modules/dividers.scad>
include <modules/drawer.scad>
include <modules/drawer_handle.scad>
include <modules/riser.scad>
include <modules/backer.scad>
include <modules/section.scad>
