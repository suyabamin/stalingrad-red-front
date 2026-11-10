@tool
extends SceneTree

func _init() -> void:
	var pack_path := "res://assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf"
	var pack_res := load(pack_path) as PackedScene
	var pack_inst := pack_res.instantiate()
	
	# Find STG nodes
	var stg_nodes: Array[Node] = []
	for n in pack_inst.find_children("*", "Node3D", true, false):
		if "stg" in n.name.to_lower():
			stg_nodes.append(n)
			print("STG node: ", n.name, " class: ", n.get_class(), " xform: ", n.transform)
			for c in n.get_children():
				print("   child: ", c.name, " class: ", c.get_class(), " xform: ", c.transform)
	
	pack_inst.free()
	quit(0)
