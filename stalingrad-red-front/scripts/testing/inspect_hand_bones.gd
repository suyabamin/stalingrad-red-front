@tool
extends SceneTree

func _init() -> void:
	var soldier_path := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"
	var soldier_res := load(soldier_path) as PackedScene
	var soldier := soldier_res.instantiate() as Node3D
	
	var skel: Skeleton3D = soldier.find_children("*", "Skeleton3D", true, false)[0]
	print("=== HAND BONES AND LOCAL TRANSFORMS ===")
	for bname in [
		"RightShoulder", "RightArm", "RightForeArm", "RightHand",
		"RightHandThumb1", "RightHandThumb2", "RightHandThumb3", "RightHandThumb4",
		"RightHandIndex1", "RightHandIndex2", "RightHandIndex3", "RightHandIndex4",
		"RightHandMiddle1", "RightHandMiddle2", "RightHandMiddle3", "RightHandMiddle4",
		"LeftShoulder", "LeftArm", "LeftForeArm", "LeftHand",
		"LeftHandThumb1", "LeftHandIndex1", "LeftHandMiddle1"
	]:
		var idx := skel.find_bone(bname)
		var rest := skel.get_bone_rest(idx)
		var gpose := skel.get_bone_global_pose(idx)
		print("%-20s [idx %2d] rest_trans=%s rest_euler=%s | gpose_origin=%s" % [
			bname, idx, rest.origin, rest.basis.get_euler() * 180.0 / PI, gpose.origin
		])
	
	soldier.free()
	quit(0)
