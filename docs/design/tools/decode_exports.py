#!/usr/bin/env python3
"""Write the boards a Penpot export call returned.

The plugin hands back ``{filename: base64}``; an answer that size is spilled by
the agent harness into a file rather than returned, so this reads that file and
writes each board where it belongs. Run ``embed_fonts.py`` over the result
afterwards — an export straight from Penpot points its ``@font-face`` at
Penpot's own font proxy.

    python3 docs/design/tools/decode_exports.py <spill.json> <out-dir>
"""

import base64
import json
import sys
from pathlib import Path


def decode(spill: Path, out_dir: Path) -> list[Path]:
    """Write every file named in *spill* into *out_dir*."""
    payload = json.loads(spill.read_text())
    files = payload.get("result", payload)
    if not isinstance(files, dict):
        raise SystemExit(f"{spill}: expected a map of filename to base64")
    out_dir.mkdir(parents=True, exist_ok=True)
    written = []
    for name, encoded in files.items():
        # A key with no suffix, or one marked with an underscore, is something
        # the export call reported about itself rather than a file.
        if not isinstance(encoded, str) or name.startswith("_"):
            continue
        if not Path(name).suffix:
            continue
        target = out_dir / name
        target.write_bytes(base64.b64decode(encoded))
        written.append(target)
    return written


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    written = decode(Path(sys.argv[1]), Path(sys.argv[2]))
    if not written:
        raise SystemExit("nothing in that answer looked like a file")
    for path in written:
        print(f"{path} ({path.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
