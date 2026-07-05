#!/usr/bin/env python3
"""
DeskWare Next - tools/flatten.py

Flatten a .scad entry file into a single self-contained file by textually
inlining every project `include <...>` (which matches OpenSCAD's own
include semantics). Library includes that don't resolve inside the project
(BOSL2/...) are kept, deduplicated to their first occurrence - MakerWorld's
parametric maker lab provides BOSL2, but only accepts a single model file.

Each inlined file is prefixed with a /*[Hidden]*/ customizer section so the
framework's internal constants don't appear in the Customizer UI; only the
entry file's own parameters (declared before its first include) show up.
Pass --expose for files whose customizer sections should stay visible.

    python3 tools/flatten.py examples/customizer.scad -o build/deskware-next-makerworld.scad

Licensed CC-BY-NC-SA 4.0. See LICENSE.md for attribution.
"""

import argparse
import datetime
import re
import sys
from pathlib import Path

INCLUDE_RE = re.compile(r"^\s*(include|use)\s*<([^>]+)>\s*;?\s*$")
PROJECT_ROOT = Path(__file__).resolve().parent.parent


def resolve(target: str, including_file: Path) -> Path | None:
    """Resolve an include target the way OpenSCAD does: relative to the
    including file first, then the project root (our OPENSCADPATH)."""
    for base in (including_file.parent, PROJECT_ROOT):
        candidate = (base / target).resolve()
        if candidate.is_file():
            return candidate
    return None


def flatten(path: Path, seen: set[Path], expose: set[Path], top: bool) -> list[str]:
    out = []
    for line in path.read_text().splitlines():
        m = INCLUDE_RE.match(line)
        if not m:
            out.append(line)
            continue
        kind, target = m.groups()
        resolved = resolve(target, path)
        if resolved is None or PROJECT_ROOT not in resolved.parents:
            # external library (BOSL2): keep the directive, once
            key = Path(target)
            if key not in seen:
                seen.add(key)
                out.append(line)
            continue
        if kind == "use":
            sys.exit(f"error: {path}: `use <{target}>` of a project file can't "
                     "be inlined (top-level code would execute); use include")
        if resolved in seen:
            continue
        seen.add(resolved)
        rel = resolved.relative_to(PROJECT_ROOT)
        out.append(f"//======== begin {rel} ========")
        if resolved not in expose:
            out.append("/*[Hidden]*/")
        out.extend(flatten(resolved, seen, expose, top=False))
        out.append(f"//======== end {rel} ========")
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[1])
    ap.add_argument("entry", type=Path, help="entry .scad file to flatten")
    ap.add_argument("-o", "--output", type=Path, required=True)
    ap.add_argument("--expose", type=Path, action="append", default=[],
                    help="project file whose customizer parameters stay visible")
    args = ap.parse_args()

    entry = args.entry.resolve()
    expose = {p.resolve() for p in args.expose}
    body = flatten(entry, seen=set(), expose=expose, top=True)

    header = [
        f"//GENERATED FILE - do not edit. Built by tools/flatten.py from",
        f"//{entry.relative_to(PROJECT_ROOT)} on {datetime.date.today()}.",
        "//",
        "//DeskWare Next - https://github.com/AlwaysOutofRange/deskware-next",
        "//Design by Hands on Katie, original OpenSCAD by BlackjackDuck (Andy),",
        "//openGrid by David D. Licensed CC-BY-NC-SA 4.0 - see LICENSE.md.",
        "",
    ]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(header + body) + "\n")

    leftovers = [l for l in body if INCLUDE_RE.match(l)]
    print(f"{args.output}: {len(body)} lines, kept includes: "
          + (", ".join(INCLUDE_RE.match(l).group(2) for l in leftovers) or "none"))


if __name__ == "__main__":
    main()
