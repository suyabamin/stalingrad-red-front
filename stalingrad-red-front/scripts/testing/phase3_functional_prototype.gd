extends Node3D
## Isolated Phase 3 prototypes. Never instanced by Mission 01 or the live player/enemy scenes.

const OUT_DIR := "res://docs/asset_readiness_previews/phase3"
const SOLDIER_PATH := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier.fbx"
const SOLDIER_TEXTURE := "res://assets/library/incoming_downloads/german_soldie/LowpolySoldier/LowpolySoldier_Texture.png"
const ARMS_PATH := "res://assets/library/incoming_downloads/first_person_arms/fps arms/FPS ARMS RIG 1.fbx"
const ARMS_TEXTURE := "res://assets/library/incoming_downloads/first_person_arms/fps arms/new_diff.png"
const MOSIN_PATH := "res://assets/library/incoming_downloads/mosin_nagant/mosin_nagant_lowpoly.glb"
const PPSH_PATH := "res://assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf"

var camera: Camera3D
var stage: Node3D

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_setup_world()
	print("PHASE3_API SkeletonIK3D=%s" % ClassDB.class_exists("SkeletonIK3D"))
	await _preview_ppsh()
	await _inspect_soldier()
	await _inspect_arms()
	print("PHASE3_DIAGNOSTIC_COMPLETE")
	get_tree().quit()

func _setup_world() -> void:
	stage = Node3D.new()
	stage.name = "IsolatedPrototypeStage"
	add_child(stage)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.15, 0.17, 0.20)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.8, 0.8, 0.8)
	env.ambient_light_energy = 0.7
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35.0, -25.0, 0.0)
	light.light_energy = 0.9
	add_child(light)
	camera = Camera3D.new()
	camera.name = "PrototypeCamera"
	camera.fov = 48.0
	add_child(camera)
	camera.current = true

func _preview_ppsh() -> void:
	var packed := load(PPSH_PATH) as PackedScene
	if packed == null:
		print("PPSH_PREVIEW=FAILED_TO_LOAD")
		return
	var root := packed.instantiate() as Node3D
	stage.add_child(root)
	await get_tree().process_frame
	var ppsh_nodes: Array[Node] = []
	for node in root.find_children("*", "Node3D", true, false):
		if "ppsh" in node.name.to_lower():
			ppsh_nodes.append(node)
	var selected_meshes := 0
	var triangles := 0
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		var keep := false
		for target in ppsh_nodes:
			if target == mesh_node or target.is_ancestor_of(mesh_node):
				keep = true
		mesh_node.visible = keep
		if not keep or mesh_node.mesh == null:
			continue
		selected_meshes += 1
		for surface in mesh_node.mesh.get_surface_count():
			var arrays := mesh_node.mesh.surface_get_arrays(surface)
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			triangles += indices.size() / 3 if not indices.is_empty() else vertices.size() / 3
			var material := mesh_node.get_active_material(surface)
			print("PPSH_SURFACE mesh=%s material=%s" % [mesh_node.name, material.resource_name if material != null else "MISSING"])
	var bounds := _combined_bounds(root)
	root.global_position -= bounds.position + bounds.size * 0.5
	var target := Vector3.ZERO
	camera.look_at_from_position(target + Vector3(0.0, 1.0, 0.18).normalized() * 2.0, target, Vector3.FORWARD)
	await _capture("ppsh_41_existing_pack.png")
	print("PPSH_RESULT nodes=%d meshes=%d triangles=%d bounds=%s license=CC_BY_4.0 source=ww2_low_poly_weapons_pack" % [ppsh_nodes.size(), selected_meshes, triangles, bounds.size])
	root.queue_free()
	await get_tree().process_frame

func _inspect_soldier() -> void:
	var packed := load(SOLDIER_PATH) as PackedScene
	var root := packed.instantiate() as Node3D
	stage.add_child(root)
	await get_tree().process_frame
	var skeletons := root.find_children("*", "Skeleton3D", true, false)
	if skeletons.is_empty():
		print("SOLDIER_INSPECT=NO_SKELETON")
		root.queue_free()
		return
	var skeleton := skeletons[0] as Skeleton3D
	for name in ["Hips", "Spine2", "LeftShoulder", "LeftArm", "LeftForeArm", "LeftHand", "RightShoulder", "RightArm", "RightForeArm", "RightHand"]:
		var idx := skeleton.find_bone(name)
		if idx >= 0:
			var pose := skeleton.get_bone_global_pose(idx)
			print("SOLDIER_BONE name=%s idx=%d parent=%d global_origin=%s global_rotation=%s" % [name, idx, skeleton.get_bone_parent(idx), pose.origin, pose.basis.get_euler()])
	print("SOLDIER_API has_right_arm=%s has_right_hand=%s has_left_arm=%s has_left_hand=%s" % [skeleton.find_bone("RightArm") >= 0, skeleton.find_bone("RightHand") >= 0, skeleton.find_bone("LeftArm") >= 0, skeleton.find_bone("LeftHand") >= 0])
	root.queue_free()
	await get_tree().process_frame

func _inspect_arms() -> void:
	var packed := load(ARMS_PATH) as PackedScene
	var root := packed.instantiate() as Node3D
	stage.add_child(root)
	await get_tree().process_frame
	var skeletons := root.find_children("*", "Skeleton3D", true, false)
	if not skeletons.is_empty():
		var skeleton := skeletons[0] as Skeleton3D
		for name in ["clavicle.R", "upper_arm.R", "forearm.R", "hand.R", "clavicle.L", "upper_arm.L", "forearm.L", "hand.L"]:
			var idx := skeleton.find_bone(name)
			if idx >= 0:
				var pose := skeleton.get_bone_global_pose(idx)
				print("ARMS_BONE name=%s idx=%d parent=%d global_origin=%s global_rotation=%s" % [name, idx, skeleton.get_bone_parent(idx), pose.origin, pose.basis.get_euler()])
	print("ARMS_BOUNDS=%s" % _combined_bounds(root).size)
	root.queue_free()
	await get_tree().process_frame

func _combined_bounds(root: Node3D) -> AABB:
	var result := AABB()
	var has_bounds := false
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh == null:
			continue
		var bounds := mesh_node.get_aabb() * mesh_node.global_transform
		result = bounds if not has_bounds else result.merge(bounds)
		has_bounds = true
	return result

func _capture(filename: String) -> void:
	await get_tree().process_frame
	if DisplayServer.get_name() == "headless":
		print("CAPTURE_SKIPPED headless %s" % filename)
		return
	await RenderingServer.frame_post_draw
	var output := ProjectSettings.globalize_path(OUT_DIR.path_join(filename))
	var image := get_viewport().get_texture().get_image()
	print("CAPTURE name=%s size=%dx%d error=%d" % [filename, image.get_width(), image.get_height(), image.save_png(output)])
