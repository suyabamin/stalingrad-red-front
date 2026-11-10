extends Node3D

const SOLDIER_FBX := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"
const SOLDIER_TEX := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier_Texture.png"
const WEAPONS_PACK := "res://assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf"
const OUTPUT_DIR := "res://docs/asset_readiness_previews/phase3/recovery_step1"

enum PoseType {
	STANDING,
	AIMING
}

var skeleton: Skeleton3D
var bone_attachment: BoneAttachment3D
var rifle_socket: Node3D
var rifle_root: Node3D
var camera: Camera3D
var soldier_root: Node3D

# Bone indices
var idx_hips := -1
var idx_spine := -1
var idx_spine1 := -1
var idx_spine2 := -1
var idx_neck := -1
var idx_head := -1

var idx_r_shoulder := -1
var idx_r_arm := -1
var idx_r_forearm := -1
var idx_r_hand := -1

var idx_l_shoulder := -1
var idx_l_arm := -1
var idx_l_forearm := -1
var idx_l_hand := -1

var right_thumb_bones: Array[int] = []
var right_index_bones: Array[int] = []
var right_middle_bones: Array[int] = []

var left_thumb_bones: Array[int] = []
var left_index_bones: Array[int] = []
var left_middle_bones: Array[int] = []

# Cached socket transform relative to RightHand
var socket_basis: Basis
var socket_pos: Vector3

func _ready() -> void:
	call_deferred("_run_capture_sequence")

func _run_capture_sequence() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	_setup_world()
	_setup_soldier()
	_setup_rifle()
	_cache_bones()
	
	for i in range(5):
		await get_tree().process_frame
	
	print("--- BEGINNING SCREENSHOT CAPTURE AT 1280x720 ---")
	
	# 1. Standing pose: full body
	apply_pose(PoseType.STANDING)
	_setup_camera_standing_full()
	for i in range(4):
		await get_tree().process_frame
	await _capture("1_german_soldier_standing_rifle.png")
	
	# 2. Standing pose: close-up of primary hand (right hand grip)
	_setup_camera_primary_hand_standing_closeup()
	for i in range(4):
		await get_tree().process_frame
	await _capture("2_primary_hand_rifle_grip.png")
	
	# 3. Aiming pose: close-up of secondary hand (left hand supporting handguard)
	apply_pose(PoseType.AIMING)
	_setup_camera_secondary_hand_closeup()
	for i in range(4):
		await get_tree().process_frame
	await _capture("3_secondary_hand_rifle_support.png")
	
	# 4. Aiming pose: complete aiming posture
	_setup_camera_aiming_pose()
	for i in range(4):
		await get_tree().process_frame
	await _capture("4_german_soldier_aiming_pose.png")
	
	print("--- SCREENSHOT CAPTURE COMPLETE ---")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(0)

func _setup_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.12, 0.14, 0.17)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.80, 0.82, 0.86)
	env.ambient_light_energy = 0.85
	
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	
	# Key Light (warm sun from front-right)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-28.0, 42.0, 0.0)
	sun.light_color = Color(1.0, 0.98, 0.93)
	sun.light_energy = 1.15
	sun.shadow_enabled = false
	add_child(sun)
	
	# Fill Light (cool sky fill from front-left)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-12.0, -65.0, 0.0)
	fill.light_color = Color(0.65, 0.75, 0.88)
	fill.light_energy = 0.65
	fill.shadow_enabled = false
	add_child(fill)
	
	# Back Rim Light (for silhouette separation)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(25.0, -155.0, 0.0)
	rim.light_color = Color(0.88, 0.94, 1.0)
	rim.light_energy = 0.60
	rim.shadow_enabled = false
	add_child(rim)
	
	camera = Camera3D.new()
	camera.name = "IsolatedCamera"
	camera.fov = 34.0
	add_child(camera)
	camera.current = true

func _setup_soldier() -> void:
	var res := load(SOLDIER_FBX) as PackedScene
	soldier_root = res.instantiate() as Node3D
	soldier_root.name = "GermanSoldier"
	add_child(soldier_root)
	
	var tex := load(SOLDIER_TEX) as Texture2D
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.roughness = 0.74
	mat.metallic = 0.08
	
	for child in soldier_root.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		mi.material_override = mat
	
	var skels := soldier_root.find_children("*", "Skeleton3D", true, false)
	skeleton = skels[0] as Skeleton3D

func _cache_bones() -> void:
	idx_hips = skeleton.find_bone("Hips")
	idx_spine = skeleton.find_bone("Spine")
	idx_spine1 = skeleton.find_bone("Spine1")
	idx_spine2 = skeleton.find_bone("Spine2")
	idx_neck = skeleton.find_bone("Neck")
	idx_head = skeleton.find_bone("Head")
	
	idx_r_shoulder = skeleton.find_bone("RightShoulder")
	idx_r_arm = skeleton.find_bone("RightArm")
	idx_r_forearm = skeleton.find_bone("RightForeArm")
	idx_r_hand = skeleton.find_bone("RightHand")
	
	idx_l_shoulder = skeleton.find_bone("LeftShoulder")
	idx_l_arm = skeleton.find_bone("LeftArm")
	idx_l_forearm = skeleton.find_bone("LeftForeArm")
	idx_l_hand = skeleton.find_bone("LeftHand")
	
	for i in range(1, 5):
		var rt := skeleton.find_bone("RightHandThumb%d" % i)
		if rt >= 0: right_thumb_bones.append(rt)
		var ri := skeleton.find_bone("RightHandIndex%d" % i)
		if ri >= 0: right_index_bones.append(ri)
		var rm := skeleton.find_bone("RightHandMiddle%d" % i)
		if rm >= 0: right_middle_bones.append(rm)
		
		var lt := skeleton.find_bone("LeftHandThumb%d" % i)
		if lt >= 0: left_thumb_bones.append(lt)
		var li := skeleton.find_bone("LeftHandIndex%d" % i)
		if li >= 0: left_index_bones.append(li)
		var lm := skeleton.find_bone("LeftHandMiddle%d" % i)
		if lm >= 0: left_middle_bones.append(lm)

func _setup_rifle() -> void:
	bone_attachment = BoneAttachment3D.new()
	bone_attachment.name = "RightHandAttachment"
	bone_attachment.bone_name = "RightHand"
	skeleton.add_child(bone_attachment)
	
	rifle_socket = Node3D.new()
	rifle_socket.name = "RifleSocket"
	bone_attachment.add_child(rifle_socket)
	
	# Load authentic German STG44 from weapons pack
	var pack_res := load(WEAPONS_PACK) as PackedScene
	var pack_inst := pack_res.instantiate()
	
	var stg_body: Node3D = null
	for child in pack_inst.find_children("*", "Node3D", true, false):
		if child.name == "STG 44_28":
			stg_body = child.duplicate(7) as Node3D
			break
	pack_inst.free()
	
	rifle_root = Node3D.new()
	rifle_root.name = "STG44_Model"
	rifle_socket.add_child(rifle_root)
	
	# Grip center in local coordinates is (-0.16338, 0.18534, 0.0)
	var grip_offset := Vector3(-0.163382, 0.185335, 0.0)
	stg_body.position = -grip_offset
	rifle_root.add_child(stg_body)
	
	# Target orientation of rifle in Aiming Pose:
	# Rifle +X (barrel) -> Forward (+Z)
	# Rifle +Y (sights) -> Up (+Y)
	# Rifle +Z (lateral)-> Right (+X)
	var target_rifle_basis := Basis(
		Vector3(0, 0, 1), # Rifle X -> World +Z
		Vector3(0, 1, 0), # Rifle Y -> World +Y
		Vector3(1, 0, 0)  # Rifle Z -> World +X
	)
	
	# In Aiming Pose, RightHand basis is:
	var rh_aim_basis := Basis.from_euler(Vector3(deg_to_rad(-10.0), deg_to_rad(15.0), deg_to_rad(-8.0)))
	socket_basis = rh_aim_basis.inverse() * target_rifle_basis
	
	# Socket position offset relative to RightHand origin (seats grip directly into palm)
	socket_pos = Vector3(-0.022, 0.030, -0.010)
	
	rifle_socket.transform = Transform3D(socket_basis, socket_pos)

func apply_pose(pose: PoseType) -> void:
	skeleton.clear_bones_global_pose_override()
	skeleton.reset_bone_poses()
	
	match pose:
		PoseType.STANDING:
			_apply_standing_pose()
		PoseType.AIMING:
			_apply_aiming_pose()
	
	skeleton.force_update_all_bone_transforms()

func _apply_standing_pose() -> void:
	# STANDING LOW-READY PATROL POSE:
	# Rifle angled diagonally across the body, pointing down and forward (~25 deg down).
	var spine_rot := Basis.from_euler(Vector3(deg_to_rad(-2.0), deg_to_rad(4.0), 0.0))
	var spine_pos := skeleton.get_bone_global_pose(idx_spine).origin
	skeleton.set_bone_global_pose_override(idx_spine, Transform3D(spine_rot, spine_pos), 1.0, true)
	
	var head_rot := Basis.from_euler(Vector3(deg_to_rad(2.0), deg_to_rad(-2.0), 0.0))
	var head_pos := skeleton.get_bone_global_pose(idx_head).origin
	skeleton.set_bone_global_pose_override(idx_head, Transform3D(head_rot, head_pos), 1.0, true)
	
	# Right Arm: angled so the rifle points forward and down across waist
	var r_shoulder := skeleton.get_bone_global_pose(idx_r_arm).origin
	var r_hand_pos := Vector3(-0.14, 1.12, 0.20)
	var r_elbow := _solve_two_bone(r_shoulder, r_hand_pos, 0.248, 0.275, Vector3(-0.25, 1.25, 0.08))
	
	var r_arm_basis := _basis_look_at(r_shoulder, r_elbow, Vector3.FORWARD)
	var r_fore_basis := _basis_look_at(r_elbow, r_hand_pos, Vector3.FORWARD)
	var r_hand_basis := Basis.from_euler(Vector3(deg_to_rad(-32.0), deg_to_rad(22.0), deg_to_rad(-12.0)))
	
	skeleton.set_bone_global_pose_override(idx_r_arm, Transform3D(r_arm_basis, r_shoulder), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_r_forearm, Transform3D(r_fore_basis, r_elbow), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_r_hand, Transform3D(r_hand_basis, r_hand_pos), 1.0, true)
	
	# Compute where the handguard is based on the rifle's actual world transform:
	var rifle_grip_world := r_hand_pos + r_hand_basis * socket_pos
	var rifle_barrel_dir := (r_hand_basis * socket_basis.x).normalized()
	var rifle_up_dir := (r_hand_basis * socket_basis.y).normalized()
	# Handguard is 0.20m forward along barrel and 0.035m below receiver (cupping from underneath)
	var handguard_world := rifle_grip_world + rifle_barrel_dir * 0.20 - rifle_up_dir * 0.035
	
	# Left Arm: reaches to handguard position
	var l_shoulder := skeleton.get_bone_global_pose(idx_l_arm).origin
	var l_hand_pos := handguard_world
	var l_elbow := _solve_two_bone(l_shoulder, l_hand_pos, 0.248, 0.275, Vector3(0.24, 1.15, 0.18))
	
	var l_arm_basis := _basis_look_at(l_shoulder, l_elbow, Vector3.FORWARD)
	var l_fore_basis := _basis_look_at(l_elbow, l_hand_pos, Vector3.FORWARD)
	# Left hand cupping upward/inward along barrel (palm normal UP, fingers forward)
	var l_hand_basis := Basis(
		Vector3(-0.95, 0.0, 0.31).normalized(),
		Vector3(0.12, 0.40, 0.91).normalized(),
		Vector3(-0.28, 0.91, -0.38).normalized()
	).orthonormalized()
	
	skeleton.set_bone_global_pose_override(idx_l_arm, Transform3D(l_arm_basis, l_shoulder), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_l_forearm, Transform3D(l_fore_basis, l_elbow), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_l_hand, Transform3D(l_hand_basis, l_hand_pos), 1.0, true)
	
	_curl_fingers_grip()

func _apply_aiming_pose() -> void:
	# COMBAT AIMING POSE:
	# Rifle horizontal, barrel pointing forward (+Z), buttstock seated against right shoulder.
	var spine_rot := Basis.from_euler(Vector3(deg_to_rad(6.0), deg_to_rad(8.0), deg_to_rad(-2.0)))
	var spine_pos := skeleton.get_bone_global_pose(idx_spine).origin
	skeleton.set_bone_global_pose_override(idx_spine, Transform3D(spine_rot, spine_pos), 1.0, true)
	
	# Head tilted into cheek weld along the sights line
	var head_pos := skeleton.get_bone_global_pose(idx_head).origin
	var head_rot := Basis.from_euler(Vector3(deg_to_rad(10.0), deg_to_rad(-12.0), deg_to_rad(8.0)))
	skeleton.set_bone_global_pose_override(idx_head, Transform3D(head_rot, head_pos), 1.0, true)
	
	# Right Hand at pistol grip:
	var r_shoulder := skeleton.get_bone_global_pose(idx_r_arm).origin
	var r_hand_pos := Vector3(-0.06, 1.41, 0.30)
	var r_elbow := _solve_two_bone(r_shoulder, r_hand_pos, 0.248, 0.275, Vector3(-0.25, 1.25, 0.10))
	
	var r_arm_basis := _basis_look_at(r_shoulder, r_elbow, Vector3.FORWARD)
	var r_fore_basis := _basis_look_at(r_elbow, r_hand_pos, Vector3.FORWARD)
	var r_hand_basis := Basis.from_euler(Vector3(deg_to_rad(-10.0), deg_to_rad(15.0), deg_to_rad(-8.0)))
	
	skeleton.set_bone_global_pose_override(idx_r_arm, Transform3D(r_arm_basis, r_shoulder), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_r_forearm, Transform3D(r_fore_basis, r_elbow), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_r_hand, Transform3D(r_hand_basis, r_hand_pos), 1.0, true)
	
	# Compute where the handguard is in aiming pose:
	var rifle_grip_world := r_hand_pos + r_hand_basis * socket_pos
	var rifle_barrel_dir := (r_hand_basis * socket_basis.x).normalized()
	var rifle_up_dir := (r_hand_basis * socket_basis.y).normalized()
	# Handguard is 0.21m forward along barrel and 0.035m below receiver (cupping from underneath)
	var handguard_world := rifle_grip_world + rifle_barrel_dir * 0.21 - rifle_up_dir * 0.035
	
	# Left Arm reaches forward to support handguard from below:
	var l_shoulder := skeleton.get_bone_global_pose(idx_l_arm).origin
	var l_hand_pos := handguard_world
	var l_elbow := _solve_two_bone(l_shoulder, l_hand_pos, 0.248, 0.275, Vector3(0.20, 1.25, 0.22))
	
	var l_arm_basis := _basis_look_at(l_shoulder, l_elbow, Vector3.FORWARD)
	var l_fore_basis := _basis_look_at(l_elbow, l_hand_pos, Vector3.FORWARD)
	# Left hand cupping under handguard (palm facing up, fingers forward along handguard)
	var l_hand_basis := Basis(
		Vector3(-0.95, 0.0, 0.31).normalized(),
		Vector3(0.10, 0.35, 0.93).normalized(),
		Vector3(-0.29, 0.94, -0.33).normalized()
	).orthonormalized()
	
	skeleton.set_bone_global_pose_override(idx_l_arm, Transform3D(l_arm_basis, l_shoulder), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_l_forearm, Transform3D(l_fore_basis, l_elbow), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_l_hand, Transform3D(l_hand_basis, l_hand_pos), 1.0, true)
	
	_curl_fingers_grip()

func _curl_fingers_grip() -> void:
	# Right hand fingers:
	# Thumb curls inward around the grip
	for b in right_thumb_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.RIGHT, deg_to_rad(35.0))
		skeleton.set_bone_pose_rotation(b, curl_q)
	
	# Index finger: extended along trigger guard, curling at tip
	for b in right_index_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(24.0))
		skeleton.set_bone_pose_rotation(b, curl_q)
	
	# Middle finger: tightly curled around pistol grip
	for b in right_middle_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(48.0))
		skeleton.set_bone_pose_rotation(b, curl_q)
	
	# Left hand fingers:
	# Thumb resting along top of handguard
	for b in left_thumb_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.RIGHT, deg_to_rad(25.0))
		skeleton.set_bone_pose_rotation(b, curl_q)
	
	# Index and middle fingers cupping under and around handguard
	for b in left_index_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(36.0))
		skeleton.set_bone_pose_rotation(b, curl_q)
	for b in left_middle_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(40.0))
		skeleton.set_bone_pose_rotation(b, curl_q)

func _solve_two_bone(root_pos: Vector3, target_pos: Vector3, len1: float, len2: float, hint_pos: Vector3) -> Vector3:
	var to_target := target_pos - root_pos
	var d := to_target.length()
	d = clampf(d, 0.001, len1 + len2 - 0.002)
	
	var cos_alpha := (len1 * len1 + d * d - len2 * len2) / (2.0 * len1 * d)
	cos_alpha = clampf(cos_alpha, -1.0, 1.0)
	var alpha := acos(cos_alpha)
	
	var target_dir := to_target.normalized()
	var hint_vec := hint_pos - root_pos
	var plane_normal := target_dir.cross(hint_vec).normalized()
	if plane_normal.length_squared() < 0.001:
		plane_normal = target_dir.cross(Vector3.UP).normalized()
	
	var bend_dir := plane_normal.cross(target_dir).normalized()
	var elbow_dir := (target_dir * cos(alpha) + bend_dir * sin(alpha)).normalized()
	return root_pos + elbow_dir * len1

func _basis_look_at(from: Vector3, to: Vector3, up_hint: Vector3) -> Basis:
	var y_axis := (to - from).normalized()
	var z_axis := y_axis.cross(up_hint).normalized()
	if z_axis.length_squared() < 0.001:
		z_axis = y_axis.cross(Vector3.RIGHT).normalized()
	var x_axis := y_axis.cross(z_axis).normalized()
	return Basis(x_axis, y_axis, z_axis)

# --- CAMERA FRAMING PRESETS ---

func _setup_camera_standing_full() -> void:
	# Full-body shot of standing soldier holding rifle (boots to helmet fully in frame)
	camera.fov = 34.0
	var target := Vector3(0.0, 0.95, 0.15)
	var cam_pos := Vector3(0.55, 1.15, 3.10)
	camera.look_at_from_position(cam_pos, target, Vector3.UP)

func _setup_camera_primary_hand_standing_closeup() -> void:
	# Close-up framing of right hand on pistol grip and trigger
	camera.fov = 24.0
	var r_hand_pos := skeleton.get_bone_global_pose(idx_r_hand).origin
	var target := r_hand_pos + Vector3(0.01, 0.02, 0.02)
	var cam_pos := target + Vector3(-0.42, 0.18, 0.50)
	camera.look_at_from_position(cam_pos, target, Vector3.UP)

func _setup_camera_secondary_hand_closeup() -> void:
	# Close-up framing of left hand supporting handguard in aiming pose
	camera.fov = 24.0
	var l_hand_pos := skeleton.get_bone_global_pose(idx_l_hand).origin
	var target := l_hand_pos + Vector3(0.0, 0.01, 0.0)
	var cam_pos := target + Vector3(0.42, 0.18, 0.48)
	camera.look_at_from_position(cam_pos, target, Vector3.UP)

func _setup_camera_aiming_pose() -> void:
	# 3/4 profile shot of combat aiming pose showing shoulder weld and iron sights alignment
	camera.fov = 30.0
	var target := Vector3(-0.02, 1.42, 0.32)
	var cam_pos := Vector3(-1.45, 1.52, 1.35)
	camera.look_at_from_position(cam_pos, target, Vector3.UP)

func _capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	if img != null:
		var full_path := ProjectSettings.globalize_path(OUTPUT_DIR.path_join(filename))
		var err := img.save_png(full_path)
		print("CAPTURED: %s (%dx%d) err=%d" % [filename, img.get_width(), img.get_height(), err])
	else:
		print("ERROR: Viewport image was null for %s" % filename)
