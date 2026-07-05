# MakerWorld listing

Upload notes: license **CC BY-NC-SA 4.0**, published as a **remix** of the
original DeskWare listing. Covers: `docs/images/cover_web.png` (16:9) and
`docs/images/cover_app.png` (4:3).

## Title

DeskWare Next — fully parametric DeskWare (any size)

## Description

**DeskWare, rebuilt as a fully parametric framework.** This is a remix of
DeskWare (design by Hands on Katie, OpenSCAD by BlackjackDuck) with the same
design language and the same interfaces — but every part is generated from
parameters. Build storage systems at **any width, depth, and height** instead
of fixed 196 mm plates. With default settings, parts are dimensionally
identical to original DeskWare and mix freely with existing prints.

**Using the customizer**

Pick a **Part** and export it — the *assembly* entry is a display preview of
the whole system, not a print file. Then customize:

- Free millimeter dimensions: section width, depth, total height
- End caps: Rounded / Squared / Rounded Square, adjustable corner radius
- Drawers: built-in compartments (rows × columns), drop-in divider inserts, printed handle or hardware screw pulls (single/double), front inlay recess for multi-color fronts
- Risers: slides on both/one/no sides, front chamfer, stepped split-height riser
- Top plate: recess depth and lip to fit your insert material (felt, veneer, acrylic…)
- Walls, clearances, and per-part colors

**What to print** (system of N sections)

- 1 base plate + 1 top plate per section
- N+1 risers, 1 backer per section
- Per drawer slot: drawer + front (+ handle or screws)
- 2 base plate ends + 2 top plate ends (left and right are the same print)

Standard heights 67.5 / 107.5 / 147.5 mm give 1 / 2 / 3 drawer slots per
section — but any height works; the generator tells you what fits. Drawer
interiors round to whole 42 mm Gridfinity units so bins drop straight in,
and the plates carry standard openGrid fields, so the whole openGrid
accessory ecosystem snaps on.

No supports needed — everything prints in its designed orientation.

**Part too big for your bed?** The full framework on GitHub also
auto-splits oversized parts with mating connectors (dovetail keys, hidden
dowels, or puzzle glue seams):
https://github.com/AlwaysOutofRange/deskware-next

**Credits**

- Design: Katie of Hands on Katie (YouTube, Patreon, Discord)
- Original OpenSCAD: BlackjackDuck (Andy)
- openGrid: David D, with optimization by Pedro Leite
- Parametric refactor: AlwaysOutofRange, written with substantial help from Claude Code

Licensed CC BY-NC-SA 4.0, inherited from the original DeskWare.
