# Phase 2 Test Report: Weapons and Combat

Audit date: 2026-11-08.

## Scope and evidence

This report distinguishes developer-reported manual results from checks performed during this audit. The project owner reports manually testing the following in Godot: Mosin-Nagant firing, PPSH-41 automatic firing, reloading, and damage to the stationary target; no Godot errors were observed during those tests. These results are attributed to the project owner and were not independently reproduced in this audit.

The audit inspected weapon scripts and data resources, player health/controller, game manager, input setup, HUD, weapon/player/main/test scenes, and project configuration. This is source inspection, not a runtime test. No Godot runtime or headless import/parser command was run because no Godot executable was available in the shell.

## Developer-reported manual results

| Check | Result | Attribution |
|---|---|---|
| Mosin-Nagant firing | Working | Project owner manual test |
| PPSH-41 automatic firing | Working | Project owner manual test |
| Reloading | Working | Project owner manual test; scope of ammo edge cases not specified |
| Stationary target damage | Working | Project owner manual test |
| Godot errors during these tests | None observed | Project owner manual observation |

These results do not establish unmentioned cases such as empty magazines, reserve exhaustion, reload interruption, ADS, recoil, occlusion, switching during reload, or death/restart regression.

## Source audit findings (not runtime-tested)

- Both weapon scenes reference `WeaponBase` and their respective `WeaponData` resources. Mosin values are 5/5 magazine, 30 reserve, 80 damage and 1.2 rounds/second; PPSH values are 35/35, 105 reserve, 18 damage and 10 rounds/second.
- `WeaponManager` creates both weapons, selects Mosin by default, tracks cooldown on the selected weapon, and emits the selected weapon's ammo state on switching. A reload timer retains the weapon instance that began reloading, so switching does not redirect its ammo transfer.
- Reload transfers at most the missing magazine capacity and available reserve. The code rejects full-magazine, empty-reserve and duplicate reload requests.
- Aim ray originates at the camera and excludes the player body RID. It uses all collision layers, so world geometry can block a target behind it. Damage is delivered only when the first collider implements `apply_damage(amount)`.
- Fire and aim use left and right mouse buttons; reload and weapon slots use R, 1 and 2. No conflicting bindings were found in the project's input setup. Escape uses Godot's `ui_cancel` action.
- No temporary health/damage debug input controls were found. `PlayerHealth` and its scene integration were retained.
- Fire, reload, empty and impact audio player nodes are created, but the weapon resources assign no audio streams. Weapon meshes are procedural graybox placeholders.

## Remaining manual checks

| Check | Status |
|---|---|
| Empty magazine and no negative ammo | Not reported / not run by auditor |
| Partial, full-magazine, and empty-reserve reload boundaries | Not reported / not run by auditor |
| Reload concurrency and weapon switching during reload | Not reported / not run by auditor |
| Weapon switching and per-weapon ammo restoration | Not reported / not run by auditor |
| ADS transitions, recoil recovery, and sway | Not reported / not run by auditor |
| Misses, world occlusion, and player self-hit exclusion | Not reported / not run by auditor |
| Player health/death/restart regression after Phase 2 | Not run by auditor; Phase 1 results remain owner-reported separately |
| Godot parse/import or runtime validation | Not run; executable unavailable |

No Phase 2 test is claimed as independently passed by this audit. The cases above are not implied by the four reported results.
