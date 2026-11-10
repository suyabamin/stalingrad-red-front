extends Node3D

const GLTFAssetLoader = preload("res://scripts/core/gltf_asset_loader.gd")

func _ready() -> void:
	print("--- ASSET TEST RANGE INITIALIZING ---")
	
	# Create environment and directional light for visual testing
	var env := WorldEnvironment.new()
	var env_res := Environment.new()
	env_res.background_mode = Environment.BG_COLOR
	env_res.background_color = Color(0.2, 0.25, 0.3)
	env_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env_res.ambient_light_color = Color(0.6, 0.6, 0.6)
	env.environment = env_res
	add_child(env)
	
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.light_color = Color(0.95, 0.95, 0.9)
	add_child(sun)
	
	var camera := Camera3D.new()
	add_child(camera)
	camera.position = Vector3(0, 3, 12)
	camera.look_at(Vector3(0, 1.5, 0))
	
	var start_ms := Time.get_ticks_msec()
	
	# Instantiate models via GLTFAssetLoader
	var assets := {
		"GermanSoldier": {"node": GLTFAssetLoader.instantiate_german_soldier(), "pos": Vector3(-4, 0, 0)},
		"PanzerI": {"node": GLTFAssetLoader.instantiate_panzer_i(), "pos": Vector3(0, 0, 0)},
		"CrashedHs129": {"node": GLTFAssetLoader.instantiate_crashed_hs129(), "pos": Vector3(8, 0, -5)},
		"CityRuins": {"node": GLTFAssetLoader.instantiate_city_ruins(), "pos": Vector3(-12, 0, -8)},
		"GrenadeCrate": {"node": GLTFAssetLoader.instantiate_stick_grenades(), "pos": Vector3(-2, 0, 1)}
	}
	
	var elapsed := Time.get_ticks_msec() - start_ms
	print("All 5 assets instantiated in %d ms" % elapsed)
	
	var passed_count := 0
	for key in assets:
		var item: Dictionary = assets[key]
		var node: Node3D = item["node"] as Node3D
		if node == null:
			printerr("FAILED to instantiate asset: %s" % key)
			continue
		node.position = item["pos"]
		add_child(node)
		
		var meshes := node.find_children("*", "MeshInstance3D", true, false)
		print("[PASS] %s instantiated with %d MeshInstance3D nodes at %s" % [key, meshes.size(), item["pos"]])
		passed_count += 1
		
	print("--- ASSET TEST RANGE VERIFICATION: %d/%d PASSED ---" % [passed_count, assets.size()])
	if passed_count == assets.size():
		print("STATUS: ALL ASSETS VALIDATED SUCCESSFULLY")
	else:
		printerr("STATUS: SOME ASSETS FAILED VALIDATION")
