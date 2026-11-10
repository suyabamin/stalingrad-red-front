extends Node3D

var _passed: int = 0
var _failed: int = 0

func _ready() -> void:
	call_deferred("_run_checks")

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
		print("PASSED: %s" % description)
	else:
		_failed += 1
		push_error("FAILED: %s" % description)

func _run_checks() -> void:
	# 1. Main scene loading
	var packed_main := load("res://scenes/main/main.tscn") as PackedScene
	_check(packed_main != null, "Main scene loads successfully")
	var main := packed_main.instantiate() as Node3D
	add_child(main)
	await get_tree().process_frame

	# 2. Environment resource checks
	var world_env := main.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_check(world_env != null and world_env.environment != null, "WorldEnvironment has valid environment resource")
	var env := world_env.environment
	_check(env.fog_enabled, "Environment depth/height fog is enabled")
	_check(env.fog_density > 0.001 and env.fog_density <= 0.02, "Fog density is within subtle range (0.008)")
	_check(env.ambient_light_energy >= 0.65 and env.ambient_light_energy <= 0.85, "Ambient light energy is balanced")
	var dir_light := main.get_node_or_null("Sunlight") as DirectionalLight3D
	_check(dir_light != null and not dir_light.shadow_enabled, "Directional real-time shadows remain disabled")

	# 3. Atmospheric effects checks
	var atmo := main.get_node_or_null("Atmosphere") as Phase5CAtmosphere
	_check(atmo != null, "Atmosphere scene is instantiated under Main")
	var emitters := atmo.get_emitters()
	_check(emitters.size() == 4, "Atmosphere has exactly 4 CPUParticles3D emitters")
	var total_particles := atmo.get_active_particle_count()
	_check(total_particles <= 120, "Total active particles (%d) does not exceed limit (120)" % total_particles)
	var has_collision_or_trail := false
	for emitter in emitters:
		if emitter.has_node("CollisionShape3D") or emitter.get_child_count() > 0:
			has_collision_or_trail = true
	_check(not has_collision_or_trail, "Particle emitters have no collision shapes or subemitters")

	# Quality fallback test
	atmo.apply_low_quality(true)
	var low_particles := atmo.get_active_particle_count()
	_check(low_particles < total_particles and not atmo.smoke_west.emitting and not atmo.smoke_east.emitting, "Atmosphere low-quality fallback disables smoke and reduces particles")
	atmo.apply_low_quality(false)
	_check(atmo.get_active_particle_count() == total_particles, "Atmosphere restores full particle count on high quality")

	# 4. Environmental storytelling props
	var battlefield := main.get_node_or_null("Battlefield")
	_check(battlefield != null, "Battlefield node exists")
	var story_props := [
		"LandingDamagedCrate", "LandingCharredBeam", "LandingEquipmentTin", "LandingScorchedDebris",
		"TransitionDamagedSupplyBox", "TransitionBrokenTimberCross", "TransitionDiscardedCanister", "TransitionImpactCraterRim",
		"StreetFallenRafter", "StreetAbandonedAmmoBox", "StreetBrokenFenceSpur", "StreetMasonrySlab"
	]
	var found_props := 0
	var props_render_only := true
	for prop_name in story_props:
		var node := battlefield.get_node_or_null(prop_name)
		if node != null:
			found_props += 1
			if node is StaticBody3D or node.has_node("CollisionShape3D") or node.has_node("CollisionPolygon3D"):
				props_render_only = false
	_check(found_props == 12, "All 12 Phase 5C storytelling props exist")
	_check(props_render_only, "All Phase 5C storytelling props are strictly render-only (no collision shapes)")

	# Verify Phase 5B assets remain intact
	var b5_models := ["Phase05B1RuinedFacade", "Phase05B1Rubble", "Phase05B1SandbagWall", "Phase05B1MilitaryCrate"]
	var b5_intact := true
	for b5 in b5_models:
		if battlefield.get_node_or_null(b5) == null:
			b5_intact = false
	_check(b5_intact, "Phase 5B pilot models remain intact")

	# Verify no new objective triggers
	var trigger_count := 0
	for child in battlefield.get_children():
		if child.name.begins_with("ObjectiveTrigger"):
			trigger_count += 1
	_check(trigger_count == 5, "Objective trigger count remains exactly 5")

	# 5. Environmental soundscape checks
	var soundscape := main.get_node_or_null("Soundscape") as Phase5CSoundscape
	_check(soundscape != null, "Soundscape scene is instantiated under Main")
	var bus_idx := AudioServer.get_bus_index(&"Environment")
	_check(bus_idx != -1, "Environment audio bus exists in AudioServer")
	if bus_idx != -1:
		var send_bus := AudioServer.get_bus_send(bus_idx)
		_check(send_bus == &"Master", "Environment audio bus sends to Master")
		var vol := AudioServer.get_bus_volume_db(bus_idx)
		_check(vol <= -10.0, "Environment audio bus volume is subdued (<= -10 dB, actual: %.1f dB)" % vol)

	_check(soundscape.wind_player != null and soundscape.wind_player.stream != null, "Wind ambience audio player has valid stream")
	_check(soundscape.wind_player.bus == &"Environment", "Wind ambience uses Environment bus")
	var wind_stream := soundscape.wind_player.stream as AudioStreamWAV
	_check(wind_stream != null and wind_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and wind_stream.loop_end > 0, "Wind loop covers the full source instead of a zero-length loop")
	_check(soundscape.wind_player.volume_db >= 10.0, "Wind level compensates for the quiet source while retaining the attenuated Environment bus")
	_check(soundscape.artillery_player != null and soundscape.artillery_player.stream != null, "Distant artillery player has valid stream")
	_check(soundscape.artillery_player.bus == &"Environment", "Distant artillery uses Environment bus")
	_check(soundscape.artillery_player.unit_size >= 50.0 and soundscape.artillery_player.max_distance >= 200.0, "Distant artillery has adjusted long-range attenuation")
	_check(soundscape.battlefield_player != null and soundscape.battlefield_player.stream != null, "Distant battlefield player has valid stream")
	_check(soundscape.battlefield_player.bus == &"Environment", "Distant battlefield uses Environment bus")
	var mosin_data: WeaponData = load("res://resources/weapons/mosin_nagant.tres")
	_check(mosin_data.reload_sound != null and mosin_data.reload_sound.get_length() > 3.0 and mosin_data.reload_sound.get_length() <= 3.5, "Mosin reload playback contains one short natural action rather than repeated cycles")
	GameManager.set_paused(false)
	await get_tree().process_frame
	_check(soundscape.wind_player.playing, "Wind playback starts after the paused briefing is dismissed")
	soundscape._artillery_timer = 0.0
	await get_tree().create_timer(0.1).timeout
	_check(soundscape.artillery_player.playing, "Distant artillery timer dispatches playback during active mission time")

	# Weapon audio unaffected check
	var player := main.get_node_or_null("Player")
	var listener := player.find_child("AudioListener3D", true, false) as AudioListener3D if player != null else null
	_check(listener != null and listener.current, "Player camera owns the active 3D audio listener")
	var weapons := player.get_node_or_null("WeaponManager")
	_check(weapons != null, "Weapon manager is present on player")

	print("PHASE_05C_RUNTIME_CHECKS_PASSED=%d FAILED=%d" % [_passed, _failed])
	if _failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)
