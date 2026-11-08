# Build and run

1. Install Godot 4.7.2 Standard (no .NET version required) on Windows.
2. Import `stalingrad-red-front/project.godot` in the Godot Project Manager.
3. Open the project and press F6 to run the current scene, or F5 to launch the configured `scenes/main/main.tscn` startup scene.
4. Click the window if needed to capture the mouse. Press Escape to release it.
5. For a Windows build, use Project > Export, add a Windows Desktop preset, and export the project.

The project selects the Compatibility renderer and Godot's built-in 3D physics engine. No external plugins or assets are required.

## Verification status

Godot 4.7.2 project scan, Mission 01 runtime assertions, the Phase 3B combat regression harness, and a non-headless 1280×720 rendered launch have been run. The runtime harness simulates movement from the landing into the street. A full manual editor walkthrough, sustained performance profile and Windows export remain untested. See `PHASE_04A_TEST_REPORT.md` and `PHASE_03B_TEST_REPORT.md`.
