# Trainsonic — Web Design & Dev Quotation

A single-page interactive quotation prepared for **Serop Elmayan** at Trainsonic.

[**View the quote →**](https://example.github.io/trainsonic/) <!-- replace with actual Pages URL after deploy -->

## What's in this repo

- [`index.html`](./index.html) — the deliverable. Fully self-contained: SVG logo inlined as a `<symbol>`, 3D wireframe embedded as gzipped base64, no external runtime dependencies.
- [`trainsonic-logo*.svg`](./trainsonic-logo.svg) — source logo variants from the Trainsonic brand kit.
- [`decimate_obj.awk`](./decimate_obj.awk) — build script that voxel-quantizes the source `.obj` and emits the wireframe data baked into the HTML. Source `.obj` files are excluded via `.gitignore`.

## Build pipeline (for reference)

```bash
# 1. Voxel-quantize OBJ → vertex + face text
awk -v vout=/tmp/v.txt -v fout=/tmp/f.txt -f decimate_obj.awk source.obj

# 2. Bundle, gzip, base64
{ echo "TSWIRE2"; echo "$(wc -l < /tmp/v.txt) $(wc -l < /tmp/f.txt)"; cat /tmp/v.txt; cat /tmp/f.txt; } > wire.txt
gzip -9 wire.txt
base64 -w0 wire.txt.gz > wire.b64

# 3. Inject into the <script id="wire-data"> placeholder in the HTML
```

## Deployment

Hosted via GitHub Pages. Just push to `main`; the site rebuilds automatically.
