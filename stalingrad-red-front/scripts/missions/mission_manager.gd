extends Node
## Tracks the currently loaded prototype mission.

signal mission_started(mission_id: String)
signal mission_completed(mission_id: String)

var current_mission_id := ""

func start_mission(mission_id: String) -> void:
	current_mission_id = mission_id
	mission_started.emit(mission_id)

func complete_current_mission() -> void:
	if current_mission_id.is_empty():
		return
	mission_completed.emit(current_mission_id)
