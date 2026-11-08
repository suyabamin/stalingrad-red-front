extends Node

func _ready() -> void:
	var packed := load("res://scenes/main/main.tscn") as PackedScene
	var main := packed.instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().process_frame
	await get_tree().physics_frame
	var battlefield: Node3D = main.get_node("Battlefield")
	var player: PlayerController = main.get_node("Player")
	var checks := 0
	_assert(main.get_node_or_null("HUD") != null and player.get_node_or_null("WeaponManager") != null, "Mission retains HUD and existing weapon manager")
	checks += 1
	_assert(main.find_children("*", "EnemyController", true, false).is_empty(), "Mission 01 remains free of Phase 3B enemies")
	checks += 1
	_assert(battlefield.get_node_or_null("VolgaWater") != null and battlefield.get_node_or_null("LandingPier") != null, "Volga landing and water landmarks instantiate")
	_assert(battlefield.get_node_or_null("RuinedBuildingShell") != null and battlefield.get_node_or_null("WreckedLorryChassis") != null, "Ruined street landmarks instantiate")
	checks += 2
	_assert(player.global_position.distance_to(Vector3(0, 0.08, 22)) < 0.1 and player.camera.current, "Player begins at landing with the first-person camera active")
	checks += 1
	var floor_query := PhysicsRayQueryParameters3D.create(Vector3(0, 2, 22), Vector3(0, -2, 22))
	floor_query.exclude = [player.get_rid()]
	var floor_hit: Dictionary = main.get_world_3d().direct_space_state.intersect_ray(floor_query)
	_assert(not floor_hit.is_empty() and (floor_hit.collider as Node).name == "ContinuousGround", "Continuous walkable ground collides at the player spawn")
	checks += 1
	var mission_before := MissionManager.current_mission_id
	_assert(mission_before == "mission_01", "Mission 01 manager starts with the battlefield")
	checks += 1
	Input.action_press("move_forward")
	for _index in 1200:
		await get_tree().physics_frame
	Input.action_release("move_forward")
	_assert(player.global_position.z < -70.0 and player.global_position.y > -0.1 and player.global_position.y < 0.3, "Player traverses from the landing through the ruined street while staying grounded")
	checks += 1
	player.position = Vector3.ZERO
	var weapon_manager: WeaponManager = player.get_node("WeaponManager")
	var ammo_before: int = weapon_manager.current_weapon.magazine_ammo
	_assert(weapon_manager.current_weapon.fire() and weapon_manager.current_weapon.magazine_ammo == ammo_before - 1, "Existing weapon fires and consumes ammunition in Mission 01")
	checks += 1
	var enemy_range := load("res://scenes/testing/enemy_test_range.tscn") as PackedScene
	var range_instance := enemy_range.instantiate()
	_assert(range_instance.get_node_or_null("Enemy") != null and range_instance.get_node_or_null("Player") != null, "F6 enemy test range still loads independently")
	checks += 1
	range_instance.free()
	print("PHASE_04A_RUNTIME_CHECKS_PASSED=%d" % checks)
	get_tree().quit(0)

func _assert(condition: bool, description: String) -> void:
	if condition:
		print("PASSED: " + description)
	else:
		push_error("FAILED: " + description)
		get_tree().quit(1)
