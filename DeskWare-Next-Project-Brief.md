# DeskWare Next -- Project Brief

## Overview

We are creating **DeskWare Next**, a fork of the original DeskWare
OpenSCAD project.

The goal is **not** to redesign the appearance of DeskWare. The goal is
to make the codebase modular, maintainable, and fully parameterized
while keeping the original design language.

DeskWare Next should allow users to generate storage systems of **any
dimensions**, instead of relying on fixed plate sizes like 196 mm.

------------------------------------------------------------------------

## Core Goals

-   Modular architecture
-   Clean OpenSCAD code
-   Minimal duplicated code
-   No magic numbers
-   Everything driven by parameters
-   Easy to extend
-   Easy to maintain
-   Easy to create new accessories

------------------------------------------------------------------------

## Design Philosophy

Instead of many specialized modules:

``` scad
drawer_small()
drawer_large()
drawer_xl()
plate_196()
plate_half()
```

Everything should become generic.

Example:

``` scad
plate(
    width = 180,
    depth = 180
);

drawer(
    width = 180,
    depth = 180,
    height = 60,
    rows = 2,
    columns = 3
);
```

------------------------------------------------------------------------

## Main Configuration

Every important dimension should come from a single configuration file.

Example:

``` scad
PLATE_WIDTH
PLATE_DEPTH

WALL_THICKNESS
BOTTOM_THICKNESS

CLEARANCE

CORNER_RADIUS

GRID_SIZE

MAGNET_DIAMETER
MAGNET_HEIGHT

PRINT_BED_SIZE

CONNECTOR_STYLE
```

Nothing should depend on hardcoded values.

------------------------------------------------------------------------

## Dynamic System

Every object should calculate its own dimensions.

Examples include:

-   Drawer wall spacing
-   Divider spacing
-   Grid placement
-   Clip locations
-   Magnet positions
-   Screw positions
-   Finger cutouts
-   Corner radii

All of these should derive from the parent object's dimensions.

------------------------------------------------------------------------

## Printer Independence

DeskWare Next should not assume any printer size.

Instead:

``` scad
MAX_PRINT_WIDTH
MAX_PRINT_DEPTH
```

If an object exceeds these dimensions it should automatically support
splitting into multiple printable pieces.

Future split methods:

-   Dowels
-   Dovetails
-   Puzzle joints
-   Magnet alignment

------------------------------------------------------------------------

## File Structure

``` text
deskware-next/

config.scad

core/
    constants.scad
    math.scad
    utilities.scad

geometry/
    rounded_box.scad
    fillets.scad
    chamfers.scad

connectors/
    dovetail.scad
    dowel.scad
    magnets.scad

modules/
    plate.scad
    drawer.scad
    organizer.scad
    riser.scad

accessories/
    pen_holder.scad
    tray.scad
    bins.scad

examples/
```

No 90,000-line single file.

------------------------------------------------------------------------

## Coding Standards

Every module should:

-   Have a clear purpose
-   Accept parameters
-   Avoid global state
-   Avoid duplicated calculations
-   Use descriptive variable names
-   Document parameters

Example:

``` scad
module drawer(
    width,
    depth,
    height,
    wall,
    clearance,
    rows,
    columns
)
```

------------------------------------------------------------------------

## Compatibility

Maintain the visual identity of the original DeskWare where practical.

Existing accessories should be portable with minimal changes.

Do not intentionally change aesthetics unless necessary.

------------------------------------------------------------------------

## Long-Term Vision

DeskWare Next should become a reusable framework rather than a fixed
collection of models.

Future additions may include:

-   Modular cable management
-   Monitor risers
-   Keyboard trays
-   Laptop stands
-   Shelving
-   Pegboard integration
-   Tool holders
-   Gridfinity compatibility
-   Parametric organizers

------------------------------------------------------------------------

## Development Strategy

Development should happen in small milestones.

### Milestone 1

-   Project structure
-   Configuration system
-   Shared utility functions

### Milestone 2

-   Dynamic plate generator

### Milestone 3

-   Dynamic drawer generator

### Milestone 4

-   Dynamic divider system

### Milestone 5

-   Connector system

### Milestone 6

-   Accessories

### Milestone 7

-   Automatic split generation

### Milestone 8

-   Documentation and examples

------------------------------------------------------------------------

## Guiding Principle

If a number appears more than once, it probably belongs in a parameter
or a shared calculation.

Every feature should be designed so changing a single dimension
propagates naturally throughout the model.

The end result should feel less like a collection of individual models
and more like a **parametric desk organization framework**.
