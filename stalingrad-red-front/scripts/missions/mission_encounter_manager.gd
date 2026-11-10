extends Node3D
class_name MissionEncounterManager
## Owns the active Mission 01 encounter and its spawned infantry.

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/infantry_enemy.tscn")

var _run_id := -1
var _objective_id: StringName = &""
var _encounter: EncounterDefinition
var _next_spawn := 0
var _living: Dictionary = {}
var _counted_deaths: Dictionary = {}
var _spawning := false

func _ready() -> void:
	MissionManager.objective_started.connect(_on_objective_started)
	MissionManager.mission_prepared.connect(_on_mission_prepared)
	MissionManager.mission_failed.connect(_on_mission_ended)
	MissionManager.mission_completed.connect(_on_mission_completed)
	if MissionManager.current_definition != null:
		_run_id = MissionManager.mission_run_id

func get_living_enemy_count() -> int:
	return _living.size()

func get_spawned_enemy_count() -> int:
	return _next_spawn

func get_active_enemies() -> Array[Node3D]:
	var result: Array[Node3D] = []
	for actor in _living.values():
		if is_instance_valid(actor):
			result.append(actor)
	return result

func _on_mission_prepared(_definition: MissionDefinition) -> void:
	_cleanup()
	_run_id = MissionManager.mission_run_id

func _on_objective_started(objective: ObjectiveDefinition, _number: int, _total: int) -> void:
	if _run_id != MissionManager.mission_run_id:
		_cleanup()
		_run_id = MissionManager.mission_run_id
	if objective.encounter == null:
		_cleanup()
		return
	if _objective_id == objective.objective_id and _run_id == MissionManager.mission_run_id:
		return
	_cleanup()
	_objective_id = objective.objective_id
	_encounter = objective.encounter
	_next_spawn = 0
	_counted_deaths.clear()
	_spawn_initial.call_deferred(_run_id, _objective_id)

func _spawn_initial(expected_run: int, expected_objective: StringName) -> void:
	if _spawning or not _is_active(expected_run, expected_objective):
		return
	_spawning = true
	for _index in 3:
		await get_tree().physics_frame
	if not _is_active(expected_run, expected_objective):
		_spawning = false
		return
	var map := get_world_3d().get_navigation_map()
	if NavigationServer3D.map_get_iteration_id(map) == 0:
		push_error("Mission encounter blocked: navigation map did not synchronize before spawning.")
		_spawning = false
		return
	_spawn_until_cap()
	_spawning = false

func _spawn_until_cap() -> void:
	if _encounter == null or not _is_active(_run_id, _objective_id):
		return
	var cap := maxi(1, _encounter.max_simultaneous_enemies)
	while _living.size() < cap and _next_spawn < _encounter.spawn_positions.size():
		var spawn_position: Vector3 = _encounter.spawn_positions[_next_spawn]
		var map := get_world_3d().get_navigation_map()
		var closest := NavigationServer3D.map_get_closest_point(map, to_global(spawn_position))
		if closest.distance_to(to_global(spawn_position)) > 0.75:
			push_error("Mission encounter spawn is outside the connected navigation corridor: %s" % spawn_position)
			return
		var actor := (_encounter.enemy_scene if _encounter.enemy_scene != null else ENEMY_SCENE).instantiate() as CharacterBody3D
		if actor == null:
			push_error("Mission encounter enemy scene root is not CharacterBody3D.")
			return
		add_child(actor)
		actor.position = spawn_position
		var instance_id := actor.get_instance_id()
		var health := actor.get_node_or_null("Health") as EnemyHealth
		if health == null:
			actor.queue_free()
			push_error("Mission encounter actor has no EnemyHealth node.")
			return
		_living[instance_id] = actor
		health.died.connect(_on_enemy_died.bind(instance_id, _run_id, _objective_id), CONNECT_ONE_SHOT)
		_next_spawn += 1

func _on_enemy_died(instance_id: int, callback_run: int, callback_objective: StringName) -> void:
	if not _is_active(callback_run, callback_objective) or _counted_deaths.has(instance_id):
		return
	if not _living.has(instance_id):
		return
	_living.erase(instance_id)
	_counted_deaths[instance_id] = true
	_spawn_until_cap()
	if _encounter != null and _next_spawn == _encounter.spawn_positions.size() and _living.is_empty():
		_report_clear.call_deferred(callback_run, callback_objective)

func _report_clear(callback_run: int, callback_objective: StringName) -> void:
	if _is_active(callback_run, callback_objective) and _encounter != null and _next_spawn == _encounter.spawn_positions.size() and _living.is_empty():
		MissionManager.report_objective_encounter_cleared(callback_objective, callback_run)

func _on_mission_ended(_mission_id: String, _reason: String) -> void:
	_cleanup()

func _on_mission_completed(_mission_id: String) -> void:
	_cleanup()

func _is_active(expected_run: int, expected_objective: StringName) -> bool:
	return expected_run == _run_id and expected_run == MissionManager.mission_run_id and expected_objective == _objective_id and MissionManager.mission_state == MissionManager.MissionState.ACTIVE

func _cleanup() -> void:
	_run_id = MissionManager.mission_run_id
	_objective_id = &""
	_encounter = null
	_next_spawn = 0
	_counted_deaths.clear()
	_spawning = false
	_living.clear()
	for child in get_children():
		child.queue_free()
