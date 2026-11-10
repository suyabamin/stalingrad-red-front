# PPSH-41 Final Acquisition Report

**Finding:** incoming `assets/library/incoming_downloads/ppsh_41/` is empty, but the project already contains a candidate in `assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf`. The existing pack's local `license.txt` identifies J.AkioHonda's WW2 Low Poly Weapons Pack under CC BY 4.0 with attribution. This existing asset is distinct from an incoming download; it was not copied, renamed, or replaced.

The isolated diagnostic selected named `PPSH 41_23` and `PPSH 41 Magazine_27` nodes. The prior inspection and current diagnostic identify three mesh pieces, 3,544 triangles, `Wood_Parts` and `BlackMetalParts`, and bounds approximately `(1.205566, 0.462338, 0.222118)`. It is static; no firing/reload articulation was established.

**Visual acceptance: not met.** `docs/asset_readiness_previews/phase3/ppsh_41_existing_pack.png` was opened and inspected; the model is cropped and off-center. Do not use that image as acceptance evidence. No asset was downloaded or duplicated. Next step is to fix isolated presentation framing and capture a complete render, then separately assess scale, orientation and viewmodel fit. No integration authorization is implied.
