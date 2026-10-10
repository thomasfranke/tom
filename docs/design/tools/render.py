"""Renders an exported board, or any SVG, to a PNG with headless Chrome.

    python3 docs/design/tools/render.py <board.svg> <out.png> [--size 1440x900] [--scale 2]

Chrome and not `rsvg-convert`, because the latter drops every mono face over
how the family is quoted and blames the file. The default size is the boards'
own window, so a screenshot the app takes at 1440×900 (`tom e2e <name>
--board`) crops to the same rectangle and every number taken off the two is
real; `--scale 2` doubles the pixels for reading a radius or a hairline.
"""

import os
import subprocess
import sys

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"


def render(svg, out, size="1440x900", scale=1):
    """Write *svg* to *out* at *size* logical pixels, *scale* device pixels each."""
    width, height = size.split("x")
    subprocess.run(
        [
            CHROME, "--headless", "--disable-gpu", "--hide-scrollbars",
            f"--force-device-scale-factor={scale}",
            f"--window-size={width},{height}",
            f"--screenshot={os.path.abspath(out)}",
            "file://" + os.path.abspath(svg),
        ],
        check=True, capture_output=True,
    )
    return out


def main(argv):
    if len(argv) < 2:
        raise SystemExit(__doc__)
    size, scale, rest = "1440x900", 1, []
    it = iter(argv)
    for arg in it:
        if arg == "--size":
            size = next(it)
        elif arg == "--scale":
            scale = int(next(it))
        else:
            rest.append(arg)
    print(render(rest[0], rest[1], size, scale))


if __name__ == "__main__":
    main(sys.argv[1:])
