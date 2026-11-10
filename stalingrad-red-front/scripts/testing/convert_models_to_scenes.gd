extends SceneTree

func _init() -> void:
	print("--- GENERATING PACKED SCENES FOR 3D ASSETS ---")
	
	# 1. Wehrmacht Soldier Visual Scene
	_convert_model(
		"res://assets/library/characters/german/wehrmacht_soldier/scene.gltf",
		"res://scenes/characters/german_soldier_visual.tscn",
		Vector3(0.9, 0.9, 0.9), # Height becomes ~1.8m
		Vector3(0, -0.9, 0),    # Pivot centered at feet for CharacterBody3D (capsule is 1.8m high centered at y=0.9)
		"GermanSoldierVisual"
	)
	
	# 2. Panzer I Tank Scene
	_convert_model(
		"res://assets/library/vehicles/tanks/pzkpfw_i_ausf_a/scene.gltf",
		"res://scenes/vehicles/panzer_i.tscn",
		Vector3(0.08, 0.08, 0.08), # ~4.2m length, 2.2m width, 1.8m height
		Vector3(0, 0, 0),
		"PanzerI"
	)
	
	# 3. Crashed Hs 129 Aircraft Scene
	_convert_model(
		"res://assets/library/vehicles/destroyed_vehicles/crashed_hs129/scene.gltf",
		"res://scenes/vehicles/crashed_hs129.tscn",
		Vector3(0.065, 0.065, 0.065), # ~11.0m fuselage length
		Vector3(0, 0, 0),
		"CrashedHs129"
	)
	
	# 4. City Ruins Facade Scene
	_convert_model(
		"res://assets/library/environment/rubble/city_ruins_environment/scene.gltf",
		"res://scenes/environment/city_ruins_facade.tscn",
		Vector3(0.12, 0.12, 0.12), # ~12.5m frontage, 11m height
		Vector3(0, 0, 0),
		"CityRuinsFacade"
	)
	
	# 5. German Stick Grenades Pack Scene
	_convert_model(
		"res://assets/library/weapons/german/german_stick_grenades_pack.glb",
		"res://scenes/props/german_grenade_crate.tscn",
		Vector3(0.04, 0.04, 0.04), # ~0.57m crate bundle
		Vector3(0, 0, 0),
		"GermanGrenadeCrate"
	)
	
	print("\n--- ALL PACKED SCENES GENERATED SUCCESSFULLY ---")
	quit(0)

func _convert_model(gltf_path: String, tscn_path: String, scale_vec: Vector3, offset_vec: Vector3, root_name: String) -> void:
	print("Converting %s -> %s..." % [gltf_path, tscn_path])
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_file(gltf_path, state)
	if err != OK:
		printerr("Failed to append GLTF: %d" % err)
		return
	var raw_root: Node = doc.generate_scene(state)
	if raw_root == null:
		printerr("Failed to generate scene from GLTF")
		return
		
	var wrapper := Node3D.new()
	wrapper.name = root_name
	
	raw_root.name = "Model"
	raw_root.scale = scale_vec
	raw_root.position = offset_vec
	wrapper.add_child(raw_root)
	
	# In Godot, for PackedScene to save children properly, owner must be set on all descendants
	_set_owner_recursive(wrapper, wrapper)
	
	var packed := PackedScene.new()
	var pack_err := packed.pack(wrapper)
	if pack_err != OK:
		printerr("Failed to pack scene: %d" % pack_err)
		wrapper.free()
		return
		
	var save_err := ResourceSaver.save(packed, tscn_path)
	print("  Saved %s with err=%d" % [tscn_path, save_err])
	wrapper.free()

func _set_owner_recursive(node: Node, scene_owner: Node) -> void:
	for child in node.get_children():
		child.owner = scene_owner
		_set_owner_recursive(child, scene_owner)
