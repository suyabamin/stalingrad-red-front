# Intel UHD 620 Asset Budget — Phase 3 Prototypes

Target is Godot 4.7.2 Compatibility renderer on Intel UHD 620. This phase did not establish a production performance budget because no complete prototype scene was assembled or benchmarked.

Known source costs from Phase 2 validation: soldier 5,075 triangles; arms 8,152 triangles; Mosin 28,041 triangles with three 4096×4096 maps. Those Mosin texture imports occupied 58,311,424 bytes in the inspected cache; 2K and 1K derivative cache estimates were 11,391,910 and 2,926,498 bytes respectively. These are prior import measurements, not a Phase 3 runtime benchmark. Existing PPSH selected meshes total 3,544 triangles.

No FPS, GPU memory, draw-call, skinning, or frame-time measurement was made for a combined soldier/weapon or first-person scene. Do not claim the candidate fits target hardware. Proposed later gates: measure 60-second warmed captures at 1280×720 and 1920×1080 on target UHD 620; report median/P95/P99 frame times, peak process memory, draw calls and texture residency; keep full-resolution originals unchanged and compare licensed derived 1K/2K variants before any implementation approval.
