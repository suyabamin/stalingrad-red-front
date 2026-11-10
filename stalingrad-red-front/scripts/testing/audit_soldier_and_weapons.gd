@tool
extends SceneTree

func _init() -> void:
	print("--- AUDITING SKELETON AND WEAPONS ---")
	
	# 1. Inspect LowpolySoldier.fbx
	var soldier_path := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"
	var soldier_res := load(soldier_path) as PackedScene
	if soldier_res == null:
		print("ERROR: Failed to load LowpolySoldier.fbx")
	else:
		var soldier_inst := soldier_res.instantiate()
		print("\n=== SOLDIER TREE ===")
		_print_tree(soldier_inst, "")
		var skeletons := soldier_inst.find_children("*", "Skeleton3D", true, false)
		if skeletons.size() > 0:
			var skel: Skeleton3D = skeletons[0]
			print("\n=== SKELETON BONES (count: %d) ===" % skel.get_bone_count())
			for i in range(skel.get_bone_count()):
				var bname := skel.get_bone_name(i)
				var parent_idx := skel.get_bone_parent(i)
				var parent_name := skel.get_bone_name(parent_idx) if parent_idx >= 0 else "ROOT"
				var rest := skel.get_bone_rest(i)
				var pose := skel.get_bone_pose(i)
				print("[%02d] %s (parent: %s [%d]) rest_pos: %s rest_rot_deg: %s" % [
					i, bname, parent_name, parent_idx, rest.origin, rest.basis.get_euler() * 180.0 / PI
				])
		soldier_inst.free()

	# 2. Inspect ww2_weapons_pack scene.gltf
	var weapons_path := "res://assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf"
	var weapons_res := load(weapons_path) as PackedScene
	if weapons_res == null:
		print("ERROR: Failed to load ww2_weapons_pack")
	else:
		var weapons_inst := weapons_res.instantiate()
		print("\n=== WEAPONS PACK TREE ===")
		_print_tree(weapons_inst, "")
		weapons_inst.free()

	# 3. Inspect mosin_nagant_lowpoly.glb
	var mosin_path := "res://assets/library/incoming_downloads/mosin_nagant/mosin_nagant_lowpoly.glb"
	var mosin_res := load(mosin_path) as PackedScene
	if mosin_res != null:
		var mosin_inst := mosin_res.instantiate()
		print("\n=== MOSIN TREE ===")
		_print_tree(mosin_inst, "")
		mosin_inst.free()

	print("\n--- AUDIT COMPLETE ---")
	quit(0)

func _print_tree(node: Node, indent: String) -> void:
	var info := "%s- %s (%s)" % [indent, node.name, node.get_class()]
	if node is MeshInstance3D:
		var aabb: AABB = node.get_aabb()
		info += " [Mesh AABB size: %s]" % [aabb.size]
	print(info)
	for child in node.get_children():
		_print_tree(child, indent + "  ")
