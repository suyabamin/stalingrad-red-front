extends Node
## Small global entry point for pause and player lifecycle signals.

signal player_spawned(player: Node3D)
signal pause_changed(is_paused: bool)
signal player_died

var current_player: Node3D

func register_player(player: Node3D) -> void:
	current_player = player
	player_spawned.emit(player)

func notify_player_died() -> void:
	player_died.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func restart_current_scene() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func set_paused(value: bool) -> void:
	get_tree().paused = value
	pause_changed.emit(value)
