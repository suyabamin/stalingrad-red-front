extends StaticBody3D
class_name CombatTestTarget
## Stationary receiver used only by the isolated Phase 2 test range.

signal health_changed(current_health: int, maximum_health: int)

@export_range(1, 10000, 1) var maximum_health: int = 500
var current_health: int = 500

func _ready() -> void:
	current_health = maximum_health
	print("Combat test target health: %d/%d" % [current_health, maximum_health])

func apply_damage(amount: int) -> void:
	if amount <= 0:
		return
	current_health = maxi(0, current_health - amount)
	health_changed.emit(current_health, maximum_health)
	print("Combat test target health: %d/%d" % [current_health, maximum_health])
