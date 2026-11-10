extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var packed := load("res://scenes/main/main.tscn") as PackedScene
	var main := packed.instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	await physics_frame
	get_root().size = Vector2i(1280, 720)
	var player := main.get_node("Player") as Node3D
	var hud := main.get_node("HUD") as CanvasLayer
	get_root().gui_disable_input = true
	root.get_tree().paused = false
	
	var views: Array[Dictionary] = [
		{"name": "volga_landing", "pos": Vector3(0, 0.08, 22), "rot": Vector3(-0.04, 0.0, 0.0), "hud": false},
		{"name": "battlefield_transition", "pos": Vector3(0, 0.08, -18), "rot": Vector3(-0.05, 0.0, 0.0), "hud": false},
		{"name": "ruined_stalingrad_street", "pos": Vector3(0, 0.08, -61), "rot": Vector3(-0.04, 0.0, 0.0), "hud": false},
		{"name": "building_closeup", "pos": Vector3(11.5, 0.08, -28.0), "rot": Vector3(-0.12, -PI * 0.5, 0.0), "hud": false},
		{"name": "military_defensive_position", "pos": Vector3(13.0, 0.08, -39.0), "rot": Vector3(-0.08, PI * 0.5, 0.0), "hud": false},
		{"name": "player_level_gameplay", "pos": Vector3(0, 0.08, 22), "rot": Vector3(-0.04, 0.0, 0.0), "hud": true},
		{"name": "combat_sightline_landing", "pos": Vector3(0, 0.08, 16), "rot": Vector3(0.0, 0.0, 0.0), "hud": false},
		{"name": "combat_sightline_transition", "pos": Vector3(0, 0.08, -24), "rot": Vector3(0.0, 0.0, 0.0), "hud": false},
		{"name": "combat_sightline_street", "pos": Vector3(0, 0.08, -68), "rot": Vector3(0.0, 0.0, 0.0), "hud": false},
	]
	
	for view in views:
		hud.visible = view["hud"]
		if view["hud"]:
			hud.call("_on_start_mission_pressed")
			await process_frame
		player.global_position = view["pos"]
		player.rotation.y = view["rot"].y
		player.get_node("Head").rotation.x = view["rot"].x
		# Give a few frames for particles and rendering to settle
		for _f in range(12):
			await process_frame
		await RenderingServer.frame_post_draw
		var image := get_root().get_texture().get_image()
		var path := "res://docs/phase5c_%s.png" % view["name"]
		var result := image.save_png(path)
		print("CAPTURE %s error=%s size=%s" % [path, result, image.get_size()])
	quit()
