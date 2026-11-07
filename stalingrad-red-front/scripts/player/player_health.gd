extends Node
class_name PlayerHealth
## Health state kept separate from player locomotion.

signal health_changed(current_health: int, maximum_health: int)
signal died

@export_range(1, 1000, 1) var maximum_health: int = 100
var current_health: int = 100
var is_dead: bool = false

func _ready() -> void:
	maximum_health = maxi(1, maximum_health)
	current_health = maximum_health

func apply_damage(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	var previous_health: int = current_health
	current_health = maxi(0, current_health - amount)
	if current_health != previous_health:
		health_changed.emit(current_health, maximum_health)
	if current_health == 0:
		is_dead = true
		died.emit()

func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	var previous_health: int = current_health
	current_health = mini(maximum_health, current_health + amount)
	if current_health != previous_health:
		health_changed.emit(current_health, maximum_health)

func reset() -> void:
	var was_dead: bool = is_dead
	var previous_health: int = current_health
	current_health = maximum_health
	is_dead = false
	if was_dead or previous_health != current_health:
		health_changed.emit(current_health, maximum_health)
