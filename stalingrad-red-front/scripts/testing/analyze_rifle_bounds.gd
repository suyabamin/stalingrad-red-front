@tool
extends SceneTree

func _init() -> void:
	print("--- EXTRACTING AND ANALYZING RIFLES ---")
	
	# 1. STG 44
	var pack_path := "res://assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf"
	var pack_res := load(pack_path) as PackedScene
	var pack_inst := pack_res.instantiate()
	
	var stg_root := Node3D.new()
	stg_root.name = "STG44"
	for child in pack_inst.find_children("*", "Node3D", true, false):
		if child.name == "STG 44_28" or child.name == "STG 44 Maganize_32":
			var dupe := child.duplicate(7) as Node3D
			stg_root.add_child(dupe)
			print("Added STG component: %s with %d children" % [dupe.name, dupe.get_child_count()])
	
	var aabb_stg := _calc_aabb(stg_root)
	print("STG44 total local AABB: origin=%s, size=%s" % [aabb_stg.position, aabb_stg.size])
	print("STG44 length along X=%f, Y=%f, Z=%f" % [aabb_stg.size.x, aabb_stg.size.y, aabb_stg.size.z])
	stg_root.free()
	pack_inst.free()
	
	# 2. Mosin Nagant
	var mosin_path := "res://assets/library/incoming_downloads/mosin_nagant/mosin_nagant_lowpoly.glb"
	var mosin_res := load(mosin_path) as PackedScene
	var mosin_inst := mosin_res.instantiate()
	var mosin_mesh := mosin_inst.find_child("MosinNagant_Mosin_0", true, false) as MeshInstance3D
	if mosin_mesh != null:
		var aabb_mosin := mosin_mesh.get_aabb()
		print("Mosin mesh local AABB: origin=%s, size=%s" % [aabb_mosin.position, aabb_mosin.size])
		print("Mosin length along X=%f, Y=%f, Z=%f" % [aabb_mosin.size.x, aabb_mosin.size.y, aabb_mosin.size.z])
	mosin_inst.free()
	
	quit(0)

func _calc_aabb(node: Node3D) -> AABB:
	var total := AABB()
	var first := true
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		if mi.mesh == null:
			continue
		var aabb: AABB = mi.transform * mi.get_aabb()
		if first:
			total = aabb
			first = false
		else:
			total = total.merge(aabb)
	return total
