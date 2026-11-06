extends Node
## Small global entry point for pause and player lifecycle signals.

signal player_spawned(player: Node3D)
signal pause_changed(is_paused: bool)

var current_player: Node3D

func register_player(player: Node3D) -> void:
	current_player = player
	player_spawned.emit(player)

func set_paused(value: bool) -> void:
	get_tree().paused = value
	pause_changed.emit(value)
