@tool
extends SceneTree

func _init() -> void:
	print("=== INSPECTING RIFLE CANDIDATES ===")
	
	# 1. STG 44 from ww2_weapons_pack
	var weapons_path := "res://assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf"
	var weapons_res := load(weapons_path) as PackedScene
	if weapons_res != null:
		var root := weapons_res.instantiate()
		for node in root.find_children("*", "Node3D", true, false):
			if "stg" in node.name.to_lower():
				print("\nSTG NODE: %s (class: %s, transform: %s)" % [node.name, node.get_class(), node.transform])
				for c in node.get_children():
					print("  child: %s (%s)" % [c.name, c.get_class()])
					if c is MeshInstance3D:
						print("    mesh: %s, aabb: %s, mat: %s" % [c.mesh.resource_name, c.get_aabb(), c.get_active_material(0)])
		root.free()

	# 2. Mosin Nagant
	var mosin_path := "res://assets/library/incoming_downloads/mosin_nagant/mosin_nagant_lowpoly.glb"
	var mosin_res := load(mosin_path) as PackedScene
	if mosin_res != null:
		var root := mosin_res.instantiate()
		for node in root.find_children("*", "MeshInstance3D", true, false):
			var mi := node as MeshInstance3D
			print("\nMOSIN MESH: %s, aabb: %s, xform: %s, mat: %s" % [mi.name, mi.get_aabb(), mi.global_transform, mi.get_active_material(0)])
		root.free()

	quit(0)
