extends Resource
class_name EncounterDefinition
## Mission-local spawn data for one combat encounter.

@export var encounter_id: StringName
@export var enemy_scene: PackedScene = preload("res://scenes/enemies/infantry_enemy.tscn")
@export var spawn_positions: Array[Vector3] = []
@export_range(1, 8, 1) var max_simultaneous_enemies: int = 2
