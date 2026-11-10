@tool
extends SceneTree

func _init() -> void:
	var soldier_path := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"
	var soldier_res := load(soldier_path) as PackedScene
	var soldier := soldier_res.instantiate() as Node3D
	var skel: Skeleton3D = soldier.find_children("*", "Skeleton3D", true, false)[0]
	
	for bname in ["RightArm", "RightForeArm", "RightHand", "LeftArm", "LeftForeArm", "LeftHand"]:
		var idx := skel.find_bone(bname)
		var rest := skel.get_bone_rest(idx)
		print("\nBONE: %s" % bname)
		print("  rest origin: %s" % rest.origin)
		print("  rest basis X (local): %s" % rest.basis.x)
		print("  rest basis Y (local): %s" % rest.basis.y)
		print("  rest basis Z (local): %s" % rest.basis.z)
	
	soldier.free()
	quit(0)
