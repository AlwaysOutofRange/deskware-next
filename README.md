# DeskWare Next

A modular, fully parameterized fork of [DeskWare](https://makerworld.com/)
(design by Hands on Katie, OpenSCAD by BlackjackDuck). Same design language,
new architecture: every part is generated from parameters, so storage systems
of **any dimensions** can be produced — no more fixed 196 mm plates.

## Requirements

- OpenSCAD (recent version; developed against 2026.06)
- [BOSL2](https://github.com/BelfrySCAD/BOSL2) on the OpenSCAD library path

## Usage

```scad
include <deskware-next.scad>

base_plate();                        // defaults from config.scad (196 mm, interchangeable with original DeskWare)
base_plate(width = 250, depth = 230); // or any size — grid pockets and connectors adapt
```

Defaults live in `config.scad`; part modules take them as parameter defaults,
so you can edit the config or pass arguments per part. With unchanged
defaults, parts are dimensionally interchangeable with original DeskWare
prints.

## Structure

| Path | Contents |
| --- | --- |
| `config.scad` | User-facing parameters (dimensions, clearances, print bed, colors) |
| `core/` | Fixed system constants, pure derivation functions, shared helpers |
| `geometry/` | 2D cross-section profiles and sweep helpers |
| `connectors/` | HOK connectors, dovetails, dowels, magnets, tabs, slides, screws, seam joint API |
| `modules/` | The parts: base plate, top plate, drawer + front, handle, riser, backer, dividers |
| `vendor/` | openGrid tiles (by David D), ported verbatim |
| `examples/` | Ready-to-render demos |
| `legacy/` | The original monolithic sources, unmodified (reference) |

## Milestone status

- [x] **M1** — project structure, configuration system, shared utilities
- [x] **M2** — dynamic base/top plate generators
- [x] **M3** — dynamic drawer generator (plus riser and backer, completing the core section)
- [x] **M4** — dynamic divider system (`drawer(rows, columns)` + drop-in `divider_insert()`)
- [x] **M5** — connector system (`CONNECTOR_STYLE`-dispatched seam joints: dovetail, dowel, magnet)
- [ ] **M6** — accessories
- [ ] **M7** — automatic split generation for oversized parts
- [ ] **M8** — documentation and examples

## License

CC BY-NC-SA 4.0, inherited from the original DeskWare. See
[LICENSE.md](LICENSE.md) for attribution.
