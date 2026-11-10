@tool
extends SceneTree

func _init() -> void:
	var weapons_path := "res://assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf"
	var weapons_res := load(weapons_path) as PackedScene
	if weapons_res != null:
		var weapons_inst := weapons_res.instantiate()
		print("\n=== WEAPONS PACK NODES ===")
		for child in weapons_inst.find_children("*", "Node3D", true, false):
			if child.get_parent() == weapons_inst or child.get_parent().name.begins_with("Sketchfab") or child.get_parent().name.begins_with("GLTF"):
				print("Top group: %s" % child.name)
			# print if it looks like a weapon name
			var lower := child.name.to_lower()
			if ("kar" in lower or "k98" in lower or "gewehr" in lower or "mauser" in lower or "mosin" in lower or "stg" in lower or "mp40" in lower or "thompson" in lower or "colt" in lower or "ppsh" in lower or "m1" in lower or "lee" in lower or "enfield" in lower or "springfield" in lower or "rifle" in lower):
				print("WEAPON MATCH: %s (parent: %s, children: %d)" % [child.name, child.get_parent().name, child.get_child_count()])
		weapons_inst.free()
	quit(0)
