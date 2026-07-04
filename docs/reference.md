# DeskWare Next — Reference

Everything is included through the umbrella file:

```scad
include <deskware-next.scad>
```

All part modules follow the same conventions: **UPPER_SNAKE names in
`config.scad` are defaults**, every dimension is a parameter, parts are
BOSL2 `attachable` (they take `anchor` / `spin` / `orient` and compose with
`attach()`), and derived placements come from the pure functions in
`core/math.scad`. With unchanged config defaults, parts are dimensionally
interchangeable with original DeskWare prints (verified against the
original sources preserved in `legacy/`).

---

## Configuration (`config.scad`)

| Parameter | Default | Meaning |
| --- | --- | --- |
| `PLATE_WIDTH` / `PLATE_DEPTH` | 196 / 196.5 | Core section size, riser center to riser center. Any value — grid fields and connector positions adapt. |
| `TOTAL_HEIGHT` | 107.5 | Bottom of the risers to the top of the top plate. |
| `MAX_PRINT_WIDTH` / `MAX_PRINT_DEPTH` | *your bed* | Print bed limits; parts warn when exceeded, `split_part()` fixes it. |
| `WALL_THICKNESS` / `BOTTOM_THICKNESS` | 3 / 2 | Drawer walls and floors. |
| `CLEARANCE` | 0.15 | Fit clearance between mating parts. |
| `DIVIDER_THICKNESS` | 2 | Drawer compartment divider walls. |
| `CORNER_RADIUS` | 50 | Corner rounding of "Rounded Square" end pieces. |
| `END_STYLE` | `"Rounded Square"` | End cap style: `Rounded`, `Squared`, `Rounded Square`. |
| `TOP_PLATE_*` | — | Thickness, insert recess depth, lip width, chamfer, seating clearance. |
| `DRAWER_*` | — | Mounting method (printed handle / screw pulls), front chamfer, inlay recess. |
| `CONNECTOR_STYLE` | `"dovetail"` | Seam joint style: `dovetail`, `dowel`, `magnet`. |
| `CONNECTOR_SPACING` | 50 | Target distance between seam connectors. |
| `MAGNET_DIAMETER` / `MAGNET_HEIGHT` | 6 / 2 | Disc magnets for magnet seams. |
| `DOWEL_DIAMETER` / `DOWEL_LENGTH` | 4 / 16 | Printed dowel pins for dowel seams. |
| `BASE_PLATE_THICKNESS`, `RISER_WIDTH`, `ADDITIONAL_TOP_PLATE_SUPPORT`, `CURVE_RADIUS`, `VERBOSE` | — | Advanced. |

Interop-critical values (openGrid 28 mm unit, Gridfinity 42 mm, HOK
connector profile, dovetail/tab/slide dimensions, plate interface geometry)
live in `core/constants.scad` and should not normally be changed.

## Parts (`modules/`)

Every module accepts more parameters than shown — open the file for the
full documented signature. Deviating dimensions re-derive everything
inside (grid counts, connector spacings, slide counts).

```scad
//a whole system in one call (display composition)
storage_system(sections = 2, width = 196, depth = 196.5, total_height = 107.5);

//plates
base_plate(width = PLATE_WIDTH, depth = base_plate_depth(PLATE_DEPTH, BASEPLATE_DEPTH_EXTENSION));
top_plate(width = PLATE_WIDTH, thickness = 8.5, recess = 1);

//core section structure
riser(slide_sides = "BOTH", height = 80, chamfer = 0);
riser_split(height1 = 80, height2 = 40);        //stepped-height riser halves
backer(width = PLATE_WIDTH, height = 80);

//end caps (style: "Rounded", "Squared", "Rounded Square")
base_plate_end(style = END_STYLE, side = LEFT);
top_plate_end(style = END_STYLE, side = RIGHT);

//drawers
drawer(height_units = 1, rows = 2, columns = 3);  //built-in compartments
drawer_front(height_units = 1, recess = false);
drawer_handle();
divider_insert(rows = 3, columns = 2);            //drop-in for printed drawers
divider_grid([160, 160, 35], rows = 2, columns = 4); //raw wall lattice
```

Drawer sizing: `drawer()` takes **outside** dimensions; the default width
spans the riser gap and the default interior rounds down to whole
Gridfinity units so bins drop in.

## Connectors (`connectors/`)

Built into parts (interop with original DeskWare): HOK connectors
(`hok_connector()`, printable, joins stacked parts), alignment tabs,
drawer slides, printed screws (`t_screw()`, `screw_socket_sm()`).

Seam joints, for splitting and side-by-side joining:

```scad
//negative space: subtract from BOTH halves of a seam (they mate by symmetry)
seam_connector_cutouts(style = CONNECTOR_STYLE, seam = [width, height]);
//the loose printed keys (dovetail keys / dowel pins; magnets print nothing)
seam_connector_keys(style = CONNECTOR_STYLE, seam = [width, height]);
```

Seam frame: seam plane = XZ, X along the seam, Z up from the part bottom,
parts occupy +Y/−Y. Primitives are also available directly:
`dovetail_male()` / `dovetail_female()` / `dovetail_socket_pair()`,
`dowel_pin()` / `dowel_hole()`, `magnet_pocket()`.

## Splitting oversized parts (`core/split.scad`)

```scad
split_part(size = [420, 211, 9.5],   //bbox of the child (anchor=BOT at origin)
           axis = "x",               //"x", "y", or "both" (grid split)
           style = "dovetail",       //dovetail, dowel, magnet, or puzzle
           cuts = undef,             //explicit cut positions (steer around features)
           seam = undef,             //[width, height]: height override for the joints
           keepout = 15,             //drop connectors this close to a crossing seam
           show_keys = true,         //render the loose keys next to each seam
           gap = 20)                 //explode distance (0 = assembled)
    top_plate(width = 420, anchor=BOT);
```

Derives the piece count from `MAX_PRINT_*`, subtracts mating seam cutouts
at every cut, and renders the loose keys. `axis="both"` grid-splits a part
that exceeds the bed in both directions, keeping connectors away from the
seam crossings. `style="puzzle"` cuts an interlocking glue seam through the
whole cross-section instead of using loose keys (exactly 2 pieces on one
axis) - the right choice for thin-walled parts like drawers, fronts, and
backers, where a key would poke through the walls. Use `seam=` where a part
is thinner at the cut (e.g. `[0, BASEPLATE_TILE_POCKET]` puts a base
plate's dowels in the solid floor under its grid well) and `cuts=` to keep
seams out of grid fields.

`examples/test_print_200.scad` exercises all of this: a complete
200 x 200.5 x 107.5 mm system where every part is pre-split for a
175 x 175 mm bed, selectable per print plate through the Customizer.

## Derivation functions (`core/math.scad`)

All pure, all explicit-input. The ones you'll actually reach for:

| Function | Gives you |
| --- | --- |
| `core_section_height(total, top_t, base_t)` | Riser/backer height from a total height. |
| `base_plate_depth(core_d, ext)` / `top_plate_depth(bp_d, chamfer, clr)` / `riser_depth(core_d, setback)` | Companion part depths. |
| `drawer_outside_width(core_w, riser_w)` / `drawer_outside_depth(...)` / `drawer_height(units, sep, clr)` | Drawer envelope. |
| `slide_count(riser_h, ...)` | Drawer slots on a riser. |
| `grid_units_fit(span, unit, margin)` / `grid_span(units, unit)` | Grid fitting. |
| `hok_spacing_depth(units, unit)` / `hok_spacing_back(units, unit)` | HOK cutout spacing (must match between stacked parts). |
| `compartment_size(span, count, wall)` | Divider compartment size. |
| `connector_positions(span, spacing, margin)` | Seam connector layout. |
| `split_count(span, max)` / `split_positions(span, n)` | Split planning. |

## Provenance and verification

The original monolithic sources are preserved unmodified in `legacy/` and
serve as the regression oracle: every ported part (plates, drawers,
fronts, handle, riser, backer, dovetails, T-screw) was exported to STL at
default dimensions alongside its legacy counterpart and matched with zero
volume and bounding-box deltas (boolean differences render empty).
openGrid is by David D, ported verbatim in `vendor/`. License: CC BY-NC-SA
4.0 — see [LICENSE.md](../LICENSE.md).
