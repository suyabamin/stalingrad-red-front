@echo off
echo --- FINAL REGRESSION SUITE ---
echo.

echo [1/5] Phase 3B...
"C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "D:\Stalingrad Red Front\stalingrad-red-front" --scene res://scenes/testing/phase_03b_runtime_check.tscn 2>&1
echo 3B_EXIT=%ERRORLEVEL%
echo.

echo [2/5] Phase 4A...
"C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "D:\Stalingrad Red Front\stalingrad-red-front" --scene res://scenes/testing/phase_04a_runtime_check.tscn 2>&1
echo 4A_EXIT=%ERRORLEVEL%
echo.

echo [3/5] Phase 4B...
"C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "D:\Stalingrad Red Front\stalingrad-red-front" --scene res://scenes/testing/phase_04b_runtime_check.tscn 2>&1
echo 4B_EXIT=%ERRORLEVEL%
echo.

echo [4/5] Phase 4C...
"C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "D:\Stalingrad Red Front\stalingrad-red-front" --scene res://scenes/testing/phase_04c_runtime_check.tscn 2>&1
echo 4C_EXIT=%ERRORLEVEL%
echo.

echo [5/5] Phase 5C...
"C:\Users\HP\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "D:\Stalingrad Red Front\stalingrad-red-front" --scene res://scenes/testing/phase_05c_runtime_check.tscn 2>&1
echo 5C_EXIT=%ERRORLEVEL%
echo.

echo --- REGRESSION SUITE COMPLETE ---
