# Phase 2 Asset Compatibility Report

| Pair | Status | Evidence / missing validation |
|---|---|---|
| German soldier + rifle | **NOT TESTED / BLOCKED** | Soldier skin deforms on a 49-bone rig, but there is no tested rifle, clip, hand attachment, two-hand contact, shoulder fit or muzzle alignment. Incoming soldier rights unresolved. |
| First-person arms + Mosin | **NOT TESTED** | Arms have 62-bone rig and open hands; Mosin is one static mesh. No combined scene, grip, camera fit or near-plane test. |
| First-person arms + PPSH | **BLOCKED** | Incoming PPSH folder is empty; no combination was staged or inferred from another Soviet weapon. |

## Cross-asset constraints

- Soldier and arms source skeletons have different bone counts/names; no retarget map or animation transfer was tested.
- Soldier hands omit ring/pinky chains; the arms rig includes them. Actual contact pose cannot be assumed from matching humanoid proportions.
- The arms test FBX's embedded character root is 10× the base variant, and some rest transforms differ. Applying a compensating outer 0.1 scale only corrects measured bounds; it does not reconcile pose hierarchy differences.
- Mosin has no articulated bolt/magazine node. Reload/fire poses would need an isolated derived visual solution if later authorized.
- All incoming asset source/license status remains unresolved, so none is approved for production redistribution.

No incompatible pair was forced together. No player/enemy scenes, gameplay resources, scripts or test expectations were edited.
