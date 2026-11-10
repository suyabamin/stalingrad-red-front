@tool
extends SceneTree

func _init() -> void:
	var soldier_path := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"
	var soldier_res := load(soldier_path) as PackedScene
	var soldier := soldier_res.instantiate() as Node3D
	var skel: Skeleton3D = soldier.find_children("*", "Skeleton3D", true, false)[0]
	
	var rhand := skel.find_bone("RightHand")
	var lhand := skel.find_bone("LeftHand")
	var rgp := skel.get_bone_global_pose(rhand)
	var lgp := skel.get_bone_global_pose(lhand)
	
	print("RightHand global pose:")
	print("  origin: ", rgp.origin)
	print("  basis.x (local X in skel space): ", rgp.basis.x)
	print("  basis.y (local Y in skel space): ", rgp.basis.y)
	print("  basis.z (local Z in skel space): ", rgp.basis.z)
	
	print("LeftHand global pose:")
	print("  origin: ", lgp.origin)
	print("  basis.x (local X in skel space): ", lgp.basis.x)
	print("  basis.y (local Y in skel space): ", lgp.basis.y)
	print("  basis.z (local Z in skel space): ", lgp.basis.z)
	
	soldier.free()
	quit(0)
