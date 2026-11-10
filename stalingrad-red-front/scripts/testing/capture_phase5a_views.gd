extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := scene.instantiate()
	root.add_child(main)
	await process_frame
	get_root().size = Vector2i(1280, 720)
	var player := main.get_node("Player") as Node3D
	var camera := main.get_node("Player/Head/Camera3D") as Camera3D
	var hud := main.get_node("HUD")
	hud.hide()
	get_root().gui_disable_input = true
	root.get_tree().paused = false
	var views: Array[Dictionary] = [
		{"name": "volga_landing", "pos": Vector3(0, 1.7, 22), "rot": Vector3(-0.04, 0.0, 0.0)},
		{"name": "battlefield_transition", "pos": Vector3(0, 1.7, -18), "rot": Vector3(-0.05, 0.0, 0.0)},
		{"name": "ruined_street", "pos": Vector3(0, 1.7, -61), "rot": Vector3(-0.04, 0.0, 0.0)},
		{"name": "closeup_ground_road_building", "pos": Vector3(-5.0, 1.7, 8), "rot": Vector3(-0.19, -0.27, 0.0)},
	]
	for view in views:
		player.global_position = view["pos"]
		camera.rotation = view["rot"]
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var image := get_root().get_texture().get_image()
		var path := "res://docs/phase5a_%s.png" % view["name"]
		var result := image.save_png(path)
		print("CAPTURE %s error=%s size=%s" % [path, result, image.get_size()])
	quit()
