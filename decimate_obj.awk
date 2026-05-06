# Voxel-quantize an OBJ — output unique vertices + non-degenerate triangle faces.
# Output (text):
#   <V_count> <F_count>\n
#   V lines: "x y z"
#   F lines: "i j k" (1-indexed)

BEGIN {
  GRID = 20           # 1/GRID mm per voxel — 0.05mm
  vidx = 0
  uniq_v = 0
  face_count = 0
  printf("") > vout
  printf("") > fout
}

function snap(x) {
  return (x >= 0) ? int(x*GRID + 0.5)/GRID : -int(-x*GRID + 0.5)/GRID
}

$1 == "v" {
  vidx++
  x = snap($2 + 0); y = snap($3 + 0); z = snap($4 + 0)
  key = x SUBSEP y SUBSEP z
  if (!(key in vmap)) {
    uniq_v++
    vmap[key] = uniq_v
    printf("%g %g %g\n", x, y, z) >> vout
  }
  remap[vidx] = vmap[key]
  next
}

# Triangle (or fan-triangulated polygon) face — drop degenerates
$1 == "f" {
  n = NF - 1
  if (n < 3) next
  delete fv
  for (i = 1; i <= n; i++) {
    tok = $(i+1)
    sub(/\/.*/, "", tok)
    fv[i] = remap[tok + 0]
  }
  # fan triangulate
  v0 = fv[1]
  for (i = 2; i < n; i++) {
    a = v0; b = fv[i]; c = fv[i+1]
    if (a == b || b == c || a == c) continue
    # dedupe identical triangles (sorted)
    if (a < b) { if (a < c) { p1=a; if (b<c){p2=b;p3=c}else{p2=c;p3=b} } else {p1=c;p2=a;p3=b} }
    else { if (b < c) { p1=b; if (a<c){p2=a;p3=c}else{p2=c;p3=a} } else {p1=c;p2=b;p3=a} }
    fkey = p1 SUBSEP p2 SUBSEP p3
    if (!(fseen[fkey])) {
      fseen[fkey] = 1
      printf("%d %d %d\n", a, b, c) >> fout
      face_count++
    }
  }
}

END {
  printf("vertices: %d (from %d), faces: %d\n", uniq_v, vidx, face_count) > "/dev/stderr"
}
