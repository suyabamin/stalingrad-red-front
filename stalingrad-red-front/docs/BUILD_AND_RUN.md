# Build and run

1. Install Godot 4.7.2 Standard (no .NET version required) on Windows.
2. Import `stalingrad-red-front/project.godot` in the Godot Project Manager.
3. Open the project and press F6 to run the current scene, or F5 to launch the configured `scenes/main/main.tscn` startup scene and mission briefing.
4. Click **START MISSION** to begin and capture the mouse. Press Escape to release the mouse during play.
5. For a Windows build, use Project > Export, add a Windows Desktop preset, and export the project.

The project selects the Compatibility renderer and Godot's built-in 3D physics engine. No external plugins or assets are required.

## Verification status

Godot 4.7.2 project scan, Phase 4B mission progression/restart assertions, Phase 3B combat regression, direct startup launch, and non-headless GL Compatibility captures of briefing, objective HUD and mission completion have been run. Full user-driven manual playthrough, sustained performance profile and Windows export remain untested. See the Phase 4A and 4B test reports.
