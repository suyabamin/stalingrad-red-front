# Build and run

1. Install Godot 4.7.2 Standard (no .NET version required) on Windows.
2. Import `stalingrad-red-front/project.godot` in the Godot Project Manager.
3. Open the project and press F6 to run the current scene, or F5 to launch the configured `scenes/main/main.tscn` startup scene.
4. Click the window if needed to capture the mouse. Press Escape to release it.
5. For a Windows build, use Project > Export, add a Windows Desktop preset, and export the project.

The project selects the Compatibility renderer and Godot's built-in 3D physics engine. No external plugins or assets are required.

## Verification status

The current environment did not expose a Godot executable during implementation. Syntax parsing, editor import, interactive scene launch, movement, mouse look, jumping and Windows export therefore still require verification with Godot 4.7.2. See the delivery report in the project handoff for the checks that were possible here.
