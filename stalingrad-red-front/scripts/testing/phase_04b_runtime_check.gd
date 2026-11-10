extends Node
## Integration check for the briefing, sequential objectives, completion and restart.

const MISSION_SCENE: PackedScene = preload("res://scenes/main/main.tscn")

var _checks: int = 0
var _failures: int = 0
var _completion_signal_count: int = 0

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := MISSION_SCENE.instantiate()
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	await _frames(2)
	var hud: CanvasLayer = main.get_node("HUD") as CanvasLayer
	var player: PlayerController = main.get_node("Player") as PlayerController
	var battlefield: Node3D = main.get_node("Battlefield") as Node3D
	MissionManager.mission_completed.connect(_on_mission_completed)
	_check(MissionManager.mission_state == MissionManager.MissionState.READY, "Mission prepares in ready state")
	_check(get_tree().paused and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Briefing pauses play and releases the mouse")
	_check((hud.get("briefing_panel") as Control).visible, "Across the Volga briefing is visible")
	_check(MissionManager.get_objective_count() == 5, "Mission data provides all five ordered objectives")
	_check(MissionManager.current_definition.historical_context.contains("1942") and MissionManager.current_definition.briefing.to_lower().contains("fictional"), "Briefing separates historical context from fictional mission text")
	var spawn_z := player.global_position.z
	Input.action_press("move_forward")
	await _frames(20)
	Input.action_release("move_forward")
	_check(is_equal_approx(player.global_position.z, spawn_z), "Player movement is held while the briefing is open")
	var objective_three: ObjectiveTrigger = battlefield.get_node("ObjectiveTrigger03") as ObjectiveTrigger
	player.global_position = objective_three.global_position + Vector3(0.0, 0.08, 0.0)
	await _frames(3)
	_check(MissionManager.mission_state == MissionManager.MissionState.READY and MissionManager.completed_objective_count == 0, "Objectives cannot progress before Start Mission")
	player.global_position = Vector3(0.0, 0.08, 22.0)
	await _frames(3)
	(hud.get("start_mission_button") as Button).pressed.emit()
	_check(MissionManager.mission_state == MissionManager.MissionState.ACTIVE, "Start Mission activates objective one")
	_check(not get_tree().paused, "Starting gameplay unpauses the player")
	if DisplayServer.get_name() != "headless":
		_check(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "Starting gameplay restores mouse capture")
	else:
		print("NOT TESTED: OS mouse capture is unavailable in a headless display server")
	_check((hud.get("objective_progress_label") as Label).text == "OBJECTIVE 1 / 5", "Objective HUD shows the current sequence position")
	await _clear_current_encounter(battlefield)
	_check(MissionManager.current_objective_index == 0 and MissionManager.completed_objective_count == 0, "Clearing enemies alone cannot complete an objective before its location")
	player.global_position = objective_three.global_position + Vector3(0.0, 0.08, 0.0)
	await _frames(3)
	_check(MissionManager.current_objective_index == 0 and MissionManager.completed_objective_count == 0, "Entering a later trigger cannot skip the active first objective")
	player.global_position = Vector3(0.0, 0.08, 22.0)
	await _frames(3)
	Input.action_press("move_forward")
	await _frames(120)
	Input.action_release("move_forward")
	await _frames(2)
	_check(MissionManager.completed_objective_count == 1 and MissionManager.current_objective_index == 1, "Walking into the landing trigger completes objective one exactly once")
	_check(not MissionManager.complete_objective(&"landing_zone"), "Duplicate completion is rejected")
	_check((hud.get("objective_progress_label") as Label).text == "OBJECTIVE 2 / 5", "Objective HUD advances from signal after completion")
	var manager: WeaponManager = player.get_node("WeaponManager") as WeaponManager
	manager.switch_weapon(2)
	var ppsh: WeaponBase = manager.current_weapon
	var ammo_before: int = ppsh.magazine_ammo
	_check(ppsh.data.weapon_name == "PPSH-41" and ppsh.fire() and ppsh.magazine_ammo == ammo_before - 1, "PPSH switching, hitscan fire and ammunition remain functional")
	var ppsh_fire_audio := ppsh._audio_players.get("fire") as AudioStreamPlayer3D
	_check(ppsh_fire_audio != null and ppsh_fire_audio.playing, "PPSH weapon fire starts its configured audio playback")
	_check((hud.get("ammunition_label") as Label).text.contains("AMMO %d" % ppsh.magazine_ammo), "Existing ammo HUD updates after firing")
	manager._start_reload()
	_check(ppsh.is_reloading, "Existing weapon manager starts PPSH reload")
	var ppsh_reload_audio := ppsh._audio_players.get("reload") as AudioStreamPlayer3D
	_check(ppsh_reload_audio != null and ppsh_reload_audio.playing and ppsh_reload_audio.stream == ppsh.data.reload_sound, "PPSH reload starts its configured audio playback")
	(manager.get("_reload_timer") as Timer).stop()
	manager._on_reload_timeout()
	_check(not ppsh.is_reloading and ppsh.magazine_ammo == ppsh.data.magazine_capacity, "Existing PPSH reload restores its magazine")
	manager.switch_weapon(1)
	var mosin: WeaponBase = manager.current_weapon
	var mosin_ammo_before: int = mosin.magazine_ammo
	_check(mosin.data.weapon_name == "Mosin-Nagant" and mosin.fire() and mosin.magazine_ammo == mosin_ammo_before - 1, "Mosin switching and fire remain functional")
	var mosin_fire_audio := mosin._audio_players.get("fire") as AudioStreamPlayer3D
	_check(mosin_fire_audio != null and mosin_fire_audio.playing, "Mosin weapon fire starts its configured audio playback")
	Input.action_press("aim")
	for _index in 40:
		manager._update_aim_and_sway(0.1)
	Input.action_release("aim")
	_check(player.camera.fov < 80.0, "Existing aim-down-sights camera transition remains functional")
	for index in range(1, 5):
		await _clear_current_encounter(battlefield)
		await _visit_trigger(battlefield, player, index)
		if index < 4:
			_check(MissionManager.current_objective_index == index + 1 and MissionManager.completed_objective_count == index + 1, "Objective %d completes in order and activates the next" % (index + 1))
		else:
			_check(MissionManager.mission_state == MissionManager.MissionState.COMPLETED and MissionManager.completed_objective_count == 5, "Final trigger completes all five objectives and the mission")
	_check(_completion_signal_count == 1 and (hud.get("completion_panel") as Control).visible, "Mission completion screen and signal occur exactly once")
	_check(get_tree().paused and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Mission completion pauses play and releases the mouse")
	MissionManager.complete_current_mission()
	MissionManager.complete_current_mission()
	_check(_completion_signal_count == 1, "Repeated completion calls do not re-emit mission completion")
	(hud.get("completion_restart_button") as Button).pressed.emit()
	await _frames(4)
	var restarted_main := get_tree().current_scene
	_check(restarted_main != main and MissionManager.mission_state == MissionManager.MissionState.READY, "Completion restart reloads into the briefing")
	var restarted_hud: CanvasLayer = restarted_main.get_node("HUD") as CanvasLayer
	var restarted_player: PlayerController = restarted_main.get_node("Player") as PlayerController
	_check(restarted_player.health.current_health == restarted_player.health.maximum_health and (restarted_hud.get("briefing_panel") as Control).visible, "Completion restart restores player health and briefing")
	(restarted_hud.get("start_mission_button") as Button).pressed.emit()
	restarted_player.health.apply_damage(1000)
	await _frames(2)
	_check(restarted_player.is_dead and MissionManager.mission_state == MissionManager.MissionState.FAILED, "Player death fails the active objective and mission")
	var failed_encounters: MissionEncounterManager = restarted_main.get_node("Battlefield/EncounterManager") as MissionEncounterManager
	_check(failed_encounters.get_living_enemy_count() == 0 and failed_encounters.get_children().is_empty(), "Player death clears mission-owned enemies")
	_check((restarted_hud.get("death_panel") as Control).visible and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Existing player death/recovery UI still appears")
	_check((restarted_hud.get("health_label") as Label).text == "HEALTH 0 / 100", "Existing health HUD still updates at player death")
	(restarted_hud.get("death_restart_button") as Button).pressed.emit()
	await _frames(4)
	var death_restart_main := get_tree().current_scene
	var death_restart_player: PlayerController = death_restart_main.get_node("Player") as PlayerController
	_check(death_restart_player.health.current_health == death_restart_player.health.maximum_health and MissionManager.mission_state == MissionManager.MissionState.READY, "Death restart restores health and resets mission progress")
	(death_restart_main.get_node("HUD").get("start_mission_button") as Button).pressed.emit()
	await _frames(8)
	var fresh_encounters: MissionEncounterManager = death_restart_main.get_node("Battlefield/EncounterManager") as MissionEncounterManager
	_check(fresh_encounters.get_living_enemy_count() == 1 and fresh_encounters.get_spawned_enemy_count() == 1, "Death restart starts exactly one fresh first encounter")
	print("PHASE_04B_RUNTIME_CHECKS_PASSED=%d FAILED=%d" % [_checks - _failures, _failures])
	get_tree().quit(1 if _failures > 0 else 0)

func _visit_trigger(battlefield: Node3D, player: PlayerController, index: int) -> void:
	var trigger: ObjectiveTrigger = battlefield.get_node("ObjectiveTrigger%02d" % (index + 1)) as ObjectiveTrigger
	player.velocity = Vector3.ZERO
	player.global_position = trigger.global_position + Vector3(0.0, 0.08, 0.0)
	await _frames(4)

func _clear_current_encounter(battlefield: Node3D) -> void:
	var encounter_manager: MissionEncounterManager = battlefield.get_node("EncounterManager") as MissionEncounterManager
	var objective := MissionManager.get_current_objective()
	if objective == null or objective.encounter == null:
		return
	for _attempt in 8:
		await _frames(4)
		var enemies := encounter_manager.get_active_enemies()
		for enemy in enemies:
			(enemy.get_node("Health") as EnemyHealth).apply_damage(1000)
		if encounter_manager.get_spawned_enemy_count() >= objective.encounter.spawn_positions.size() and encounter_manager.get_living_enemy_count() == 0:
			await _frames(2)
			return

func _frames(count: int) -> void:
	for _index in count:
		await get_tree().physics_frame

func _check(condition: bool, description: String) -> void:
	if not condition:
		push_error("FAILED: " + description)
		_failures += 1
		return
	_checks += 1
	print("PASSED: " + description)

func _on_mission_completed(_mission_id: String) -> void:
	_completion_signal_count += 1
