# Phase 3B Implementation Report: Enemy Combat AI

Date: 2026-11-09

## Scope

Extended the Phase 3A infantry actor with player detection, investigation, navigation pursuit, ranged attacks, ammunition/reload state, and death lockout. Mission 01 and its startup scene remain separate and unchanged.

## Implementation

- `scripts/enemies/enemy_controller.gd` now has IDLE, INVESTIGATE, CHASE, ATTACK, RELOAD and DEAD combat states. The controller resolves the live player through `GameManager.current_player` and uses the existing `Player/Health` component and its `apply_damage(int)` method.
- Exported tuning covers detection, attack and target-loss ranges; walk/run speeds and stop distance; rotation; magazine/reserve; reload duration; fire interval and damage; spread; detection polling and investigation duration. Defaults are a low-damage infantry rifle (12 damage, 0.8 second interval, five rounds, 2.4 second reload).
- Visibility checks are limited to the configurable detection interval. A shot ray is issued only at the configured firing interval and applies damage only when the first hit is the player body, so solid world geometry blocks hits.
- Reload preserves remaining ammunition, transfers no more than capacity/reserve, and is not restarted when reserve is empty. Player death ends combat; enemy death stops navigation/avoidance and disables collision. Existing health/death and animation placeholders remain in use.
- `scripts/testing/enemy_test_range.gd` shows enemy health, AI state, magazine/reserve and player health. The player/HUD, enemy, navigation and obstacle environment remain confined to the isolated test scene.
- `scripts/testing/phase_03b_runtime_check.gd` and its scene provide repeatable headless integration checks.
- The runtime harness also fires the existing PPSH through `WeaponBase.fire()` and confirms ammunition consumption and damage to the enemy receiver.

## Limitations

Enemy firing and soldier movement are graybox hitscan/placeholder animation behavior. The test scene is the only scene with an enemy. Visual appearance, mouse interaction, pathfinding in rendered play, and performance on Intel UHD 620 require manual editor/hardware review.
