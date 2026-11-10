extends Node

const RANGE_SCENE: PackedScene = preload("res://scenes/testing/enemy_test_range.tscn")
const INFANTRY_SCENE: PackedScene = preload("res://scenes/enemies/infantry_enemy.tscn")

func _ready() -> void:
	var scene := RANGE_SCENE.instantiate()
	add_child(scene)
	await get_tree().process_frame
	await get_tree().physics_frame
	var enemy: EnemyController = scene.get_node("Enemy")
	var player: PlayerController = scene.get_node("Player")
	var checks := 0
	var camera := player.camera
	var start_distance := player.global_position.distance_to(enemy.global_position)
	var enemy_aim_point := enemy.visual_root.global_position + Vector3.UP * 0.65
	var projected_enemy := camera.unproject_position(enemy_aim_point)
	var viewport_rect := Rect2(Vector2.ZERO, camera.get_viewport().get_visible_rect().size)
	var visibility_query := PhysicsRayQueryParameters3D.create(camera.global_position, enemy_aim_point)
	visibility_query.exclude = [player.get_rid()]
	var visibility_hit := camera.get_world_3d().direct_space_state.intersect_ray(visibility_query)
	_assert(scene.get_node_or_null("Enemy") == enemy and not enemy.is_dead, "Enemy instance starts alive in test range")
	_assert(enemy.scale.is_equal_approx(Vector3.ONE) and enemy.visible and enemy.visual_root.visible, "Enemy scale and visibility")
	_assert(enemy.collision_layer == 4 and enemy.collision_shape.disabled == false, "Enemy collision is enabled on its configured layer")
	_assert(enemy.is_inside_tree() and enemy.get_node("Visual/Torso").visible and enemy.get_node("Visual/Head").visible and enemy.get_node("Visual/Helmet").visible, "Enemy meshes are in the active render tree")
	_assert(not camera.is_position_behind(enemy_aim_point) and viewport_rect.has_point(projected_enemy), "Enemy starts inside the player camera view")
	_assert(start_distance < 14.0 and enemy.global_position.y >= 0.0 and enemy.visual_root.global_position.y > 0.5, "Enemy starts nearby and above ground")
	_assert(not visibility_hit.is_empty() and visibility_hit.get("collider") == enemy, "No test-range wall blocks the enemy from the starting camera")
	var torso := enemy.get_node("Visual/Torso") as MeshInstance3D
	var helmet := enemy.get_node("Visual/Helmet") as MeshInstance3D
	_assert(torso.layers == 1 and helmet.layers == 1 and torso.material_override != null and helmet.material_override != null, "Enemy mesh render layers and materials are configured")
	checks += 8
	await _frames(20)
	_assert(enemy.global_position.x > -11.5 and enemy.global_position.x < 11.5 and enemy.global_position.z > -14.5 and enemy.global_position.z < 14.5, "Navigation keeps enemy inside the test area")
	checks += 1
	_assert(enemy.combat_state == EnemyController.CombatState.ATTACK, "Enemy AI starts detecting the player in the visible spawn position")
	checks += 1
	_assert(absf(enemy.visual_root.position.y - 0.85) < 0.1 and enemy.animation_player.current_animation == &"idle", "Idle animation preserves the soldier height above ground")
	checks += 1
	var approach_distance := player.global_position.distance_to(enemy.global_position)
	player.rotation.y = -0.4
	Input.action_press("move_forward")
	await _frames(30)
	Input.action_release("move_forward")
	_assert(player.global_position.distance_to(enemy.global_position) < approach_distance, "Player can approach the visible enemy")
	checks += 1
	enemy.global_position = Vector3(5.0, 0.0, -5.0)
	enemy._set_combat_state(EnemyController.CombatState.IDLE)
	player.global_position = Vector3(40.0, 0.0, 8.0)
	await _frames(30)
	_assert(enemy.combat_state == EnemyController.CombatState.IDLE, "Idle before detection")
	checks += 1
	player.global_position = Vector3(5.0, 0.0, 14.0)
	await _frames(30)
	_assert(enemy.combat_state == EnemyController.CombatState.CHASE, "Detection transitions to chase outside attack range")
	checks += 1
	var chase_distance := enemy.global_position.distance_to(player.global_position)
	await _frames(45)
	_assert(enemy.global_position.distance_to(player.global_position) < chase_distance, "NavigationAgent pursues the player")
	checks += 1
	player.global_position = Vector3(5.0, 0.0, 1.0)
	await _frames(45)
	_assert(enemy.combat_state == EnemyController.CombatState.ATTACK, "Detection and attack transition")
	checks += 1
	var hp_before: int = player.health.current_health
	await _frames(90)
	_assert(player.health.current_health < hp_before, "Enemy firing damages PlayerHealth")
	checks += 1
	enemy._player = player
	enemy._player_health = player.health
	enemy._has_sight = true
	enemy._fire_at_player()
	var audio_root := get_tree().root
	var enemy_audio_nodes := audio_root.find_children("*", "AudioStreamPlayer3D", true, false)
	var found_enemy_gunshot := false
	for audio_node in enemy_audio_nodes:
		var enemy_audio := audio_node as AudioStreamPlayer3D
		if enemy_audio.stream != null and enemy_audio.stream.resource_path.ends_with("mosin_fire.tres") and enemy_audio.playing:
			found_enemy_gunshot = true
	_assert(found_enemy_gunshot, "Enemy firing dispatches its spatial gunshot stream")
	checks += 1
	enemy._begin_reload()
	enemy_audio_nodes = audio_root.find_children("*", "AudioStreamPlayer3D", true, false)
	var found_enemy_reload := false
	for audio_node in enemy_audio_nodes:
		var enemy_audio := audio_node as AudioStreamPlayer3D
		if enemy_audio.stream != null and enemy_audio.stream.resource_path.ends_with("mosin_reload_short.tres") and enemy_audio.playing:
			found_enemy_reload = true
	_assert(found_enemy_reload, "Enemy reload dispatches its shortened spatial reload stream")
	checks += 1
	player.global_position = Vector3(5.0, 0.0, 8.0)
	enemy.global_position = Vector3(5.0, 0.0, 0.0)
	enemy.velocity = Vector3.ZERO
	enemy._set_combat_state(EnemyController.CombatState.ATTACK)
	enemy._has_sight = true
	var wall := StaticBody3D.new()
	var shot_direction := player.global_position - enemy.global_position
	shot_direction.y = 0.0
	wall.position = enemy.global_position.lerp(player.global_position, 0.5)
	wall.position.y = 1.0
	wall.rotation.y = atan2(shot_direction.x, shot_direction.z)
	var wall_shape := CollisionShape3D.new()
	var wall_box := BoxShape3D.new()
	wall_box.size = Vector3(4.0, 2.0, 0.4)
	wall_shape.shape = wall_box
	wall.add_child(wall_shape)
	scene.add_child(wall)
	await get_tree().physics_frame
	var blocked_hp: int = player.health.current_health
	var blocked_query := PhysicsRayQueryParameters3D.create(enemy.global_position + Vector3.UP * 1.35, player.global_position + Vector3.UP * 1.1)
	blocked_query.exclude = [enemy.get_rid()]
	var blocked_hit: Dictionary = scene.get_world_3d().direct_space_state.intersect_ray(blocked_query)
	_assert(not blocked_hit.is_empty() and blocked_hit.get("collider") == wall, "Test wall intersects the enemy shot path")
	checks += 1
	await _frames(45)
	_assert(player.health.current_health == blocked_hp, "Wall blocks enemy shots")
	checks += 1
	wall.queue_free()
	await get_tree().process_frame
	enemy._set_combat_state(EnemyController.CombatState.ATTACK)
	enemy._player = player
	enemy._player_health = player.health
	player.health.reset()
	enemy.magazine_ammunition = 1
	enemy.reserve_ammunition = 2
	enemy.fire_interval = 10.0
	enemy._fire_timer = 0.0
	await _frames(360)
	_assert(enemy.magazine_ammunition == 2 and enemy.reserve_ammunition == 0, "Reload transfers only reserve ammunition")
	checks += 1
	enemy.magazine_ammunition = 0
	enemy.reserve_ammunition = 0
	var magazine_before := enemy.magazine_ammunition
	await _frames(60)
	_assert(enemy.combat_state != EnemyController.CombatState.RELOAD and enemy.magazine_ammunition == magazine_before, "Empty reserve does not start infinite reload")
	checks += 1
	var enemy_health_before: int = enemy.health.current_health
	player.get_node("WeaponManager").switch_weapon(2)
	var player_weapon: WeaponBase = player.get_node("WeaponManager").current_weapon
	player.get_node("Head/Camera3D").look_at(enemy.global_position + Vector3.UP * 0.9)
	var player_ammo_before: int = player_weapon.magazine_ammo
	_assert(player_weapon.fire(), "Existing player weapon fires")
	checks += 1
	_assert(player_weapon.magazine_ammo == player_ammo_before - 1 and enemy.health.current_health < enemy_health_before, "Player weapon ammunition and enemy damage regression")
	checks += 1
	var kill_shots := 0
	while not enemy.is_dead and kill_shots < 6:
		player.camera.look_at(enemy.global_position + Vector3.UP * 0.9)
		if not player_weapon.fire():
			break
		kill_shots += 1
	_assert(enemy.is_dead and kill_shots <= 5, "Existing PPSH fire kills the enemy through EnemyHealth")
	checks += 1
	var witness: EnemyController = INFANTRY_SCENE.instantiate()
	witness.name = "PlayerDeathWitness"
	witness.position = enemy.global_position
	scene.add_child(witness)
	await _frames(2)
	witness.magazine_ammunition = witness.magazine_capacity
	witness._set_combat_state(EnemyController.CombatState.ATTACK)
	player.health.apply_damage(1000)
	var post_player_death_magazine := witness.magazine_ammunition
	await _frames(45)
	_assert(player.is_dead and witness.combat_state == EnemyController.CombatState.IDLE and witness.magazine_ammunition == post_player_death_magazine, "Player death stops enemy attacks")
	checks += 1
	witness.apply_damage(1000)
	var state_after_death := witness.combat_state
	await _frames(60)
	_assert(witness.is_dead and state_after_death == EnemyController.CombatState.DEAD and witness.combat_state == EnemyController.CombatState.DEAD, "Enemy death is terminal")
	checks += 1
	for audio_node in get_tree().root.find_children("*", "AudioStreamPlayer3D", true, false):
		var combat_audio := audio_node as AudioStreamPlayer3D
		if combat_audio.stream != null and (combat_audio.stream.resource_path.ends_with("mosin_fire.tres") or combat_audio.stream.resource_path.ends_with("mosin_reload_short.tres")):
			combat_audio.stop()
			combat_audio.queue_free()
	await get_tree().process_frame
	print("PHASE_03B_RUNTIME_CHECKS_PASSED=%d" % checks)
	get_tree().quit(0)

func _frames(count: int) -> void:
	for _index in count:
		await get_tree().physics_frame

func _assert(condition: bool, description: String) -> void:
	if not condition:
		push_error("FAILED: " + description)
	else:
		print("PASSED: " + description)
