class_name GLTFAssetLoader
extends RefCounted

static var _cached_states: Dictionary = {}

static func instantiate_gltf(gltf_res_path: String) -> Node3D:
	if not _cached_states.has(gltf_res_path):
		var doc := GLTFDocument.new()
		var state := GLTFState.new()
		var err := doc.append_from_file(gltf_res_path, state)
		if err != OK:
			push_error("GLTFAssetLoader failed to load: %s (code %d)" % [gltf_res_path, err])
			return null
		_cached_states[gltf_res_path] = {"doc": doc, "state": state}
		
	var entry: Dictionary = _cached_states[gltf_res_path]
	var doc: GLTFDocument = entry["doc"]
	var state: GLTFState = entry["state"]
	return doc.generate_scene(state) as Node3D

static func instantiate_german_soldier() -> Node3D:
	var root := Node3D.new()
	root.name = "GermanSoldierVisual"
	var raw := instantiate_gltf("res://assets/library/characters/german/wehrmacht_soldier/scene.gltf")
	if raw != null:
		raw.name = "Model"
		# Original height is 2.0m. Human height ~1.8m:
		raw.scale = Vector3(0.9, 0.9, 0.9)
		# Ground offset so feet rest at local ground level y=0 when child of Visual (y=0.85)
		raw.position = Vector3(0, 0.05, 0)
		root.add_child(raw)
	return root

static func instantiate_panzer_i() -> Node3D:
	var root := Node3D.new()
	root.name = "PanzerI"
	var raw := instantiate_gltf("res://assets/library/vehicles/tanks/pzkpfw_i_ausf_a/scene.gltf")
	if raw != null:
		raw.name = "Model"
		# Scale down to historical ~4.2m length
		raw.scale = Vector3(0.08, 0.08, 0.08)
		root.add_child(raw)
	return root

static func instantiate_crashed_hs129() -> Node3D:
	var root := Node3D.new()
	root.name = "CrashedHs129"
	var raw := instantiate_gltf("res://assets/library/vehicles/destroyed_vehicles/crashed_hs129/scene.gltf")
	if raw != null:
		raw.name = "Model"
		# Scale down to ~11m fuselage length
		raw.scale = Vector3(0.065, 0.065, 0.065)
		# Tilted crash angle
		raw.rotation_degrees = Vector3(-12, 45, 18)
		root.add_child(raw)
	return root

static func instantiate_city_ruins() -> Node3D:
	var root := Node3D.new()
	root.name = "CityRuinsFacade"
	var raw := instantiate_gltf("res://assets/library/environment/rubble/city_ruins_environment/scene.gltf")
	if raw != null:
		raw.name = "Model"
		raw.scale = Vector3(0.12, 0.12, 0.12)
		root.add_child(raw)
	return root

static func instantiate_stick_grenades() -> Node3D:
	var root := Node3D.new()
	root.name = "GermanGrenadeCrate"
	var raw := instantiate_gltf("res://assets/library/weapons/german/german_stick_grenades_pack.glb")
	if raw != null:
		raw.name = "Model"
		raw.scale = Vector3(0.04, 0.04, 0.04)
		root.add_child(raw)
	return root
