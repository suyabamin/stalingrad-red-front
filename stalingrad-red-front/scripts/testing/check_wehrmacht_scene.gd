@tool
extends SceneTree

func _init() -> void:
	var wehrmacht_path := "res://assets/library/characters/german/wehrmacht_soldier/scene.gltf"
	var wehrmacht_res := load(wehrmacht_path) as PackedScene
	if wehrmacht_res != null:
		var inst := wehrmacht_res.instantiate()
		print("\n=== WEHRMACHT SOLDIER SCENE ===")
		for node in inst.find_children("*", "MeshInstance3D", true, false):
			var mi := node as MeshInstance3D
			print("Mesh: %s parent: %s AABB: %s" % [mi.name, mi.get_parent().name, mi.get_aabb().size])
		inst.free()
	quit(0)
