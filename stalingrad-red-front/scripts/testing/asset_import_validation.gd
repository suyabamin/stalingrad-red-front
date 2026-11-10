extends Node
## Isolated, read-only runtime inspection of downloaded scene imports.

const SCENES: Array[Dictionary] = [
	{"label": "German soldier FBX", "path": "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"},
	{"label": "Mosin-Nagant GLB", "path": "res://assets/library/incoming_downloads/mosin_nagant/mosin_nagant_lowpoly.glb"},
	{"label": "First-person arms FBX", "path": "res://assets/library/incoming_downloads/first_person_arms/fps arms/FPS ARMS RIG 1.fbx"},
	{"label": "First-person arms test FBX", "path": "res://assets/library/incoming_downloads/first_person_arms/fps arms/FPS ARMS RIG 1 test.fbx"},
	{"label": "Existing static PPSH pack", "path": "res://assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf"},
]

func _ready() -> void:
	call_deferred("_run_inspection")

func _run_inspection() -> void:
	var failures := 0
	_setup_preview_environment()
	_save_texture_previews()
	for entry in SCENES:
		print("\n=== %s ===" % entry.label)
		var packed := load(entry.path) as PackedScene
		if packed == null:
			push_error("Import failed to load as PackedScene: %s" % entry.path)
			failures += 1
			continue
		var instance := packed.instantiate() as Node3D
		if instance == null:
			push_error("Imported scene did not instantiate as Node3D: %s" % entry.path)
			failures += 1
			continue
		add_child(instance)
		await get_tree().process_frame
		if entry.label == "Existing static PPSH pack":
			await _inspect_existing_ppsh(instance)
		else:
			_inspect_instance(instance)
			_apply_diagnostic_texture(instance, entry.label)
			if entry.label == "German soldier FBX":
				await _test_skeleton_pose(instance, "LeftArm")
			await _capture_preview(instance, entry.label)
		if entry.label == "First-person arms test FBX":
			await _test_arm_animation(instance)
		instance.queue_free()
		await get_tree().process_frame
	print("\nASSET_IMPORT_VALIDATION_FAILURES=%d" % failures)
	get_tree().quit(1 if failures > 0 else 0)

func _setup_preview_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.16, 0.18, 0.21)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.78, 0.78)
	environment.ambient_light_energy = 1.0
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35.0, -25.0, 0.0)
	light.light_energy = 1.2
	add_child(light)
	var camera := Camera3D.new()
	camera.name = "ValidationCamera"
	add_child(camera)
	camera.position = Vector3(0.0, 2.0, 6.0)
	camera.look_at_from_position(camera.position, Vector3.ZERO, Vector3.UP)
	camera.current = true

func _capture_preview(root: Node3D, label: String) -> void:
	if DisplayServer.get_name() == "headless":
		print("PREVIEW skipped for %s: headless rendering has no viewport texture" % label)
		return
	# Keep importer-applied unit conversion intact; frame the result using its world AABB.
	root.scale = Vector3.ONE
	await get_tree().process_frame
	await get_tree().process_frame
	var bounds := _combined_global_aabb(root)
	var center := bounds.position + bounds.size * 0.5
	var frame_size: float = maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	root.position -= center
	var direction := Vector3(1.0, 0.25, 0.2) if label == "Mosin-Nagant GLB" else Vector3(0.0, 0.2, 1.0)
	var camera := get_node("ValidationCamera") as Camera3D
	var camera_position := direction.normalized() * maxf(frame_size * 1.65, 1.0)
	camera.look_at_from_position(camera_position, Vector3.ZERO, Vector3.UP)
	await get_tree().process_frame
	var output_dir := ProjectSettings.globalize_path("res://.godot/tmp/asset_previews")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var safe_name := label.to_snake_case()
	var output_path := output_dir.path_join("%s.png" % safe_name)
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(output_path)
	print("PREVIEW label=%s size=%dx%d imported_world_bounds=%s save_error=%d" % [label, image.get_width(), image.get_height(), bounds.size, error])

func _combined_global_aabb(root: Node3D) -> AABB:
	var has_bounds := false
	var combined := AABB()
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh == null:
			continue
		var transformed := mesh_node.get_aabb() * mesh_node.global_transform
		combined = transformed if not has_bounds else combined.merge(transformed)
		has_bounds = true
	return combined

func _save_texture_previews() -> void:
	var texture_paths := [
		"res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier_Texture.png",
		"res://assets/library/incoming_downloads/first_person_arms/fps arms/new_diff.png",
		"res://assets/library/incoming_downloads/mosin_nagant/mosin_nagant_lowpoly_0.png",
		"res://assets/library/incoming_downloads/mosin_nagant/mosin_nagant_lowpoly_1.png",
		"res://assets/library/incoming_downloads/mosin_nagant/mosin_nagant_lowpoly_2.png",
	]
	var output_dir := ProjectSettings.globalize_path("res://.godot/tmp/asset_previews")
	DirAccess.make_dir_recursive_absolute(output_dir)
	for path in texture_paths:
		var texture := load(path) as Texture2D
		if texture == null:
			push_error("Texture preview could not load: %s" % path)
			continue
		var image := texture.get_image()
		image.resize(512, 512, Image.INTERPOLATE_LANCZOS)
		var output_path := output_dir.path_join(path.get_file().get_basename() + "_texture_preview.png")
		print("TEXTURE_PREVIEW path=%s source=%dx%d saved=%d" % [output_path, texture.get_width(), texture.get_height(), image.save_png(output_path)])

func _apply_diagnostic_texture(root: Node3D, label: String) -> void:
	var texture_path := ""
	match label:
		"German soldier FBX": texture_path = "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier_Texture.png"
		"First-person arms FBX", "First-person arms test FBX": texture_path = "res://assets/library/incoming_downloads/first_person_arms/fps arms/new_diff.png"
		_: return
	var texture := load(texture_path) as Texture2D
	if texture == null:
		return
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh == null:
			continue
		for surface in mesh_node.mesh.get_surface_count():
			var source := mesh_node.get_active_material(surface)
			if not source is StandardMaterial3D:
				continue
			var diagnostic := (source as StandardMaterial3D).duplicate() as StandardMaterial3D
			diagnostic.albedo_texture = texture
			diagnostic.albedo_color = Color.WHITE
			mesh_node.set_surface_override_material(surface, diagnostic)
	print("DIAGNOSTIC_TEXTURE_OVERRIDE label=%s texture=%s (isolated preview only)" % [label, texture_path])

func _inspect_existing_ppsh(root: Node3D) -> void:
	var targets: Array[Node] = []
	for node in root.find_children("*", "Node3D", true, false):
		if "ppsh" in node.name.to_lower():
			targets.append(node)
			print("PPSH_NODE path=%s type=%s" % [node.get_path(), node.get_class()])
	var selected := 0
	var triangles := 0
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		var keep_visible := false
		for target in targets:
			if target == mesh_node or target.is_ancestor_of(mesh_node):
				keep_visible = true
		mesh_node.visible = keep_visible
		if not keep_visible or mesh_node.mesh == null:
			continue
		selected += 1
		for surface in mesh_node.mesh.get_surface_count():
			var arrays := mesh_node.mesh.surface_get_arrays(surface)
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			triangles += indices.size() / 3 if not indices.is_empty() else vertices.size() / 3
			var material := mesh_node.get_active_material(surface)
			print("PPSH_MESH path=%s mesh=%s triangles=%d material=%s" % [mesh_node.get_path(), mesh_node.mesh.get_class(), (indices.size() / 3 if not indices.is_empty() else vertices.size() / 3), material.resource_name if material != null else "MISSING"])
	print("PPSH_SUMMARY matching_nodes=%d selected_meshes=%d triangles=%d" % [targets.size(), selected, triangles])
	await _capture_preview(root, "Existing static PPSH pack")

func _inspect_instance(root: Node3D) -> void:
	var mesh_nodes := root.find_children("*", "MeshInstance3D", true, false)
	var skeletons := root.find_children("*", "Skeleton3D", true, false)
	var players := root.find_children("*", "AnimationPlayer", true, false)
	var total_triangles := 0
	var surface_count := 0
	var material_count := 0
	var textured_surface_count := 0
	var skinned_mesh_count := 0
	print("root=%s children=%d mesh_instances=%d skeletons=%d animation_players=%d" % [root.name, root.get_child_count(), mesh_nodes.size(), skeletons.size(), players.size()])
	print("IMPORT_WORLD_BOUNDS size=%s" % _combined_global_aabb(root).size)
	for node in mesh_nodes:
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh == null:
			continue
		var local_bounds := mesh_node.get_aabb()
		print("MESH %s mesh=%s surfaces=%d local_aabb_size=%s local_aabb_position=%s skin=%s skeleton_path=%s" % [mesh_node.get_path(), mesh_node.mesh.get_class(), mesh_node.mesh.get_surface_count(), local_bounds.size, local_bounds.position, mesh_node.skin != null, mesh_node.skeleton])
		if mesh_node.skin != null:
			skinned_mesh_count += 1
		for surface in mesh_node.mesh.get_surface_count():
			surface_count += 1
			var arrays := mesh_node.mesh.surface_get_arrays(surface)
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var triangles := indices.size() / 3 if not indices.is_empty() else vertices.size() / 3
			total_triangles += triangles
			var material := mesh_node.get_active_material(surface)
			if material != null:
				material_count += 1
				var maps: Array[String] = []
				if material is BaseMaterial3D:
					var base := material as BaseMaterial3D
					for map_entry in [["albedo", base.albedo_texture], ["normal", base.normal_texture], ["roughness", base.roughness_texture], ["metallic", base.metallic_texture]]:
						var texture := map_entry[1] as Texture2D
						if texture != null:
							maps.append("%s:%dx%d" % [map_entry[0], texture.get_width(), texture.get_height()])
				if not maps.is_empty():
					textured_surface_count += 1
				print("SURFACE %d triangles=%d material=%s class=%s textures=%s" % [surface, triangles, material.resource_name, material.get_class(), ",".join(maps)])
			else:
				print("SURFACE %d triangles=%d material=MISSING" % [surface, triangles])
	print("SUMMARY triangles=%d surfaces=%d material_bound_surfaces=%d textured_surfaces=%d skinned_meshes=%d" % [total_triangles, surface_count, material_count, textured_surface_count, skinned_mesh_count])
	for skeleton_node in skeletons:
		var skeleton := skeleton_node as Skeleton3D
		print("SKELETON path=%s bones=%d rest_bones=%d" % [skeleton.get_path(), skeleton.get_bone_count(), skeleton.get_bone_count()])
		var hierarchy: PackedStringArray = []
		for bone in skeleton.get_bone_count():
			hierarchy.append("%s<-%d" % [skeleton.get_bone_name(bone), skeleton.get_bone_parent(bone)])
		print("BONE_HIERARCHY %s" % ", ".join(hierarchy))
	for player_node in players:
		var animation_player := player_node as AnimationPlayer
		print("ANIMATION_PLAYER path=%s root=%s" % [animation_player.get_path(), animation_player.root_node])
		for animation_name in animation_player.get_animation_list():
			var animation := animation_player.get_animation(animation_name)
			print("CLIP name=%s length=%.6f loop_mode=%d tracks=%d" % [animation_name, animation.length, animation.loop_mode, animation.get_track_count()])

func _test_arm_animation(root: Node3D) -> void:
	var skeletons := root.find_children("*", "Skeleton3D", true, false)
	var players := root.find_children("*", "AnimationPlayer", true, false)
	if skeletons.is_empty() or players.is_empty():
		print("DEFORMATION_TEST=NOT_RUN (no skeleton or AnimationPlayer)")
		return
	var skeleton := skeletons[0] as Skeleton3D
	var animation_player := players[0] as AnimationPlayer
	for animation_name in animation_player.get_animation_list():
		var animation := animation_player.get_animation(animation_name)
		if animation.length <= 0.05 or animation_name == &"RESET":
			continue
		var before := _pose_signature(skeleton)
		animation_player.play(animation_name)
		animation_player.seek(minf(0.25, animation.length * 0.5), true)
		await get_tree().process_frame
		var after := _pose_signature(skeleton)
		print("DEFORMATION_TEST clip=%s pose_changed=%s" % [animation_name, before != after])
		animation_player.stop()
		return
	print("DEFORMATION_TEST=NOT_RUN (no non-RESET animation clip)")

func _test_skeleton_pose(root: Node3D, bone_name: String) -> void:
	var skeletons := root.find_children("*", "Skeleton3D", true, false)
	if skeletons.is_empty():
		print("MANUAL_SKIN_TEST=NOT_RUN (no Skeleton3D)")
		return
	var skeleton := skeletons[0] as Skeleton3D
	var bone_index := skeleton.find_bone(bone_name)
	if bone_index < 0:
		print("MANUAL_SKIN_TEST=NOT_RUN (bone %s missing)" % bone_name)
		return
	var before := skeleton.get_bone_global_pose(bone_index)
	var original_rotation := skeleton.get_bone_pose_rotation(bone_index)
	skeleton.set_bone_pose_rotation(bone_index, original_rotation * Quaternion(Vector3.FORWARD, deg_to_rad(35.0)))
	skeleton.force_update_all_bone_transforms()
	await get_tree().process_frame
	var after := skeleton.get_bone_global_pose(bone_index)
	print("MANUAL_SKIN_TEST bone=%s global_pose_changed=%s" % [bone_name, not before.is_equal_approx(after)])

func _pose_signature(skeleton: Skeleton3D) -> String:
	var values: PackedStringArray = []
	for bone in skeleton.get_bone_count():
		values.append(str(skeleton.get_bone_pose(bone)))
	return "|".join(values)
