@tool
extends SceneTree

func _init() -> void:
	var soldier_path := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"
	var tex_path := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier_Texture.png"
	var soldier_res := load(soldier_path) as PackedScene
	var tex := load(tex_path) as Texture2D
	
	print("Texture loaded: ", tex != null)
	if tex != null:
		print("Texture size: ", tex.get_size())
	
	var inst := soldier_res.instantiate()
	for child in inst.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		print("Mesh: ", mi.name)
		for s in range(mi.mesh.get_surface_count()):
			var mat := mi.get_active_material(s)
			print("  Surface %d mat: %s" % [s, mat])
			if mat is StandardMaterial3D:
				var sm := mat as StandardMaterial3D
				print("    albedo_color: ", sm.albedo_color, " albedo_texture: ", sm.albedo_texture)
				print("    metallic: ", sm.metallic, " roughness: ", sm.roughness)
	inst.free()
	quit(0)
