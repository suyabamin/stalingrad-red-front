extends Node
## Isolated, non-destructive asset readiness previews. Never attached to gameplay scenes.

const OUTPUT_DIR := "res://docs/asset_readiness_previews/phase2"
const MOSIN_DIR := "res://assets/library/incoming_downloads/mosin_nagant"
const ARM_DIR := "res://assets/library/incoming_downloads/first_person_arms/fps arms"

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	_setup_world()
	var out := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(out)
	var maps: Array[Image] = []
	for i in 3:
		var path := "%s/mosin_nagant_lowpoly_%d.png" % [MOSIN_DIR, i]
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		maps.append(image)
		for size in [2048, 1024]:
			var candidate := image.duplicate()
			candidate.resize(size, size, Image.INTERPOLATE_LANCZOS)
			var candidate_dir := ProjectSettings.globalize_path("res://assets/library/readiness_candidates/mosin_nagant/%dk" % (size / 1024))
			DirAccess.make_dir_recursive_absolute(candidate_dir)
			var derived_path := "%s/mosin_nagant_lowpoly_%d.png" % [candidate_dir, i]
			var err: Error = candidate.save_png(derived_path)
			var bytes := FileAccess.get_file_as_bytes(derived_path).size() if err == OK else -1
			print("TEXTURE_DERIVATIVE map=%d size=%d error=%d bytes=%d original_bytes=%d" % [i, size, err, bytes, FileAccess.get_file_as_bytes(ProjectSettings.globalize_path(path)).size()])

	await _preview_asset("res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx", "german_soldier_front.png", Vector3(0.0, 0.12, 1.0), 1.05, "soldier")
	await _preview_asset("res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx", "german_soldier_side.png", Vector3(1.0, 0.10, 0.0), 1.5, "soldier_side")
	await _preview_soldier_pose()
	await _preview_arms("res://assets/library/incoming_downloads/first_person_arms/fps arms/FPS ARMS RIG 1.fbx", "first_person_arms_base_camera.png", 1.0, null)
	await _preview_arm_animation()
	await _preview_asset("res://assets/library/incoming_downloads/mosin_nagant/mosin_nagant_lowpoly.glb", "mosin_original_4k.png", Vector3(1.0, 0.22, 0.1), 0.75, "mosin")
	for size in [2048, 1024]:
		await _preview_asset("res://assets/library/incoming_downloads/mosin_nagant/mosin_nagant_lowpoly.glb", "mosin_%d_preview.png" % size, Vector3(1.0, 0.22, 0.1), 0.75, "mosin_%d" % size, maps, size)
	print("ASSET_READINESS_PREVIEW_COMPLETE")
	get_tree().quit()

func _setup_world() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.16, 0.18, 0.21)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.8, 0.8, 0.8)
	env.ambient_light_energy = 0.55
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, -25, 0)
	light.light_energy = 0.8
	add_child(light)
	var camera := Camera3D.new()
	camera.name = "PreviewCamera"
	add_child(camera)
	camera.current = true

func _preview_asset(path: String, filename: String, direction: Vector3, distance_factor: float, kind: String, source_maps: Array[Image] = [], target_size: int = 0) -> void:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Could not load isolated asset %s" % path)
		return
	var root := packed.instantiate() as Node3D
	add_child(root)
	await get_tree().process_frame
	if kind.begins_with("mosin"):
		_print_node_transforms(root)
		if target_size > 0:
			_apply_mosin_maps(root, source_maps, target_size)
	if kind.begins_with("soldier"):
		_apply_albedo(root, "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier_Texture.png")
		_print_skeleton(root)
	var bounds := _combined_aabb(root)
	var center := bounds.position + bounds.size * 0.5
	root.global_position -= center
	var frame := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	var camera := get_node("PreviewCamera") as Camera3D
	var distance := maxf(frame * distance_factor, 1.0)
	var target := Vector3(0.0, bounds.size.y * 0.45, 0.0) if kind.begins_with("soldier") else Vector3.ZERO
	camera.look_at_from_position(target + direction.normalized() * distance, target, Vector3.UP)
	await _capture(filename)
	print("PREVIEW name=%s dimensions=%dx%d bounds=%s camera_distance=%.4f" % [filename, get_viewport().size.x, get_viewport().size.y, bounds.size, distance])
	root.queue_free()
	await get_tree().process_frame

func _preview_soldier_pose() -> void:
	var packed := load("res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx") as PackedScene
	var root := packed.instantiate() as Node3D
	add_child(root)
	await get_tree().process_frame
	_apply_albedo(root, "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier_Texture.png")
	var skeletons := root.find_children("*", "Skeleton3D", true, false)
	if skeletons.is_empty():
		print("SOLDIER_POSE_PREVIEW=NOT_AVAILABLE")
		root.queue_free()
		return
	var skeleton := skeletons[0] as Skeleton3D
	var bone := skeleton.find_bone("LeftArm")
	if bone >= 0:
		skeleton.set_bone_pose_rotation(bone, skeleton.get_bone_pose_rotation(bone) * Quaternion(Vector3.FORWARD, deg_to_rad(35)))
		skeleton.force_update_all_bone_transforms()
		print("SOLDIER_POSE_DIAGNOSTIC bone=LeftArm delta_degrees=35 (temporary test pose only)")
	var bounds := _combined_aabb(root)
	root.global_position -= bounds.position + bounds.size * 0.5
	var camera := get_node("PreviewCamera") as Camera3D
	var target := Vector3(0.0, bounds.size.y * 0.45, 0.0)
	camera.look_at_from_position(target + Vector3(0.0, bounds.size.y * 0.12, maxf(bounds.size.y, 2.0) * 1.0), target, Vector3.UP)
	await _capture("german_soldier_pose_diagnostic.png")
	root.queue_free()
	await get_tree().process_frame

func _preview_arms(path: String, filename: String, root_scale: float, animation_time: Variant) -> void:
	var packed := load(path) as PackedScene
	var root := packed.instantiate() as Node3D
	root.scale = Vector3.ONE * root_scale
	add_child(root)
	await get_tree().process_frame
	_apply_albedo(root, "%s/new_diff.png" % ARM_DIR)
	if animation_time != null:
		var players := root.find_children("*", "AnimationPlayer", true, false)
		if not players.is_empty():
			var ap := players[0] as AnimationPlayer
			var anim_names := ap.get_animation_list()
			if not anim_names.is_empty():
				ap.play(anim_names[0])
				ap.seek(float(animation_time), true)
				await get_tree().process_frame
	var bounds := _combined_aabb(root)
	root.position -= bounds.position + bounds.size * 0.5
	var camera := get_node("PreviewCamera") as Camera3D
	var size := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	camera.fov = 70
	camera.look_at_from_position(Vector3(0.0, size * 0.10, maxf(size * 1.5, 0.9)), Vector3.ZERO, Vector3.UP)
	if filename == "first_person_arms_base_camera.png":
		camera.fov = 70
	await _capture(filename)
	_print_node_transforms(root)
	_print_skeleton(root)
	root.queue_free()
	await get_tree().process_frame

func _preview_arm_animation() -> void:
	var path := "%s/FPS ARMS RIG 1 test.fbx" % ARM_DIR
	var packed := load(path) as PackedScene
	var root := packed.instantiate() as Node3D
	# Temporary isolated scale normalization after comparing the FBX child-root transforms.
	root.scale = Vector3.ONE * 0.1
	add_child(root)
	await get_tree().process_frame
	_apply_albedo(root, "%s/new_diff.png" % ARM_DIR)
	_print_node_transforms(root)
	_print_skeleton(root)
	var players := root.find_children("*", "AnimationPlayer", true, false)
	if players.is_empty():
		print("ARMS_ANIMATION=NOT_AVAILABLE")
		root.queue_free()
		return
	var ap := players[0] as AnimationPlayer
	for name in ap.get_animation_list():
		var anim := ap.get_animation(name)
		print("ARMS_ANIMATION name=%s length=%.6f loop=%d tracks=%d" % [name, anim.length, anim.loop_mode, anim.get_track_count()])
		var first_pose := ""
		for t in [0.0, anim.length * 0.25, anim.length * 0.5, anim.length * 0.75, maxf(0.0, anim.length - 0.01)]:
			ap.play(name)
			ap.seek(t, true)
			await get_tree().process_frame
			var pose := _skeleton_signature(root)
			if first_pose.is_empty():
				first_pose = pose
			var bounds := _combined_aabb(root)
			var camera := get_node("PreviewCamera") as Camera3D
			var frame := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
			camera.fov = 70
			camera.look_at_from_position(Vector3(0.0, frame * 0.10, maxf(frame * 1.5, 0.9)), Vector3.ZERO, Vector3.UP)
			await _capture("arms_action_%04dms.png" % roundi(t * 1000.0))
			print("ARMS_POSE_TIME seconds=%.3f bounds=%s pose_differs_from_start=%s" % [t, bounds.size, pose != first_pose])
	ap.stop()
	root.queue_free()
	await get_tree().process_frame

func _apply_mosin_maps(root: Node3D, maps: Array[Image], size: int) -> void:
	var loaded: Array[Texture2D] = []
	for image in maps:
		var resized := image.duplicate()
		resized.resize(size, size, Image.INTERPOLATE_LANCZOS)
		loaded.append(ImageTexture.create_from_image(resized))
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		for surface in mesh_instance.mesh.get_surface_count():
			var original := mesh_instance.get_active_material(surface)
			if original == null or original is StandardMaterial3D:
				var mat := (original.duplicate() as StandardMaterial3D) if original != null else StandardMaterial3D.new()
				mat.albedo_texture = loaded[0]
				mat.albedo_color = Color.WHITE
				mesh_instance.set_surface_override_material(surface, mat)

func _apply_albedo(root: Node3D, path: String) -> void:
	var texture := load(path) as Texture2D
	if texture == null:
		print("DIAGNOSTIC_ALBEDO=NOT_LOADED path=%s" % path)
		return
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface in mesh_instance.mesh.get_surface_count():
			var original := mesh_instance.get_active_material(surface)
			var mat := (original.duplicate() as StandardMaterial3D) if original is StandardMaterial3D else StandardMaterial3D.new()
			mat.albedo_texture = texture
			mat.albedo_color = Color.WHITE
			mesh_instance.set_surface_override_material(surface, mat)

func _skeleton_signature(root: Node) -> String:
	var parts: PackedStringArray = []
	for node in root.find_children("*", "Skeleton3D", true, false):
		var skeleton := node as Skeleton3D
		for index in skeleton.get_bone_count():
			parts.append(str(skeleton.get_bone_pose(index)))
	return ";".join(parts)

func _print_node_transforms(root: Node) -> void:
	for node in root.find_children("*", "Node3D", true, false):
		var n := node as Node3D
		print("TRANSFORM path=%s pos=%s rot=%s scale=%s" % [n.get_path(), n.position, n.rotation_degrees, n.scale])
		if n is MeshInstance3D:
			var mesh_instance := n as MeshInstance3D
			if mesh_instance.mesh != null:
				for surface in mesh_instance.mesh.get_surface_count():
					var arrays := mesh_instance.mesh.surface_get_arrays(surface)
					var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
					var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV] if arrays[Mesh.ARRAY_TEX_UV] is PackedVector2Array else PackedVector2Array()
					var uv2: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV2] if arrays[Mesh.ARRAY_TEX_UV2] is PackedVector2Array else PackedVector2Array()
					print("MESH_SURFACE path=%s surface=%d mesh=%s vertices=%d uv=%d uv2=%d material=%s" % [n.get_path(), surface, mesh_instance.mesh.get_class(), vertices.size(), uv.size(), uv2.size(), mesh_instance.get_active_material(surface).resource_name if mesh_instance.get_active_material(surface) != null else "MISSING"])

func _print_skeleton(root: Node) -> void:
	for node in root.find_children("*", "Skeleton3D", true, false):
		var skeleton := node as Skeleton3D
		var bones: PackedStringArray = []
		for index in skeleton.get_bone_count():
			var rest := skeleton.get_bone_rest(index)
			var rest_euler := rest.basis.get_euler()
			var rest_degrees := Vector3(rad_to_deg(rest_euler.x), rad_to_deg(rest_euler.y), rad_to_deg(rest_euler.z))
			bones.append("%s<-%d(rest_pos=%s rest_rot_deg=%s)" % [skeleton.get_bone_name(index), skeleton.get_bone_parent(index), rest.origin, rest_degrees])
		print("SKELETON path=%s bone_count=%d hierarchy_and_rest=%s" % [skeleton.get_path(), skeleton.get_bone_count(), "; ".join(bones)])

func _combined_aabb(root: Node3D) -> AABB:
	var result := AABB()
	var has_bounds := false
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var bounds := mesh_instance.get_aabb() * mesh_instance.global_transform
		result = bounds if not has_bounds else result.merge(bounds)
		has_bounds = true
	return result

func _capture(filename: String) -> void:
	if DisplayServer.get_name() == "headless":
		print("IMAGE_CAPTURE_SKIPPED headless name=%s" % filename)
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path("%s/%s" % [OUTPUT_DIR, filename])
	var image := get_viewport().get_texture().get_image()
	print("IMAGE_SAVE name=%s size=%dx%d error=%d" % [filename, image.get_width(), image.get_height(), image.save_png(path)])
