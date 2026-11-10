extends Node3D

const SOLDIER_FBX := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"
const SOLDIER_TEX := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier_Texture.png"
const WEAPONS_PACK := "res://assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf"
const OUTPUT_DIR := "res://docs/asset_readiness_previews/phase3/recovery_step3"
const TEST_AUDIO_PATH := "res://assets/library/audio/weapons/soviet/mosin_reload.wav"

var skeleton: Skeleton3D
var bone_attachment: BoneAttachment3D
var rifle_socket: Node3D
var rifle_root: Node3D
var camera: Camera3D
var soldier_root: Node3D
var anim_player: AnimationPlayer

# Weapon components
var stg_body: Node3D
var receiver_mesh_instance: MeshInstance3D
var inserted_magazine: Node3D
var empty_magazine_prop: Node3D
var fresh_magazine_prop: Node3D
var charging_handle_prop: Node3D
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

# Baseline Aiming Pose bone transforms (for drift verification)
var baseline_spine: Transform3D
var baseline_head: Transform3D
var baseline_r_arm: Transform3D
var baseline_r_forearm: Transform3D
var baseline_r_hand: Transform3D
var baseline_l_arm: Transform3D
var baseline_l_forearm: Transform3D
var baseline_l_hand: Transform3D

# Reload animation duration: 2.40 seconds
var reload_duration := 2.40

func _ready() -> void:
	call_deferred("_run_test_and_capture_sequence")

func _run_test_and_capture_sequence() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	_setup_world()
	_setup_soldier()
	_setup_rifle()
	_cache_bones()
	_setup_audio()
	_setup_animation_player()
	
	for i in range(5):
		await get_tree().process_frame
	
	print("--- PHASE 3 RECOVERY STEP 3: VERIFYING BASELINE AIM POSE ---")
	_eval_reload_pose(0.0)
	_cache_baseline_aim_pose()
	
	print("--- RUNNING REPEATED RELOAD & DRIFT VERIFICATION (5 CYCLES) ---")
	var max_drift := _test_repeated_reload_drift(5)
	print("RESULT: Maximum cumulative drift across 5 reload cycles: %.6f mm" % (max_drift * 1000.0))
	assert(max_drift < 0.0001, "Drift exceeded tolerance!")
	
	print("--- BEGINNING SCREENSHOT CAPTURE AT 1280x720 ---")
	_setup_camera_reload_view()
	
	# 1. Initial aiming pose (t = 0.00)
	_eval_reload_pose(0.0)
	for i in range(4):
		await get_tree().process_frame
	await _capture("1_initial_aiming_pose.png")
	
	# 2. Reload start (t = 0.35, rifle tilted slightly, left hand moving to magazine)
	_eval_reload_pose(0.35)
	for i in range(4):
		await get_tree().process_frame
	await _capture("2_reload_start.png")
	
	# 3. Magazine removal (t = 0.70, left hand grasping and pulling empty magazine out)
	_eval_reload_pose(0.70)
	for i in range(4):
		await get_tree().process_frame
	await _capture("3_magazine_removal.png")
	
	# 4. Empty magazine separated from rifle (t = 1.05, magazine fully cleared, open mag well visible)
	_eval_reload_pose(1.05)
	for i in range(4):
		await get_tree().process_frame
	await _capture("4_empty_magazine_separated.png")
	
	# 5. Fresh magazine insertion (t = 1.55, fresh magazine entering and seating into mag well)
	_eval_reload_pose(1.55)
	for i in range(4):
		await get_tree().process_frame
	await _capture("5_fresh_magazine_insertion.png")
	
	# 6. Charging action (t = 1.95, left hand pulling the charging handle on left receiver side)
	_eval_reload_pose(1.95)
	for i in range(4):
		await get_tree().process_frame
	await _capture("6_charging_action.png")
	
	# 7. Final aiming pose (t = 2.40, fully reset to combat aim pose)
	_eval_reload_pose(2.40)
	for i in range(4):
		await get_tree().process_frame
	await _capture("7_final_aiming_pose.png")
	
	# 8. Repeated reload drift verification (run 3 full reload cycles and capture result)
	for cycle in range(3):
		for step in range(15):
			_eval_reload_pose(float(step) / 15.0 * reload_duration)
			await get_tree().process_frame
	_eval_reload_pose(2.40)
	for i in range(4):
		await get_tree().process_frame
	await _capture("8_repeated_reload_drift_verification.png")
	
	print("--- STEP 3 CAPTURE COMPLETE ---")
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
	sun.rotation_degrees = Vector3(-26.0, 38.0, 0.0)
	sun.light_color = Color(1.0, 0.98, 0.93)
	sun.light_energy = 1.15
	sun.shadow_enabled = false
	add_child(sun)
	
	# Fill Light (cool front-left)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-12.0, -65.0, 0.0)
	fill.light_color = Color(0.65, 0.75, 0.88)
	fill.light_energy = 0.70
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
	camera.name = "ReloadCamera"
	camera.fov = 32.0
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
	
	rifle_root = Node3D.new()
	rifle_root.name = "STG44_Model"
	rifle_socket.add_child(rifle_root)
	
	# Load authentic German STG44 from weapons pack
	var pack_res := load(WEAPONS_PACK) as PackedScene
	var pack_inst := pack_res.instantiate()
	
	stg_body = null
	for child in pack_inst.find_children("*", "Node3D", true, false):
		if child.name == "STG 44_28":
			stg_body = child.duplicate(7) as Node3D
			break
	pack_inst.free()
	
	var grip_offset := Vector3(-0.163382, 0.185335, 0.0)
	stg_body.position = -grip_offset
	rifle_root.add_child(stg_body)
	
	# Calibrated socket transform from Step 1 & 2
	var target_rifle_basis := Basis(
		Vector3(0, 0, 1), # Rifle X (barrel) -> World +Z
		Vector3(0, 1, 0), # Rifle Y (sights) -> World +Y
		Vector3(1, 0, 0)  # Rifle Z (lateral)-> World +X
	)
	var rh_aim_basis := Basis.from_euler(Vector3(deg_to_rad(-10.0), deg_to_rad(15.0), deg_to_rad(-8.0)))
	socket_basis = rh_aim_basis.inverse() * target_rifle_basis
	socket_pos = Vector3(-0.022, 0.030, -0.010)
	rifle_socket.transform = Transform3D(socket_basis, socket_pos)
	
	# Separate Object_71 into receiver (with open magazine well) and detachable magazine
	var orig_o71: MeshInstance3D = null
	for child in stg_body.find_children("*", "MeshInstance3D", true, false):
		if child.name == "Object_71":
			orig_o71 = child
			break
	
	if orig_o71 != null:
		var orig_mat := orig_o71.get_active_material(0)
		var am := orig_o71.mesh as ArrayMesh
		var arrays := am.surface_get_arrays(0)
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var norms: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		
		var st_recv := SurfaceTool.new()
		st_recv.begin(Mesh.PRIMITIVE_TRIANGLES)
		if orig_mat != null: st_recv.set_material(orig_mat)
		
		var st_mag := SurfaceTool.new()
		st_mag.begin(Mesh.PRIMITIVE_TRIANGLES)
		if orig_mat != null: st_mag.set_material(orig_mat)
		
		for i in range(0, indices.size(), 3):
			var i0 := indices[i + 0]
			var i1 := indices[i + 1]
			var i2 := indices[i + 2]
			var v0 := verts[i0]
			var v1 := verts[i1]
			var v2 := verts[i2]
			var mid_y := (v0.y + v1.y + v2.y) / 3.0
			var mid_x := (v0.x + v1.x + v2.x) / 3.0
			
			if mid_y < 5.1 and mid_x >= -0.5 and mid_x <= 2.2:
				for idx in [i0, i1, i2]:
					if uvs.size() > idx: st_mag.set_uv(uvs[idx])
					if norms.size() > idx: st_mag.set_normal(norms[idx])
					st_mag.add_vertex(verts[idx])
			else:
				for idx in [i0, i1, i2]:
					if uvs.size() > idx: st_recv.set_uv(uvs[idx])
					if norms.size() > idx: st_recv.set_normal(norms[idx])
					st_recv.add_vertex(verts[idx])
		
		var mesh_recv := st_recv.commit()
		var mesh_mag := st_mag.commit()
		
		if orig_mat != null:
			mesh_recv.surface_set_material(0, orig_mat)
			mesh_mag.surface_set_material(0, orig_mat)
		
		# Replace Object_71 mesh with receiver mesh (now has open magazine well)
		orig_o71.mesh = mesh_recv
		orig_o71.material_override = orig_mat
		
		# Create primary inserted magazine
		inserted_magazine = Node3D.new()
		inserted_magazine.name = "InsertedMagazine"
		var mi_mag := MeshInstance3D.new()
		mi_mag.mesh = mesh_mag
		mi_mag.material_override = orig_mat
		inserted_magazine.add_child(mi_mag)
		stg_body.add_child(inserted_magazine)
		
		# Create empty magazine prop (detached, moves during removal)
		empty_magazine_prop = Node3D.new()
		empty_magazine_prop.name = "EmptyMagazineProp"
		var mi_empty := MeshInstance3D.new()
		mi_empty.mesh = mesh_mag
		mi_empty.material_override = orig_mat
		empty_magazine_prop.add_child(mi_empty)
		empty_magazine_prop.visible = false
		stg_body.add_child(empty_magazine_prop)
		
		# Create fresh magazine prop (moves during insertion)
		fresh_magazine_prop = Node3D.new()
		fresh_magazine_prop.name = "FreshMagazineProp"
		var mi_fresh := MeshInstance3D.new()
		mi_fresh.mesh = mesh_mag
		mi_fresh.material_override = orig_mat
		fresh_magazine_prop.add_child(mi_fresh)
		fresh_magazine_prop.visible = false
		stg_body.add_child(fresh_magazine_prop)
	
	# Visual Charging Handle Prop on left side of receiver
	charging_handle_prop = Node3D.new()
	charging_handle_prop.name = "ChargingHandle"
	var ch_mesh := CylinderMesh.new()
	ch_mesh.top_radius = 0.0055
	ch_mesh.bottom_radius = 0.0065
	ch_mesh.height = 0.022
	var ch_mat := StandardMaterial3D.new()
	ch_mat.albedo_color = Color(0.18, 0.18, 0.20)
	ch_mat.metallic = 0.85
	ch_mat.roughness = 0.40
	var ch_mi := MeshInstance3D.new()
	ch_mi.mesh = ch_mesh
	ch_mi.material_override = ch_mat
	ch_mi.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	charging_handle_prop.add_child(ch_mi)
	
	# Position charging handle on left side of receiver in rifle_root space
	charging_handle_prop.position = Vector3(0.05, 0.12, -0.026)
	rifle_root.add_child(charging_handle_prop)

func _setup_audio() -> void:
	if ResourceLoader.exists(TEST_AUDIO_PATH):
		audio_player = AudioStreamPlayer3D.new()
		audio_player.name = "PrototypeReloadAudio"
		audio_player.stream = load(TEST_AUDIO_PATH) as AudioStream
		audio_player.volume_db = -16.0
		audio_player.max_distance = 15.0
		rifle_root.add_child(audio_player)

func _setup_animation_player() -> void:
	anim_player = AnimationPlayer.new()
	anim_player.name = "GermanSoldierReloadAnimationPlayer"
	add_child(anim_player)
	
	var lib := AnimationLibrary.new()
	var anim_reload := Animation.new()
	anim_reload.length = reload_duration
	anim_reload.loop_mode = Animation.LOOP_NONE
	
	var track_idx := anim_reload.add_track(Animation.TYPE_METHOD)
	anim_reload.track_set_path(track_idx, ".")
	anim_reload.track_insert_key(track_idx, 0.0, {"method": "_eval_reload_pose", "args": [0.0]})
	anim_reload.track_insert_key(track_idx, 0.35, {"method": "_eval_reload_pose", "args": [0.35]})
	anim_reload.track_insert_key(track_idx, 0.70, {"method": "_eval_reload_pose", "args": [0.70]})
	anim_reload.track_insert_key(track_idx, 1.05, {"method": "_eval_reload_pose", "args": [1.05]})
	anim_reload.track_insert_key(track_idx, 1.55, {"method": "_eval_reload_pose", "args": [1.55]})
	anim_reload.track_insert_key(track_idx, 1.95, {"method": "_eval_reload_pose", "args": [1.95]})
	anim_reload.track_insert_key(track_idx, 2.40, {"method": "_eval_reload_pose", "args": [2.40]})
	
	lib.add_animation("reload", anim_reload)
	anim_player.add_animation_library("", lib)

# --- RELOAD KINEMATICS & HAND TRAJECTORIES ---

func _eval_reload_pose(t: float) -> void:
	skeleton.clear_bones_global_pose_override()
	skeleton.reset_bone_poses()
	
	# Blend factor for lowered reloading rifle posture (0.0 at aim, 1.0 during active reload)
	var reload_blend := 0.0
	if t < 0.20:
		reload_blend = 0.0
	elif t < 0.50:
		reload_blend = (t - 0.20) / 0.30
	elif t < 2.05:
		reload_blend = 1.0
	elif t <= 2.40:
		reload_blend = 1.0 - (t - 2.05) / 0.35
	
	reload_blend = clampf(reload_blend, 0.0, 1.0)
	var smooth_blend := sin(reload_blend * PI * 0.5)
	
	# 1. Torso Reaction:
	# Upper body tilts slightly forward and right shoulder lowers slightly to look down at receiver
	var spine_rot := Basis.from_euler(Vector3(
		deg_to_rad(6.0 + 3.0 * smooth_blend),
		deg_to_rad(8.0 - 4.0 * smooth_blend),
		deg_to_rad(-2.0 - 2.0 * smooth_blend)
	))
	var spine_pos := skeleton.get_bone_global_pose(idx_spine).origin
	skeleton.set_bone_global_pose_override(idx_spine, Transform3D(spine_rot, spine_pos), 1.0, true)
	
	# 2. Head Reaction:
	# Head tilts downward to look directly at the magazine well during reload
	var head_pos := skeleton.get_bone_global_pose(idx_head).origin
	var head_rot := Basis.from_euler(Vector3(
		deg_to_rad(10.0 + 8.0 * smooth_blend),
		deg_to_rad(-12.0 + 8.0 * smooth_blend),
		deg_to_rad(8.0 - 4.0 * smooth_blend)
	))
	skeleton.set_bone_global_pose_override(idx_head, Transform3D(head_rot, head_pos), 1.0, true)
	
	# 3. Right Arm / Weapon Stance:
	# Right hand lowers rifle slightly closer to chest and tilts left (+12 deg roll) for easy magazine access
	var r_shoulder := skeleton.get_bone_global_pose(idx_r_arm).origin
	var r_hand_pos := Vector3(
		-0.06 - 0.02 * smooth_blend,
		1.41 - 0.06 * smooth_blend,
		0.30 - 0.04 * smooth_blend
	)
	var r_elbow := _solve_two_bone(r_shoulder, r_hand_pos, 0.248, 0.275, Vector3(-0.25, 1.25, 0.10))
	var r_arm_basis := _basis_look_at(r_shoulder, r_elbow, Vector3.FORWARD)
	var r_fore_basis := _basis_look_at(r_elbow, r_hand_pos, Vector3.FORWARD)
	var r_hand_basis := Basis.from_euler(Vector3(
		deg_to_rad(-10.0 - 5.0 * smooth_blend),
		deg_to_rad(15.0 - 6.0 * smooth_blend),
		deg_to_rad(-8.0 + 12.0 * smooth_blend)
	))
	
	skeleton.set_bone_global_pose_override(idx_r_arm, Transform3D(r_arm_basis, r_shoulder), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_r_forearm, Transform3D(r_fore_basis, r_elbow), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_r_hand, Transform3D(r_hand_basis, r_hand_pos), 1.0, true)
	
	# Compute dynamic weapon coordinate frames in world space
	var rifle_grip_world := r_hand_pos + r_hand_basis * socket_pos
	var rifle_barrel_dir := (r_hand_basis * socket_basis.x).normalized()
	var rifle_up_dir := (r_hand_basis * socket_basis.y).normalized()
	var rifle_right_dir := (r_hand_basis * socket_basis.z).normalized()
	
	# Handguard cup position
	var handguard_world := rifle_grip_world + rifle_barrel_dir * 0.21 - rifle_up_dir * 0.035
	
	# Magazine grip hold position (in world space, gripping the lower half of magazine)
	var mag_hold_world := rifle_grip_world + rifle_barrel_dir * 0.14 - rifle_up_dir * 0.10 - rifle_right_dir * 0.015
	
	# Charging handle position (in world space on left side of receiver)
	var charging_handle_world := rifle_grip_world + rifle_barrel_dir * 0.05 + rifle_up_dir * 0.12 - rifle_right_dir * 0.026
	
	# 4. Left Arm Trajectory & Magazine State across Reload Timeline
	var l_hand_target := handguard_world
	var l_hand_rot_basis := _get_handguard_basis()
	var hand_state := 0 # 0=handguard, 1=grab_empty, 2=pull_empty, 3=reach_pouch, 4=insert_fresh, 5=charge
	
	# Reset magazine props
	if inserted_magazine != null: inserted_magazine.visible = true
	if empty_magazine_prop != null: empty_magazine_prop.visible = false
	if fresh_magazine_prop != null: fresh_magazine_prop.visible = false
	if charging_handle_prop != null: charging_handle_prop.position = Vector3(0.05, 0.12, -0.026)
	
	if t < 0.20:
		# Initial Aiming Pose
		l_hand_target = handguard_world
		l_hand_rot_basis = _get_handguard_basis()
		hand_state = 0
		
	elif t < 0.50:
		# Reload Start: Left hand moves from handguard down to magazine body
		var p := (t - 0.20) / 0.30
		l_hand_target = handguard_world.lerp(mag_hold_world, sin(p * PI * 0.5))
		l_hand_rot_basis = _get_handguard_basis().slerp(_get_mag_grip_basis(), p)
		hand_state = 1
		
	elif t < 0.85:
		# Magazine Removal: Left hand pulls empty magazine out of well
		var p := (t - 0.50) / 0.35
		# Magazine extraction in stg_body local space (scale factor 0.04787)
		# 12 cm pull is ~2.5 units along -Y and +0.5 units along +X
		var slide_y := -2.6 * p
		var slide_x := 0.5 * p
		
		# Hand follows the moving magazine in world space
		l_hand_target = mag_hold_world + (-rifle_up_dir * 0.12 + rifle_barrel_dir * 0.025) * p
		l_hand_rot_basis = _get_mag_grip_basis()
		hand_state = 2
		
		if inserted_magazine != null: inserted_magazine.visible = false
		if empty_magazine_prop != null:
			empty_magazine_prop.visible = true
			empty_magazine_prop.position = Vector3(slide_x, slide_y, 0.0)
		
	elif t < 1.25:
		# Empty Magazine Cleared & Stowed: Left hand moves empty mag down to waist pouch
		var p := (t - 0.85) / 0.40
		var pouch_world := Vector3(-0.10, 1.05, 0.22)
		var clear_world := mag_hold_world + (-rifle_up_dir * 0.12 + rifle_barrel_dir * 0.025)
		l_hand_target = clear_world.lerp(pouch_world, p)
		l_hand_rot_basis = _get_mag_grip_basis().slerp(_get_pouch_basis(), p)
		hand_state = 3
		
		# Empty magazine completely cleared from receiver! Mag well is open!
		if inserted_magazine != null: inserted_magazine.visible = false
		if empty_magazine_prop != null:
			if p < 0.75:
				empty_magazine_prop.visible = true
				# In stg_body space, move down to -6.5 units (31 cm clear of receiver)
				empty_magazine_prop.position = Vector3(0.5 + p * 0.6, -2.6 - p * 4.0, 0.0)
			else:
				empty_magazine_prop.visible = false # stowed into pouch
		
	elif t < 1.70:
		# Fresh Magazine Insertion: Left hand brings fresh mag up from pouch into well
		var p := (t - 1.25) / 0.45
		var pouch_world := Vector3(-0.10, 1.05, 0.22)
		var enter_world := mag_hold_world - rifle_up_dir * 0.05
		
		if p < 0.45:
			# Moving fresh magazine from pouch to entrance
			var sub_p := p / 0.45
			l_hand_target = pouch_world.lerp(enter_world, sin(sub_p * PI * 0.5))
			l_hand_rot_basis = _get_pouch_basis().slerp(_get_mag_grip_basis(), sub_p)
			if fresh_magazine_prop != null:
				fresh_magazine_prop.visible = true
				var dist_y := lerpf(-5.5, -2.0, sub_p)
				var dist_x := lerpf(1.0, 0.4, sub_p)
				fresh_magazine_prop.position = Vector3(dist_x, dist_y, 0.0)
			if inserted_magazine != null: inserted_magazine.visible = false
		else:
			# Sliding into well and clicking home
			var sub_p := (p - 0.45) / 0.55
			l_hand_target = enter_world.lerp(mag_hold_world, sub_p)
			l_hand_rot_basis = _get_mag_grip_basis()
			var dist_y := lerpf(-2.0, 0.0, sub_p)
			var dist_x := lerpf(0.4, 0.0, sub_p)
			if dist_y < -0.05:
				if fresh_magazine_prop != null:
					fresh_magazine_prop.visible = true
					fresh_magazine_prop.position = Vector3(dist_x, dist_y, 0.0)
				if inserted_magazine != null: inserted_magazine.visible = false
			else:
				# Clicked home!
				if fresh_magazine_prop != null: fresh_magazine_prop.visible = false
				if inserted_magazine != null:
					inserted_magazine.visible = true
					inserted_magazine.position = Vector3.ZERO
		hand_state = 4
		
	elif t < 2.05:
		# Charging Action: Left hand reaches up to charging handle, pulls back, and releases
		var p := (t - 1.70) / 0.35
		var charge_start := charging_handle_world
		var charge_back := charging_handle_world - rifle_barrel_dir * 0.042 # 4.2 cm pull rearward
		
		if p < 0.25:
			# Reaching up to charging handle
			var sub_p := p / 0.25
			l_hand_target = mag_hold_world.lerp(charge_start, sub_p)
			l_hand_rot_basis = _get_mag_grip_basis().slerp(_get_charging_basis(), sub_p)
		elif p < 0.70:
			# Pulling charging handle rearward
			var sub_p := (p - 0.25) / 0.45
			var pull := sin(sub_p * PI * 0.5)
			l_hand_target = charge_start.lerp(charge_back, pull)
			l_hand_rot_basis = _get_charging_basis()
			if charging_handle_prop != null:
				charging_handle_prop.position = Vector3(0.05 - 0.042 * pull, 0.12, -0.026)
		else:
			# Handle snaps forward into battery, hand releases
			var sub_p := (p - 0.70) / 0.30
			l_hand_target = charge_back.lerp(charge_start, sub_p)
			l_hand_rot_basis = _get_charging_basis()
			if charging_handle_prop != null:
				charging_handle_prop.position = Vector3(0.05, 0.12, -0.026)
		hand_state = 5
		
	else:
		# Return to Handguard & Final Aim
		var p := (t - 2.05) / 0.35
		l_hand_target = charging_handle_world.lerp(handguard_world, sin(p * PI * 0.5))
		l_hand_rot_basis = _get_charging_basis().slerp(_get_handguard_basis(), p)
		hand_state = 0
	
	# Solve Left Arm two-bone IK to reach target
	var l_shoulder := skeleton.get_bone_global_pose(idx_l_arm).origin
	var l_elbow := _solve_two_bone(l_shoulder, l_hand_target, 0.248, 0.275, Vector3(0.18, 1.20, 0.24))
	var l_arm_basis := _basis_look_at(l_shoulder, l_elbow, Vector3.FORWARD)
	var l_fore_basis := _basis_look_at(l_elbow, l_hand_target, Vector3.FORWARD)
	
	skeleton.set_bone_global_pose_override(idx_l_arm, Transform3D(l_arm_basis, l_shoulder), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_l_forearm, Transform3D(l_fore_basis, l_elbow), 1.0, true)
	skeleton.set_bone_global_pose_override(idx_l_hand, Transform3D(l_hand_rot_basis, l_hand_target), 1.0, true)
	
	# 5. Articulate fingers based on state
	_curl_fingers_reload(hand_state)
	
	skeleton.force_update_all_bone_transforms()

# --- FINGER POSING PER RELOAD STATE ---

func _curl_fingers_reload(state: int) -> void:
	# Right hand: always maintains firm grip on pistol grip
	for b in right_thumb_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.RIGHT, deg_to_rad(35.0)))
	for b in right_index_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(24.0)))
	for b in right_middle_bones:
		var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(48.0)))
	
	# Left hand fingers:
	if state == 0:
		# Standard handguard cup
		for b in left_thumb_bones:
			var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
			skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.RIGHT, deg_to_rad(25.0)))
		for b in left_index_bones:
			var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
			skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(48.0)))
		for b in left_middle_bones:
			var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
			skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(52.0)))
	elif state in [1, 2, 3, 4]:
		# Firm wrap around curved magazine body
		for b in left_thumb_bones:
			var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
			skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.RIGHT, deg_to_rad(38.0)))
		for b in left_index_bones:
			var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
			skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(55.0)))
		for b in left_middle_bones:
			var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
			skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(60.0)))
	elif state == 5:
		# Hook grip on charging handle knob
		for b in left_thumb_bones:
			var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
			skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.RIGHT, deg_to_rad(20.0)))
		for b in left_index_bones:
			var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
			skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(65.0)))
		for b in left_middle_bones:
			var rest_q := skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
			skeleton.set_bone_pose_rotation(b, rest_q * Quaternion(Vector3.FORWARD, deg_to_rad(68.0)))

func _get_handguard_basis() -> Basis:
	return Basis(
		Vector3(-0.95, 0.0, 0.31).normalized(),
		Vector3(0.10, 0.35, 0.93).normalized(),
		Vector3(-0.29, 0.94, -0.33).normalized()
	).orthonormalized()

func _get_mag_grip_basis() -> Basis:
	# Left hand grasping magazine from left/front (palm inward toward magazine)
	return Basis(
		Vector3(-0.35, -0.92, 0.18).normalized(),
		Vector3(0.88, -0.38, -0.26).normalized(),
		Vector3(0.31, 0.06, 0.95).normalized()
	).orthonormalized()

func _get_pouch_basis() -> Basis:
	# Hand down near waist dump pouch
	return Basis(
		Vector3(0.10, -0.98, 0.15).normalized(),
		Vector3(0.95, 0.12, 0.28).normalized(),
		Vector3(-0.28, 0.14, 0.95).normalized()
	).orthonormalized()

func _get_charging_basis() -> Basis:
	# Left hand gripping charging handle on left side of receiver
	return Basis(
		Vector3(-0.85, -0.20, -0.48).normalized(),
		Vector3(-0.15, 0.97, -0.15).normalized(),
		Vector3(0.50, -0.06, -0.86).normalized()
	).orthonormalized()

# --- DRIFT VERIFICATION ---

func _cache_baseline_aim_pose() -> void:
	baseline_spine = skeleton.get_bone_global_pose(idx_spine)
	baseline_head = skeleton.get_bone_global_pose(idx_head)
	baseline_r_arm = skeleton.get_bone_global_pose(idx_r_arm)
	baseline_r_forearm = skeleton.get_bone_global_pose(idx_r_forearm)
	baseline_r_hand = skeleton.get_bone_global_pose(idx_r_hand)
	baseline_l_arm = skeleton.get_bone_global_pose(idx_l_arm)
	baseline_l_forearm = skeleton.get_bone_global_pose(idx_l_forearm)
	baseline_l_hand = skeleton.get_bone_global_pose(idx_l_hand)

func _test_repeated_reload_drift(cycles: int) -> float:
	var max_err := 0.0
	for cycle in range(cycles):
		for step in range(31):
			var sim_t := (float(step) / 30.0) * reload_duration
			_eval_reload_pose(sim_t)
		
		# Reset to end of cycle (t = 2.40)
		_eval_reload_pose(2.40)
		
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

# --- CAMERA FRAMING ---

func _setup_camera_reload_view() -> void:
	# 3/4 front-left profile showing left hand, receiver, magazine well, and charging handle
	camera.fov = 32.0
	var target := Vector3(-0.02, 1.35, 0.30)
	var cam_pos := Vector3(-1.45, 1.48, 1.25)
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
