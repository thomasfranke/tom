"""Makes a Penpot SVG export self-contained: the fonts go inside the file.

    python3 docs/design/tools/embed_fonts.py docs/design/screens/desktop/*/*.svg ...

Penpot's SVG export keeps every text as `<text>` and lists the fonts it uses
as `@font-face` rules — but their `src` points at Penpot's font proxy. Opened
anywhere that cannot or will not fetch it (GitHub renders an SVG as an image
and loads nothing external; any machine offline), the text falls back to
whatever font is at hand, and the export stops showing what the board shows.

This rewrites each rule's `src` into a `data:` URI, keeping only the `latin`
subset — the boards are English — so a 1440×900 board grows by ~100KB rather
than by every script the family ships. Downloads are cached in
`generated/fonts/` (git-ignored) so the second file costs nothing. Idempotent:
a file already embedded is left alone.
"""

import base64
import hashlib
import os
import re
import sys
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "generated", "fonts")
KEEP_SUBSETS = {"latin"}

BLOCK = re.compile(r"/\*\s*([\w-]+)\s*\*/\s*(@font-face\s*\{.*?\})", re.S)
SRC = re.compile(r"url\((https?://[^)]+)\)")


# Penpot's proxy answers 403 to anything that does not look like a browser, and
# its paths mirror Google's CDN one for one — so ask politely first, and fall
# back to the origin the file actually comes from.
PROXY = "https://design.penpot.app/internal/gfonts/font/"
ORIGIN = "https://fonts.gstatic.com/s/"
HEADERS = {"User-Agent": "Mozilla/5.0 (embed_fonts.py; TOM design tools)"}


def fetch(url):
    os.makedirs(CACHE, exist_ok=True)
    name = hashlib.sha1(url.encode()).hexdigest()[:16] + os.path.splitext(url)[1]
    path = os.path.join(CACHE, name)
    if not os.path.exists(path):
        candidates = [url] + ([url.replace(PROXY, ORIGIN, 1)] if url.startswith(PROXY) else [])
        last = None
        for candidate in candidates:
            try:
                req = urllib.request.Request(candidate, headers=HEADERS)
                with urllib.request.urlopen(req, timeout=30) as r:
                    data = r.read()
                break
            except urllib.error.HTTPError as e:  # try the next origin
                last = e
        else:
            raise last
        with open(path, "wb") as f:
            f.write(data)
    with open(path, "rb") as f:
        return f.read()


def embed(svg):
    m = re.search(r"<style>(.*?)</style>", svg, re.S)
    if not m or "data:font" in m.group(1):
        return svg, 0
    css = m.group(1)
    kept = []
    for subset, rule in BLOCK.findall(css):
        if subset not in KEEP_SUBSETS:
            continue
        url = SRC.search(rule).group(1)
        mime = "font/woff2" if url.endswith(".woff2") else "font/ttf"
        data = base64.b64encode(fetch(url)).decode("ascii")
        kept.append(SRC.sub(f"url(data:{mime};base64,{data})", rule, count=1))
    return svg.replace(m.group(0), "<style>" + "\n".join(kept) + "</style>", 1), len(kept)


def main(paths):
    for path in paths:
        with open(path, encoding="utf-8") as f:
            before = f.read()
        after, faces = embed(before)
        if faces:
            with open(path, "w", encoding="utf-8") as f:
                f.write(after)
        print(f"{path}: {'already embedded' if not faces else f'{faces} faces, {len(before) // 1024}KB -> {len(after) // 1024}KB'}")


if __name__ == "__main__":
    main(sys.argv[1:])
