/*
DeskWare Next - examples/multi_section_desk.scad

The flagship: a two-section desk system at classic DeskWare dimensions,
from a single storage_system() call. Risers are shared between sections;
every derived value (grid fields, connector spacings, drawer sizes, slot
counts) follows the width/depth/height arguments.

Note: classic 196mm parts exceed small print beds. See
examples/monitor_shelf.scad for splitting oversized parts, or
examples/compact_system.scad for a system sized to print whole.

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
*/

include <../deskware-next.scad>

storage_system(sections = 2);
