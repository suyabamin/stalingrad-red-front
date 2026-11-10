extends SceneTree

func _initialize() -> void:
	call_deferred("_audit")

func _audit() -> void:
	print("=== STARTING DETAILED ASSET AUDIT VIA GODOT ===")
	var base_dir := "res://assets/all_assets/"
	var dir := DirAccess.open(base_dir)
	if not dir:
		print("Failed to open %s" % base_dir)
		quit(1)
		return

	_scan_dir_recursive(base_dir)
	quit()

func _scan_dir_recursive(path: String) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path := path.path_join(file_name)
			if dir.current_is_dir():
				_scan_dir_recursive(full_path)
			else:
				var ext := file_name.get_extension().to_lower()
				if ext in ["gltf", "glb"]:
					_inspect_model(full_path)
				elif ext in ["wav", "mp3", "ogg", "flac"]:
					_inspect_audio(full_path)
		file_name = dir.get_next()

func _inspect_model(res_path: String) -> void:
	print("\n--- MODEL: %s ---" % res_path)
	var file_access := FileAccess.open(res_path, FileAccess.READ)
	var fsize := 0
	if file_access:
		fsize = file_access.get_length()
		file_access.close()
	print("  File size: %d bytes (%.2f MB)" % [fsize, float(fsize) / (1024.0 * 1024.0)])
	
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_file(ProjectSettings.globalize_path(res_path), state)
	if err != OK:
		print("  ERROR: Failed to parse GLTF: %d" % err)
		return
	
	var scene := doc.generate_scene(state)
	if not scene:
		print("  ERROR: Failed to generate scene from GLTF")
		return
		
	var total_vertices := 0
	var total_triangles := 0
	var mesh_count := 0
	var materials := {}
	var has_skeleton := false
	var anim_player: AnimationPlayer = null
	
	var nodes_to_check := [scene]
	while not nodes_to_check.is_empty():
		var node: Node = nodes_to_check.pop_back()
		if node is MeshInstance3D:
			mesh_count += 1
			var mi: MeshInstance3D = node
			if mi.mesh:
				for s in range(mi.mesh.get_surface_count()):
					var arrays := mi.mesh.surface_get_arrays(s)
					if arrays.size() > Mesh.ARRAY_VERTEX and arrays[Mesh.ARRAY_VERTEX] != null:
						total_vertices += (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
					if arrays.size() > Mesh.ARRAY_INDEX and arrays[Mesh.ARRAY_INDEX] != null:
						total_triangles += (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
					var mat := mi.mesh.surface_get_material(s)
					if mat:
						materials[mat.resource_name if mat.resource_name != "" else "unnamed_mat_%d" % materials.size()] = true
		elif node is Skeleton3D:
			has_skeleton = true
			var sk: Skeleton3D = node
			print("  Skeleton found: %s with %d bones" % [sk.name, sk.get_bone_count()])
		elif node is AnimationPlayer:
			anim_player = node
			
		for c in node.get_children():
			nodes_to_check.append(c)
			
	print("  Meshes: %d | Vertices: %d | Triangles: %d" % [mesh_count, total_vertices, total_triangles])
	print("  Rigged/Skeleton: %s" % has_skeleton)
	if anim_player:
		var anim_list := anim_player.get_animation_list()
		print("  AnimationPlayer present with %d animations: %s" % [anim_list.size(), str(anim_list)])
	else:
		print("  No AnimationPlayer in root generation")
	print("  Materials count: %d" % materials.size())

func _inspect_audio(res_path: String) -> void:
	print("\n--- AUDIO: %s ---" % res_path)
	var fa := FileAccess.open(res_path, FileAccess.READ)
	var fsize := 0
	if fa:
		fsize = fa.get_length()
		fa.close()
	print("  File size: %d bytes (%.2f KB)" % [fsize, float(fsize) / 1024.0])
	var stream = load(res_path)
	if stream:
		print("  Loaded successfully as: %s" % stream.get_class())
		if stream is AudioStreamWAV:
			var w: AudioStreamWAV = stream
			print("  WAV format: %d | mix_rate: %d | stereo: %s | loop_mode: %d | length: %.2fs" % [
				w.format, w.mix_rate, w.stereo, w.loop_mode, w.get_length()
			])
		elif stream is AudioStreamMP3:
			var m: AudioStreamMP3 = stream
			print("  MP3 loop: %s | length: %.2fs" % [m.loop, m.get_length()])
		elif stream is AudioStreamOggVorbis:
			var o: AudioStreamOggVorbis = stream
			print("  OGG loop: %s | length: %.2fs" % [o.loop, o.get_length()])
	else:
		print("  WARNING: Could not load via resource loader (may need editor import scan first)")
