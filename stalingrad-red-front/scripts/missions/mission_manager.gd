extends Node
## Owns mission lifecycle and the sequential objective state machine.

signal mission_prepared(definition: MissionDefinition)
signal mission_started(mission_id: String)
signal mission_completed(mission_id: String)
signal mission_failed(mission_id: String, reason: String)
signal mission_state_changed(state: StringName)
signal objective_started(objective: ObjectiveDefinition, number: int, total: int)
signal objective_completed(objective: ObjectiveDefinition, completed_count: int, total: int)
signal objective_failed(objective: ObjectiveDefinition, reason: String)

enum MissionState { IDLE, READY, ACTIVE, COMPLETED, FAILED }
enum ObjectiveState { INACTIVE, ACTIVE, COMPLETED, FAILED }

var current_definition: MissionDefinition
var current_mission_id := ""
var mission_state: MissionState = MissionState.IDLE
var current_objective_index: int = -1
var completed_objective_count: int = 0
var objective_states: Array[ObjectiveState] = []
var _completion_emitted: bool = false

func _ready() -> void:
	if not GameManager.player_died.is_connected(_on_player_died):
		GameManager.player_died.connect(_on_player_died)

func prepare_mission(definition: MissionDefinition) -> bool:
	if definition == null or definition.mission_id.is_empty() or definition.objectives.is_empty():
		push_error("Cannot prepare mission: definition or ordered objectives are missing.")
		return false
	var seen_ids: Dictionary = {}
	for objective in definition.objectives:
		if objective == null or objective.objective_id.is_empty() or objective.display_name.is_empty() or seen_ids.has(objective.objective_id):
			push_error("Cannot prepare mission '%s': objective data is missing or duplicated." % definition.mission_id)
			return false
		seen_ids[objective.objective_id] = true
	current_definition = definition
	current_mission_id = String(definition.mission_id)
	mission_state = MissionState.READY
	current_objective_index = 0
	completed_objective_count = 0
	objective_states.clear()
	for _objective in definition.objectives:
		objective_states.append(ObjectiveState.INACTIVE)
	_completion_emitted = false
	mission_state_changed.emit(&"ready")
	mission_prepared.emit(definition)
	return true

func begin_mission() -> bool:
	if mission_state != MissionState.READY or current_definition == null:
		return false
	mission_state = MissionState.ACTIVE
	mission_state_changed.emit(&"active")
	mission_started.emit(current_mission_id)
	_activate_current_objective()
	return true

## Compatibility entry point for callers that used the previous manager API.
func start_mission(mission_id: String) -> void:
	if mission_id == current_mission_id:
		begin_mission()

func get_current_objective() -> ObjectiveDefinition:
	if mission_state != MissionState.ACTIVE or current_definition == null:
		return null
	if current_objective_index < 0 or current_objective_index >= current_definition.objectives.size():
		return null
	return current_definition.objectives[current_objective_index]

func get_objective_count() -> int:
	return current_definition.objectives.size() if current_definition != null else 0

func complete_objective(objective_id: StringName) -> bool:
	if mission_state != MissionState.ACTIVE:
		return false
	var objective := get_current_objective()
	if objective == null or objective.objective_id != objective_id:
		return false
	if objective_states[current_objective_index] != ObjectiveState.ACTIVE:
		return false
	objective_states[current_objective_index] = ObjectiveState.COMPLETED
	completed_objective_count += 1
	objective_completed.emit(objective, completed_objective_count, get_objective_count())
	if completed_objective_count == get_objective_count():
		mission_state = MissionState.COMPLETED
		mission_state_changed.emit(&"completed")
		if not _completion_emitted:
			_completion_emitted = true
			mission_completed.emit(current_mission_id)
		return true
	current_objective_index += 1
	_activate_current_objective()
	return true

func complete_current_mission() -> void:
	var objective := get_current_objective()
	if objective != null and current_objective_index == get_objective_count() - 1:
		complete_objective(objective.objective_id)

func fail_current_objective(reason: String) -> bool:
	if mission_state != MissionState.ACTIVE:
		return false
	var objective := get_current_objective()
	if objective == null or objective_states[current_objective_index] != ObjectiveState.ACTIVE:
		return false
	objective_states[current_objective_index] = ObjectiveState.FAILED
	mission_state = MissionState.FAILED
	objective_failed.emit(objective, reason)
	mission_state_changed.emit(&"failed")
	mission_failed.emit(current_mission_id, reason)
	return true

func _activate_current_objective() -> void:
	if current_definition == null or current_objective_index < 0 or current_objective_index >= current_definition.objectives.size():
		return
	objective_states[current_objective_index] = ObjectiveState.ACTIVE
	objective_started.emit(current_definition.objectives[current_objective_index], current_objective_index + 1, get_objective_count())

func _on_player_died() -> void:
	fail_current_objective("Player incapacitated")
