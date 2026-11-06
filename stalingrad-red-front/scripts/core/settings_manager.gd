extends Node
## Persistent player settings used by the prototype.

signal sensitivity_changed(value: float)

const DEFAULT_SENSITIVITY := 0.0025
var mouse_sensitivity: float = DEFAULT_SENSITIVITY

func _ready() -> void:
	preload("res://scripts/core/input_setup.gd").configure()

func set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = clampf(value, 0.0002, 0.02)
	sensitivity_changed.emit(mouse_sensitivity)
