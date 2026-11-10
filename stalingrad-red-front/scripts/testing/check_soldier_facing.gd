@tool
extends SceneTree

func _init() -> void:
	var soldier_path := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"
	var soldier_res := load(soldier_path) as PackedScene
	var soldier := soldier_res.instantiate() as Node3D
	var skel: Skeleton3D = soldier.find_children("*", "Skeleton3D", true, false)[0]
	
	print("Head global pose: ", skel.get_bone_global_pose(skel.find_bone("Head")).origin)
	print("HeadTop_End: ", skel.get_bone_global_pose(skel.find_bone("HeadTop_End")).origin)
	var lfoot := skel.find_bone("LeftFoot")
	var ltoe := skel.find_bone("LeftToeBase")
	print("LeftFoot global pose: ", skel.get_bone_global_pose(lfoot).origin)
	print("LeftToeBase global pose: ", skel.get_bone_global_pose(ltoe).origin)
	
	# Check vertices of Soldier_1 mesh
	var mi := soldier.find_child("Soldier_1", true, false) as MeshInstance3D
	var aabb := mi.get_aabb()
	print("Soldier_1 AABB: min=%s max=%s" % [aabb.position, aabb.position + aabb.size])
	
	soldier.free()
	quit(0)
