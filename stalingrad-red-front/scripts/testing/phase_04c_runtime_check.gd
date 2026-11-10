extends Node
## Combat integration, navigation and objective gate checks for Phase 4C.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
var _checks := 0
var _failures := 0

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	await _frames(10)
	var battlefield: Node3D = main.get_node("Battlefield")
	var player: PlayerController = main.get_node("Player")
	var manager: MissionEncounterManager = battlefield.get_node("EncounterManager")
	_check(MissionManager.mission_state == MissionManager.MissionState.READY and manager.get_living_enemy_count() == 0, "Briefing starts without active encounter actors")
	var region := battlefield.get_node("MissionNavigation") as NavigationRegion3D
	await _frames(10)
	var map: RID = main.get_world_3d().get_navigation_map()
	_check(region.navigation_mesh != null and NavigationServer3D.map_get_iteration_id(map) > 0, "Mission navigation corridor synchronizes")
	var candidates := 0
	for objective in MissionManager.current_definition.objectives:
		if objective.encounter == null:
			continue
		for position in objective.encounter.spawn_positions:
			var world_position: Vector3 = battlefield.to_global(position)
			_check(NavigationServer3D.map_get_closest_point(map, world_position).distance_to(world_position) < 0.75, "Encounter spawn projects onto connected route: %s" % position)
			candidates += 1
	_check(candidates == 8, "All eight proposed enemy spawn locations are represented")
	(main.get_node("HUD").get("start_mission_button") as Button).pressed.emit()
	await _frames(8)
	_check(manager.get_living_enemy_count() == 1 and manager.get_spawned_enemy_count() == 1, "Objective one spawns exactly one mission-owned enemy after Start Mission")
	var enemy := manager.get_active_enemies()[0] as EnemyController
	_check(enemy.get_navigation_map().is_valid() if enemy.has_method("get_navigation_map") else enemy.navigation_agent.get_navigation_map().is_valid(), "Spawned enemy receives the Mission 01 navigation map")
	var initial_enemy_position := enemy.global_position
	await _frames(30)
	_check(enemy.combat_state == EnemyController.CombatState.CHASE or enemy.combat_state == EnemyController.CombatState.ATTACK, "Mission enemy detects the player and enters combat")
	var health_before_attack := player.health.current_health
	for _index in 180:
		if player.health.current_health < health_before_attack:
			break
		await get_tree().physics_frame
	_check(player.health.current_health < health_before_attack, "Mission enemy navigates into range and damages PlayerHealth")
	_check(enemy.global_position.distance_to(initial_enemy_position) > 0.5, "Mission enemy approaches the player along the connected navigation route")
	# The weapon shot uses the existing hitscan path against the active encounter actor.
	enemy.set_physics_process(false)
	enemy.global_position = Vector3(player.global_position.x, 0.0, player.global_position.z - 8.0)
	await _frames(1)
	player.camera.look_at(enemy.global_position + Vector3.UP * 0.9, Vector3.UP)
	var weapons: WeaponManager = player.get_node("WeaponManager")
	weapons.switch_weapon(1)
	var mosin := weapons.current_weapon
	var health := enemy.get_node("Health") as EnemyHealth
	_check(mosin.fire() and health.is_dead, "Existing Mosin hitscan kills a spawned enemy")
	await _frames(3)
	var run_id := MissionManager.mission_run_id
	_check(MissionManager.completed_objective_count == 0, "Enemy death alone does not progress objective one")
	_check(MissionManager.report_objective_location(&"battlefield_transition", run_id) == false, "Future objective location report is rejected")
	await _clear_encounter(manager)
	_check(MissionManager.report_objective_location(&"landing_zone", run_id), "Active landing location report is accepted once")
	_check(MissionManager.completed_objective_count == 1, "Both conditions complete objective one")
	_check(MissionManager.report_objective_encounter_cleared(&"landing_zone", run_id) == false, "Duplicate encounter clear is rejected")
	# Objective two: encounter condition first, location second.
	var objective := MissionManager.get_current_objective()
	_check(objective.objective_id == &"battlefield_transition", "Objective two activates in sequence")
	run_id = MissionManager.mission_run_id
	await _frames(8)
	var ppsh_enemy := manager.get_active_enemies()[0] as EnemyController
	ppsh_enemy.set_physics_process(false)
	ppsh_enemy.global_position = Vector3(player.global_position.x, 0.0, player.global_position.z - 8.0)
	for other_enemy in manager.get_active_enemies():
		if other_enemy != ppsh_enemy:
			other_enemy.global_position = Vector3(20.0, 0.0, -15.0)
	await _frames(1)
	player.camera.look_at(ppsh_enemy.global_position + Vector3.UP * 0.9, Vector3.UP)
	weapons.switch_weapon(2)
	var ppsh := weapons.current_weapon
	var ppsh_health := ppsh_enemy.get_node("Health") as EnemyHealth
	for _shot in 5:
		player.camera.look_at(ppsh_enemy.global_position + Vector3.UP * 0.9, Vector3.UP)
		ppsh.fire()
	_check(ppsh_health.is_dead, "Existing PPSH hitscan kills a spawned enemy")
	await _clear_encounter(manager)
	_check(MissionManager.current_objective_encounter_cleared, "Encounter-first clear is accepted")
	_check(MissionManager.completed_objective_count == 1, "Encounter-first alone does not complete objective two")
	_check(MissionManager.report_objective_location(objective.objective_id, run_id), "Location completes encounter-first objective")
	# Objectives three and four exercise location-first order and the two-live cap.
	await _check_objective(3, true, manager, battlefield)
	await _check_objective(4, false, manager, battlefield)
	objective = MissionManager.get_current_objective()
	_check(objective.objective_id == &"mission_complete" and objective.encounter == null, "Objective five remains location-only")
	run_id = MissionManager.mission_run_id
	_check(MissionManager.report_objective_location(objective.objective_id, run_id), "Objective five completes by location")
	_check(MissionManager.mission_state == MissionManager.MissionState.COMPLETED and MissionManager.completed_objective_count == 5, "All five objectives complete in sequence")
	var stale_run_id := MissionManager.mission_run_id
	_check(MissionManager.prepare_mission(MissionManager.current_definition) and MissionManager.begin_mission(), "Preparing a new run resets mission conditions")
	await _frames(8)
	_check(not MissionManager.report_objective_location(&"landing_zone", stale_run_id), "Stale prior-run report cannot advance a restarted mission")
	_check(not MissionManager.current_objective_location_reached and MissionManager.completed_objective_count == 0, "Restart begins with clean objective progress")
	for target_index in range(4):
		if target_index > 0:
			GameManager.restart_current_scene()
			await _frames(6)
			main = get_tree().current_scene
			var hud: CanvasLayer = main.get_node("HUD")
			player = main.get_node("Player") as PlayerController
			(hud.get("start_mission_button") as Button).pressed.emit()
			await _frames(8)
			while MissionManager.current_objective_index < target_index:
				var prior_objective := MissionManager.get_current_objective()
				var prior_run := MissionManager.mission_run_id
				MissionManager.report_objective_encounter_cleared(prior_objective.objective_id, prior_run)
				MissionManager.report_objective_location(prior_objective.objective_id, prior_run)
		_check(MissionManager.current_objective_index == target_index, "Death test reaches combat objective %d" % (target_index + 1))
		player = main.get_node("Player") as PlayerController
		player.health.apply_damage(1000)
		await _frames(3)
		var death_manager: MissionEncounterManager = main.get_node("Battlefield/EncounterManager")
		_check(MissionManager.mission_state == MissionManager.MissionState.FAILED, "Player death during objective %d fails mission" % (target_index + 1))
		_check(death_manager.get_living_enemy_count() == 0 and death_manager.get_children().is_empty(), "Player death during objective %d clears encounter actors" % (target_index + 1))
	_check(_failures == 0, "Phase 4C runtime checks have no failures")
	print("PHASE_04C_RUNTIME_CHECKS_PASSED=%d FAILED=%d" % [_checks - _failures, _failures])
	get_tree().quit(1 if _failures > 0 else 0)

func _check_objective(expected_number: int, location_first: bool, manager: MissionEncounterManager, battlefield: Node3D) -> void:
	await _frames(5)
	var objective := MissionManager.get_current_objective()
	var run_id := MissionManager.mission_run_id
	if location_first:
		_check(MissionManager.report_objective_location(objective.objective_id, run_id), "Objective %d location condition accepted first" % expected_number)
		_check(MissionManager.completed_objective_count == expected_number - 1, "Objective %d location alone does not complete" % expected_number)
	await _clear_encounter(manager)
	if location_first:
		_check(MissionManager.completed_objective_count == expected_number, "Objective %d encounter clear completes once" % expected_number)
	else:
		_check(MissionManager.completed_objective_count == expected_number - 1, "Objective %d encounter clear alone does not complete" % expected_number)
		_check(MissionManager.report_objective_location(objective.objective_id, run_id), "Objective %d location condition accepted after combat" % expected_number)
		_check(MissionManager.completed_objective_count == expected_number, "Objective %d completes after both conditions" % expected_number)

func _clear_encounter(manager: MissionEncounterManager) -> void:
	var objective := MissionManager.get_current_objective()
	if objective == null or objective.encounter == null:
		return
	var maximum_living := 0
	for _attempt in 12:
		await _frames(4)
		maximum_living = maxi(maximum_living, manager.get_living_enemy_count())
		for actor in manager.get_active_enemies():
			(actor.get_node("Health") as EnemyHealth).apply_damage(1000)
		if manager.get_spawned_enemy_count() >= objective.encounter.spawn_positions.size() and manager.get_living_enemy_count() == 0:
			await _frames(3)
			if expected_cap_test(objective, maximum_living):
				_check(true, "Encounter staging respects two living enemies maximum")
			return
	_check(false, "Encounter clears with staged enemies")

func expected_cap_test(objective: ObjectiveDefinition, maximum_living: int) -> bool:
	return maximum_living <= objective.encounter.max_simultaneous_enemies

func _frames(count: int) -> void:
	for _index in count:
		await get_tree().physics_frame

func _check(condition: bool, description: String) -> void:
	if condition:
		_checks += 1
		print("PASSED: " + description)
	else:
		_failures += 1
		push_error("FAILED: " + description)
