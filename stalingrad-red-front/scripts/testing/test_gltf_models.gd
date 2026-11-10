extends SceneTree

func _init() -> void:
	print("--- TESTING GLTF LOADING VIA GLTFDOCUMENT ---")
	
	var models := {
		"wehrmacht_soldier": "res://assets/library/characters/german/wehrmacht_soldier/scene.gltf",
		"pzkpfw_i_ausf_a": "res://assets/library/vehicles/tanks/pzkpfw_i_ausf_a/scene.gltf",
		"crashed_hs129": "res://assets/library/vehicles/destroyed_vehicles/crashed_hs129/scene.gltf",
		"city_ruins_environment": "res://assets/library/environment/rubble/city_ruins_environment/scene.gltf",
		"german_stick_grenades": "res://assets/library/weapons/german/german_stick_grenades_pack.glb",
		"rock_09": "res://assets/library/environment/terrain/rock_09/rock_09_2k.gltf"
	}
	
	for name in models:
		var path: String = models[name]
		print("\nLoading model '%s' from %s..." % [name, path])
		var doc := GLTFDocument.new()
		var state := GLTFState.new()
		var err := doc.append_from_file(path, state)
		if err != OK:
			print("  [ERROR] append_from_file failed with code: %d" % err)
			continue
		var root: Node = doc.generate_scene(state)
		if root == null:
			print("  [ERROR] generate_scene returned null")
			continue
			
		var meshes: Array[MeshInstance3D] = []
		_find_meshes(root, meshes)
		
		var total_triangles := 0
		var aabb := AABB()
		var first_aabb := true
		
		for mi in meshes:
			if mi.mesh:
				var face_count := mi.mesh.get_faces().size() / 3
				total_triangles += face_count
				var mi_aabb := mi.get_aabb()
				if first_aabb:
					aabb = mi_aabb
					first_aabb = false
				else:
					aabb = aabb.merge(mi_aabb)
		
		print("  [OK] Successfully loaded '%s'!" % name)
		print("       MeshInstance3D count: %d" % meshes.size())
		print("       Total triangles: %d" % total_triangles)
		print("       AABB Size: %s, Center: %s" % [aabb.size, aabb.get_center()])
		root.free()

	print("\n--- GLTF LOADING TEST COMPLETED ---")
	quit(0)

func _find_meshes(node: Node, out_meshes: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		out_meshes.append(node)
	for child in node.get_children():
		_find_meshes(child, out_meshes)
