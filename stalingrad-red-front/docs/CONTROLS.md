# Controls

| Action | Key / button |
| --- | --- |
| Move | W, A, S, D |
| Jump | Space |
| Sprint | Shift |
| Fire | Left mouse button |
| Aim down sights | Right mouse button (hold) |
| Reload | R |
| Select Mosin-Nagant | 1 |
| Select PPSH-41 | 2 |
| Release mouse | Escape |
| Capture mouse | Click in the game window |
| Restart after death | Click **RESTART MISSION** |

On F5 startup, the mission briefing pauses movement and releases the mouse. Click **START MISSION** to begin; the mouse is captured automatically. Objective progress appears at the top right. At mission completion, click **RESTART MISSION** to replay.

Mouse sensitivity is exposed by the `SettingsManager` autoload through `set_mouse_sensitivity(value)`. Its initial value is 0.0025 radians per mouse-motion unit. The death screen's return-to-title option is disabled until a title scene exists.
