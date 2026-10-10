"""Reads a PNG into rows of RGBA tuples, and writes one back — no Pillow.

The measuring scripts beside this one (`pixels.py`, `bbox.py`, `compare.py`)
run on whatever machine has the repository, and that machine has Python and
Chrome but not necessarily Pillow. What Chrome's screenshots and Penpot's
renders need is small: 8-bit, non-interlaced, RGB or RGBA, which is all this
decodes. Anything else raises rather than guesses.
"""

import struct
import zlib


def read_png(path):
    """Return (width, height, rows); each row is a list of (r, g, b, a)."""
    data = open(path, "rb").read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"{path}: not a PNG")
    pos, idat, header = 8, [], None
    while pos < len(data):
        length, kind = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + length]
        if kind == b"IHDR":
            header = struct.unpack(">IIBBBBB", body)
        elif kind == b"IDAT":
            idat.append(body)
        elif kind == b"IEND":
            break
        pos += 12 + length
    width, height, depth, colour, _, _, interlace = header
    if depth != 8 or colour not in (2, 6) or interlace:
        raise ValueError(f"{path}: only 8-bit RGB/RGBA, non-interlaced")
    channels = 4 if colour == 6 else 3
    raw = zlib.decompress(b"".join(idat))
    stride = width * channels
    rows, previous, offset = [], bytearray(stride), 0
    for _ in range(height):
        kind = raw[offset]
        line = bytearray(raw[offset + 1:offset + 1 + stride])
        offset += 1 + stride
        _unfilter(kind, line, previous, channels)
        if channels == 3:
            rows.append([(line[i], line[i + 1], line[i + 2], 255) for i in range(0, stride, 3)])
        else:
            rows.append([tuple(line[i:i + 4]) for i in range(0, stride, 4)])
        previous = line
    return width, height, rows


def _unfilter(kind, line, previous, bpp):
    """Undo one scanline's filter in place (PNG spec, section 9)."""
    if kind == 0:
        return
    for i in range(len(line)):
        a = line[i - bpp] if i >= bpp else 0
        b = previous[i]
        c = previous[i - bpp] if i >= bpp else 0
        if kind == 1:
            line[i] = (line[i] + a) & 0xFF
        elif kind == 2:
            line[i] = (line[i] + b) & 0xFF
        elif kind == 3:
            line[i] = (line[i] + ((a + b) >> 1)) & 0xFF
        elif kind == 4:
            p = a + b - c
            pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
            line[i] = (line[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 0xFF
        else:
            raise ValueError(f"unknown PNG filter {kind}")


def write_png(path, width, height, rows):
    """Write rows of (r, g, b, a) as an 8-bit RGBA PNG."""
    raw = bytearray()
    for row in rows:
        raw.append(0)
        for px in row:
            raw.extend(px)
    def chunk(kind, body):
        return struct.pack(">I", len(body)) + kind + body + struct.pack(">I", zlib.crc32(kind + body) & 0xFFFFFFFF)
    out = b"\x89PNG\r\n\x1a\n"
    out += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    out += chunk(b"IDAT", zlib.compress(bytes(raw), 6))
    out += chunk(b"IEND", b"")
    open(path, "wb").write(out)


def hexof(px):
    """`#RRGGBB` of a pixel, the way the boards and the palette spell it."""
    return "#%02X%02X%02X" % px[:3]
