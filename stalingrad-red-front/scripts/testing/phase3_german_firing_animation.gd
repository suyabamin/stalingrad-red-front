extends Node3D

const SOLDIER_FBX := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"
const SOLDIER_TEX := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier_Texture.png"
const WEAPONS_PACK := "res://assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf"
const OUTPUT_DIR := "res://docs/asset_readiness_previews/phase3/recovery_step2"
const TEST_AUDIO_PATH := "res://assets/library/audio/weapons/soviet/mosin_fire.wav"

var skeleton: Skeleton3D
var bone_attachment: BoneAttachment3D
var rifle_socket: Node3D
var rifle_root: Node3D
var camera: Camera3D
var soldier_root: Node3D
var anim_player: AnimationPlayer

# VFX nodes
var muzzle_flash_root: Node3D
var muzzle_light: OmniLight3D
var smoke_particles: CPUParticles3D
var shell_casing_mesh: MeshInstance3D
var audio_player: AudioStreamPlayer3D

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

# StG 44 geometry anchors in rifle_root space
# Barrel bore center: grip offset (-0.163382, 0.185335, 0.0), bore is at X=0.635, Y=0.138
# Receiver ejection port: near rear of barrel / magazine top
var muzzle_root_pos := Vector3(0.635, 0.138, 0.0)
var ejection_port_pos := Vector3(0.09, 0.08, 0.025)

# Baseline Aiming Pose bone transforms (for drift verification)
var baseline_spine: Transform3D
var baseline_head: Transform3D
var baseline_r_arm: Transform3D
var baseline_r_forearm: Transform3D
var baseline_r_hand: Transform3D
var baseline_l_arm: Transform3D
var baseline_l_forearm: Transform3D
var baseline_l_hand: Transform3D

# Animation parameters
var firing_duration := 0.26

func _ready() -> void:
	call_deferred("_run_test_and_capture_sequence")

func _run_test_and_capture_sequence() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	_setup_world()
	_setup_soldier()
	_setup_rifle()
	_cache_bones()
	_setup_vfx_and_audio()
	_setup_animation_player()
	
	for i in range(5):
		await get_tree().process_frame
	
	print("--- PHASE 3 RECOVERY STEP 2: VERIFYING BASELINE AIM POSE ---")
	_eval_firing_pose(0.0, false)
	_cache_baseline_aim_pose()
	
	print("--- RUNNING REPEATED FIRING & DRIFT VERIFICATION (10 CYCLES) ---")
	var max_drift := _test_repeated_firing_drift(10)
	print("RESULT: Maximum cumulative drift across 10 firing cycles: %.6f mm" % (max_drift * 1000.0))
	assert(max_drift < 0.0001, "Drift exceeded tolerance!")
	
	# Clear any particles and reset pose before capturing screenshots
	smoke_particles.emitting = false
	_eval_firing_pose(0.0, false)
	for i in range(10):
		await get_tree().process_frame
	
	print("--- BEGINNING SCREENSHOT CAPTURE AT 1280x720 ---")
	_setup_camera_3_4_profile()
	
	# 1. Before firing — aiming pose (t = 0.00)
	_eval_firing_pose(0.0, false)
	for i in range(4):
		await get_tree().process_frame
	await _capture("1_aiming_pose_before_fire.png")
	
	# 2. Trigger/firing pose with muzzle flash & shell ejection (t = 0.03)
	_eval_firing_pose(0.03, true)
	for i in range(4):
		await get_tree().process_frame
	await _capture("2_trigger_firing_pose.png")
	
	# 3. Maximum recoil pose (t = 0.07, peak pushback, muzzle climb, shoulder reaction)
	_eval_firing_pose(0.07, true)
	for i in range(4):
		await get_tree().process_frame
	await _capture("3_maximum_recoil_pose.png")
	
	# 4. Recovery pose (t = 0.16, dampening return, casing tumbling away, smoke fading)
	_eval_firing_pose(0.16, true)
	for i in range(4):
		await get_tree().process_frame
	await _capture("4_recovery_pose.png")
	
	# 5. Final returned aiming pose (t = 0.26, complete cycle reset)
	_eval_firing_pose(0.26, false)
	for i in range(4):
		await get_tree().process_frame
	await _capture("5_final_returned_aiming_pose.png")
	
	# 6. Rapid fire repeat verification (run 5 full shots, capture at end of 5th shot)
	for shot in range(5):
		for step in range(10):
			_eval_firing_pose(float(step) / 10.0 * 0.26, false)
			await get_tree().process_frame
	_eval_firing_pose(0.26, false)
	for i in range(4):
		await get_tree().process_frame
	await _capture("6_rapid_fire_repeat_verification.png")
	
	# 7. Side-profile close-up at peak recoil (t = 0.07) showing shoulder seating & cheek weld
	_setup_camera_side_profile()
	_eval_firing_pose(0.07, false)
	for i in range(4):
		await get_tree().process_frame
	await _capture("7_side_profile_recoil_comparison.png")
	
	print("--- STEP 2 CAPTURE COMPLETE ---")
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
	
	# Key Light (warm front-right)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-28.0, 42.0, 0.0)
	sun.light_color = Color(1.0, 0.98, 0.93)
	sun.light_energy = 1.15
	sun.shadow_enabled = false
	add_child(sun)
	
	# Fill Light (cool front-left)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-12.0, -65.0, 0.0)
	fill.light_color = Color(0.65, 0.75, 0.88)
	fill.light_energy = 0.65
	fill.shadow_enabled = false
	add_child(fill)
	
	# Back Rim Light (silhouette separation)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(25.0, -155.0, 0.0)
	rim.light_color = Color(0.88, 0.94, 1.0)
	rim.light_energy = 0.60
	rim.shadow_enabled = false
	add_child(rim)
	
	camera = Camera3D.new()
	camera.name = "AnimationCamera"
	camera.fov = 30.0
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
	
	# Load authentic German STG44
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
	
	# Center pistol grip at (0, 0, 0)
	var grip_offset := Vector3(-0.163382, 0.185335, 0.0)
	stg_body.position = -grip_offset
	rifle_root.add_child(stg_body)
	
	# Calibrated socket transform from Step 1
	var target_rifle_basis := Basis(
		Vector3(0, 0, 1), # Rifle X (barrel) -> World +Z
		Vector3(0, 1, 0), # Rifle Y (sights) -> World +Y
		Vector3(1, 0, 0)  # Rifle Z (lateral)-> World +X
	)
	var rh_aim_basis := Basis.from_euler(Vector3(deg_to_rad(-10.0), deg_to_rad(15.0), deg_to_rad(-8.0)))
	socket_basis = rh_aim_basis.inverse() * target_rifle_basis
	socket_pos = Vector3(-0.022, 0.030, -0.010)
	rifle_socket.transform = Transform3D(socket_basis, socket_pos)

func _create_flash_texture() -> ImageTexture:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var center := Vector2(32.0, 32.0)
	for y in range(64):
		for x in range(64):
			var pos := Vector2(float(x), float(y))
			var dist := pos.distance_to(center) / 32.0
			var dx := absf(pos.x - center.x) / 32.0
			var dy := absf(pos.y - center.y) / 32.0
			# Conical diamond starburst
			var star := maxf(1.0 - (dx * 1.8 + dy * 2.2), 0.0)
			var radial := maxf(1.0 - dist, 0.0)
			var intensity := clampf(radial * 0.5 + star * 0.9, 0.0, 1.0)
			if intensity > 0.01:
				var col: Color
				if intensity > 0.65:
					col = Color(1.0, 0.98, 0.92, intensity)
				elif intensity > 0.30:
					col = Color(1.0, 0.80, 0.30, intensity * 0.95)
				else:
					col = Color(1.0, 0.40, 0.10, intensity * 0.75)
				img.set_pixel(x, y, col)
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(img)

func _create_smoke_texture() -> ImageTexture:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var center := Vector2(16.0, 16.0)
	for y in range(32):
		for x in range(32):
			var dist := Vector2(float(x), float(y)).distance_to(center) / 16.0
			var a := clampf(1.0 - dist * dist, 0.0, 1.0)
			img.set_pixel(x, y, Color(0.75, 0.76, 0.80, a * 0.45))
	return ImageTexture.create_from_image(img)

func _setup_vfx_and_audio() -> void:
	# 1. Procedural Muzzle Flash Starburst
	var flash_tex := _create_flash_texture()
	var flash_mat := StandardMaterial3D.new()
	flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	flash_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash_mat.albedo_texture = flash_tex
	flash_mat.albedo_color = Color(1.0, 0.95, 0.7, 1.0)
	
	muzzle_flash_root = Node3D.new()
	muzzle_flash_root.name = "MuzzleFlashRoot"
	muzzle_flash_root.position = muzzle_root_pos
	muzzle_flash_root.visible = false
	rifle_root.add_child(muzzle_flash_root)
	
	# Multi-angle crossed quads for volumetric flame appearance from all angles
	var quad_mesh := QuadMesh.new()
	quad_mesh.size = Vector2(0.18, 0.12)
	
	# Quad 1: tilted 30 deg
	var q1 := MeshInstance3D.new()
	q1.mesh = quad_mesh
	q1.material_override = flash_mat
	q1.position = Vector3(0.06, 0.0, 0.0)
	q1.rotation_degrees = Vector3(30.0, 0.0, 0.0)
	muzzle_flash_root.add_child(q1)
	
	# Quad 2: tilted -45 deg
	var q2 := MeshInstance3D.new()
	q2.mesh = quad_mesh
	q2.material_override = flash_mat
	q2.position = Vector3(0.06, 0.0, 0.0)
	q2.rotation_degrees = Vector3(-45.0, 0.0, 0.0)
	muzzle_flash_root.add_child(q2)
	
	# Quad 3: horizontal
	var q3 := MeshInstance3D.new()
	q3.mesh = quad_mesh
	q3.material_override = flash_mat
	q3.position = Vector3(0.06, 0.0, 0.0)
	q3.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	muzzle_flash_root.add_child(q3)
	
	# 2. Muzzle Flash Light
	muzzle_light = OmniLight3D.new()
	muzzle_light.name = "MuzzleLight"
	muzzle_light.light_color = Color(1.0, 0.85, 0.45)
	muzzle_light.light_energy = 0.0
	muzzle_light.omni_range = 3.5
	muzzle_light.position = muzzle_root_pos + Vector3(0.08, 0.0, 0.0)
	rifle_root.add_child(muzzle_light)
	
	# 3. Soft Muzzle Smoke Particles (CPUParticles3D - zero GPU overhead, fully compatible)
	var smoke_tex := _create_smoke_texture()
	var smoke_mat := StandardMaterial3D.new()
	smoke_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smoke_mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	smoke_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smoke_mat.albedo_texture = smoke_tex
	
	var smoke_quad := QuadMesh.new()
	smoke_quad.size = Vector2(0.08, 0.08)
	smoke_quad.material = smoke_mat
	
	smoke_particles = CPUParticles3D.new()
	smoke_particles.name = "MuzzleSmoke"
	smoke_particles.emitting = false
	smoke_particles.one_shot = true
	smoke_particles.explosiveness = 0.90
	smoke_particles.lifetime = 0.40
	smoke_particles.amount = 8
	smoke_particles.position = muzzle_root_pos + Vector3(0.02, 0.0, 0.0)
	smoke_particles.direction = Vector3(1.0, 0.25, 0.0) # Forward along barrel
	smoke_particles.spread = 15.0
	smoke_particles.initial_velocity_min = 0.5
	smoke_particles.initial_velocity_max = 1.0
	smoke_particles.gravity = Vector3(0.0, 0.4, 0.0) # Upward thermal draft
	smoke_particles.mesh = smoke_quad
	rifle_root.add_child(smoke_particles)
	
	# 4. Ejected Brass Shell Casing (7.92x33mm Kurz)
	var casing_mesh := CylinderMesh.new()
	casing_mesh.top_radius = 0.0055
	casing_mesh.bottom_radius = 0.0058
	casing_mesh.height = 0.033
	
	var brass_mat := StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.92, 0.78, 0.28)
	brass_mat.metallic = 0.88
	brass_mat.roughness = 0.28
	
	shell_casing_mesh = MeshInstance3D.new()
	shell_casing_mesh.name = "EjectedCasing"
	shell_casing_mesh.mesh = casing_mesh
	shell_casing_mesh.material_override = brass_mat
	shell_casing_mesh.visible = false
	rifle_root.add_child(shell_casing_mesh)
	
	# 5. Temporary Prototype Audio Preview (isolated test node only)
	if ResourceLoader.exists(TEST_AUDIO_PATH):
		audio_player = AudioStreamPlayer3D.new()
		audio_player.name = "PrototypeFiringAudio"
		audio_player.stream = load(TEST_AUDIO_PATH) as AudioStream
		audio_player.volume_db = -18.0 # Soft preview
		audio_player.max_distance = 15.0
		rifle_root.add_child(audio_player)

func _setup_animation_player() -> void:
	anim_player = AnimationPlayer.new()
	anim_player.name = "GermanSoldierAnimationPlayer"
	add_child(anim_player)
	
	var lib := AnimationLibrary.new()
	var anim_fire := Animation.new()
	anim_fire.length = firing_duration
	anim_fire.loop_mode = Animation.LOOP_NONE
	
	# Track for firing time progress
	var track_idx := anim_fire.add_track(Animation.TYPE_METHOD)
	anim_fire.track_set_path(track_idx, ".")
	anim_fire.track_insert_key(track_idx, 0.0, {"method": "_eval_firing_pose", "args": [0.0, true]})
	anim_fire.track_insert_key(track_idx, 0.03, {"method": "_eval_firing_pose", "args": [0.03, true]})
	anim_fire.track_insert_key(track_idx, 0.07, {"method": "_eval_firing_pose", "args": [0.07, true]})
	anim_fire.track_insert_key(track_idx, 0.16, {"method": "_eval_firing_pose", "args": [0.16, true]})
	anim_fire.track_insert_key(track_idx, 0.26, {"method": "_eval_firing_pose", "args": [0.26, true]})
	
	lib.add_animation("fire", anim_fire)
	anim_player.add_animation_library("", lib)

# --- RECOIL & TRIGGER KINEMATICS ---

func _get_recoil_factor(t: float) -> float:
	# t in seconds [0.0, 0.26]
	if t < 0.02:
		return 0.0
	elif t < 0.07:
		# Sharp recoil kick from 0.0 to 1.0 (50ms impulse)
		var p := (t - 0.02) / 0.05
		return sin(p * PI * 0.5)
	elif t < 0.18:
		# Spring-damped return from 1.0 to -0.06 (slight forward overshoot, 110ms)
		var p := (t - 0.07) / 0.11
		return lerpf(1.0, -0.06, sin(p * PI * 0.5))
	elif t <= 0.26:
		# Final settling to 0.0 (80ms)
		var p := (t - 0.18) / 0.08
		return lerpf(-0.06, 0.0, p)
	return 0.0

func _get_trigger_factor(t: float) -> float:
	if t < 0.03:
		return t / 0.03 # Smooth trigger pull
	elif t < 0.08:
		return 1.0 # Held during firing impulse
	elif t < 0.20:
		return 1.0 - (t - 0.08) / 0.12 # Release forward
	return 0.0

func _eval_firing_pose(t: float, allow_vfx: bool = true) -> void:
	skeleton.clear_bones_global_pose_override()
	skeleton.reset_bone_poses()
	
	var r := _get_recoil_factor(t)
	var trg := _get_trigger_factor(t)
	
	# 1. Torso Reaction (Spine pitch backward and yaw twist absorption)
	var spine_rot := Basis.from_euler(Vector3(
		deg_to_rad(6.0 - 1.8 * r),
		deg_to_rad(8.0 + 1.2 * r),
		deg_to_rad(-2.0 - 0.5 * r)
	))
	var spine_pos := skeleton.get_bone_global_pose(idx_spine).origin
	skeleton.set_bone_global_pose_override(idx_spine, Transform3D(spine_rot, spine_pos), 1.0, true)
	
	# 2. Head Cheek-Weld Reaction (Shock absorption while maintaining firm sight alignment)
	var head_pos := skeleton.get_bone_global_pose(idx_head).origin
	var head_rot := Basis.from_euler(Vector3(
		deg_to_rad(10.0 + 0.8 * r),
		deg_to_rad(-12.0 - 0.5 * r),
		deg_to_rad(8.0)
	))
	skeleton.set_bone_global_pose_override(idx_head, Transform3D(head_rot, head_pos), 1.0, true)
	
	# 3. Right Arm / Weapon Recoil (Pushes straight back into shoulder pocket, muzzle rises +3.8 deg)
	var r_shoulder := skeleton.get_bone_global_pose(idx_r_arm).origin
	var r_hand_pos := Vector3(
		-0.06 - 0.003 * r,
		1.41 + 0.008 * r,
		0.30 - 0.024 * r # 2.4 cm rearward travel into shoulder pocket
	)
	var r_elbow := _solve_two_bone(r_shoulder, r_hand_pos, 0.248, 0.275, Vector3(-0.25, 1.25, 0.10))
	
	var r_arm_basis := _basis_look_at(r_shoulder, r_elbow, Vector3.FORWARD)
	var r_fore_basis := _basis_look_at(r_elbow, r_hand_pos, Vector3.FORWARD)
	# Right hand pitches up with muzzle climb and twists slightly into shoulder
	var r_hand_basis := Basis.from_euler(Vector3(
		deg_to_rad(-10.0 - 3.8 * r),
		deg_to_rad(15.0 + 1.0 * r),
		deg_to_rad(-8.0)
	))
	
	skeleton.set_bone_global_pose_override(idx_r_arm, Transform3D(r_arm_basis, r_shoulder), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_r_forearm, Transform3D(r_fore_basis, r_elbow), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_r_hand, Transform3D(r_hand_basis, r_hand_pos), 1.0, true)
	
	# 4. Dynamic Handguard Tracking for Left Arm Support:
	# Compute where the rifle handguard is in world space based on the recoiling weapon transform:
	var rifle_grip_world := r_hand_pos + r_hand_basis * socket_pos
	var rifle_barrel_dir := (r_hand_basis * socket_basis.x).normalized()
	var rifle_up_dir := (r_hand_basis * socket_basis.y).normalized()
	# Handguard cup point (0.21m forward along barrel, 0.035m below receiver)
	var handguard_world := rifle_grip_world + rifle_barrel_dir * 0.21 - rifle_up_dir * 0.035
	
	# Left Arm: Solves analytic IK to stay clamped to handguard throughout full recoil cycle
	var l_shoulder := skeleton.get_bone_global_pose(idx_l_arm).origin
	var l_hand_pos := handguard_world
	var l_elbow := _solve_two_bone(l_shoulder, l_hand_pos, 0.248, 0.275, Vector3(0.20, 1.25, 0.22))
	
	var l_arm_basis := _basis_look_at(l_shoulder, l_elbow, Vector3.FORWARD)
	var l_fore_basis := _basis_look_at(l_elbow, l_hand_pos, Vector3.FORWARD)
	# Left hand base cupping orientation pitched with recoil
	var l_hand_base := Basis(
		Vector3(-0.95, 0.0, 0.31).normalized(),
		Vector3(0.10, 0.35, 0.93).normalized(),
		Vector3(-0.29, 0.94, -0.33).normalized()
	).orthonormalized()
	var l_hand_basis := l_hand_base * Basis.from_euler(Vector3(deg_to_rad(-3.8 * r), 0.0, 0.0))
	
	skeleton.set_bone_global_pose_override(idx_l_arm, Transform3D(l_arm_basis, l_shoulder), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_l_forearm, Transform3D(l_fore_basis, l_elbow), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_l_hand, Transform3D(l_hand_basis, l_hand_pos), 1.0, true)
	
	# 5. Finger Articulation & Trigger Pull
	_curl_fingers_with_trigger(trg)
	
	# 6. VFX & Shell Casing Updates
	if allow_vfx:
		_update_vfx(t)
	else:
		muzzle_flash_root.visible = false
		muzzle_light.light_energy = 0.0
		shell_casing_mesh.visible = false
	
	skeleton.force_update_all_bone_transforms()

func _curl_fingers_with_trigger(trg: float) -> void:
	# Right Hand Thumb: tightly wrapped around grip backstrap
	for b in right_thumb_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.RIGHT, deg_to_rad(35.0))
		skeleton.set_bone_pose_rotation(b, curl_q)
	
	# Right Hand Index Finger: pulls back onto trigger shoe
	# Base curl is 24 deg, pulls an additional 18 deg back when trigger is squeezed
	var index_curl := 24.0 + 18.0 * trg
	for b in right_index_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(index_curl))
		skeleton.set_bone_pose_rotation(b, curl_q)
	
	# Right Hand Middle Finger: wraps firmly around grip front
	for b in right_middle_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(48.0))
		skeleton.set_bone_pose_rotation(b, curl_q)
	
	# Left Hand: cups handguard (thumb top, fingers under)
	for b in left_thumb_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.RIGHT, deg_to_rad(25.0))
		skeleton.set_bone_pose_rotation(b, curl_q)
	
	for b in left_index_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(48.0))
		skeleton.set_bone_pose_rotation(b, curl_q)
	for b in left_middle_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var curl_q := rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(52.0))
		skeleton.set_bone_pose_rotation(b, curl_q)

func _update_vfx(t: float) -> void:
	# Muzzle Flash: active strictly during ignition phase [0.02, 0.05]
	var flash_active := (t >= 0.02 and t <= 0.05)
	muzzle_flash_root.visible = flash_active
	if flash_active:
		var flash_phase := (t - 0.02) / 0.03
		var energy := sin(flash_phase * PI) * 3.5
		muzzle_light.light_energy = energy
	else:
		muzzle_light.light_energy = 0.0
	
	# Smoke: trigger emission at t = 0.03
	if t >= 0.03 and t <= 0.20:
		if not smoke_particles.emitting and t < 0.05:
			smoke_particles.restart()
	
	# Shell Casing: ejects from right side port at t = 0.03 and tumbles outward
	if t >= 0.03 and t <= 0.24:
		shell_casing_mesh.visible = true
		var dt := t - 0.03
		# Velocity: pops outward to the right (+Z) and slightly up (+Y) and back (-X)
		var casing_pos := ejection_port_pos + Vector3(-0.15 * dt, 0.65 * dt - 0.5 * 9.8 * dt * dt, 0.55 * dt)
		shell_casing_mesh.position = casing_pos
		shell_casing_mesh.rotation_degrees = Vector3(dt * 720.0, dt * 540.0, dt * 360.0)
	else:
		shell_casing_mesh.visible = false

# --- BASELINE CACHING & DRIFT TESTING ---

func _cache_baseline_aim_pose() -> void:
	baseline_spine = skeleton.get_bone_global_pose(idx_spine)
	baseline_head = skeleton.get_bone_global_pose(idx_head)
	baseline_r_arm = skeleton.get_bone_global_pose(idx_r_arm)
	baseline_r_forearm = skeleton.get_bone_global_pose(idx_r_forearm)
	baseline_r_hand = skeleton.get_bone_global_pose(idx_r_hand)
	baseline_l_arm = skeleton.get_bone_global_pose(idx_l_arm)
	baseline_l_forearm = skeleton.get_bone_global_pose(idx_l_forearm)
	baseline_l_hand = skeleton.get_bone_global_pose(idx_l_hand)

func _test_repeated_firing_drift(cycles: int) -> float:
	var max_err := 0.0
	for cycle in range(cycles):
		# Simulate full animation cycle from 0.0 to 0.26 across 20 steps
		for step in range(21):
			var sim_t := (float(step) / 20.0) * firing_duration
			_eval_firing_pose(sim_t, false)
		
		# Reset to end of cycle (t = 0.26)
		_eval_firing_pose(0.26, false)
		
		# Compute deviation from baseline aim
		var cur_spine := skeleton.get_bone_global_pose(idx_spine)
		var cur_r_hand := skeleton.get_bone_global_pose(idx_r_hand)
		var cur_l_hand := skeleton.get_bone_global_pose(idx_l_hand)
		var cur_head := skeleton.get_bone_global_pose(idx_head)
		
		var err_spine := cur_spine.origin.distance_to(baseline_spine.origin)
		var err_r := cur_r_hand.origin.distance_to(baseline_r_hand.origin)
		var err_l := cur_l_hand.origin.distance_to(baseline_l_hand.origin)
		var err_h := cur_head.origin.distance_to(baseline_head.origin)
		
		max_err = maxf(max_err, maxf(err_spine, maxf(err_r, maxf(err_l, err_h))))
	return max_err

# --- ANALYTIC TWO-BONE IK & LOOK-AT ---

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

func _setup_camera_3_4_profile() -> void:
	# 3/4 profile showing soldier upper body, cheek weld, both hands, rifle, muzzle, and ejection port
	camera.fov = 30.0
	var target := Vector3(-0.02, 1.40, 0.38)
	var cam_pos := Vector3(-1.60, 1.50, 1.38)
	camera.look_at_from_position(cam_pos, target, Vector3.UP)

func _setup_camera_side_profile() -> void:
	# Pure lateral right side profile showing shoulder pocket recoil depth and cheek weld
	camera.fov = 24.0
	var target := Vector3(0.0, 1.40, 0.25)
	var cam_pos := Vector3(1.65, 1.42, 0.25)
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
