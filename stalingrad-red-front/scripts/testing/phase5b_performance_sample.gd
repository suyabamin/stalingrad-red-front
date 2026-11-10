extends SceneTree

func _initialize() -> void:
	call_deferred("_sample")

func _sample() -> void:
	var packed := load("res://scenes/main/main.tscn") as PackedScene
	var main := packed.instantiate()
	root.add_child(main)
	for _frame in range(10):
		await physics_frame
	root.get_node("MissionManager").call("begin_mission")
	await process_frame
	var intervals_ms: Array[float] = []
	var previous := Time.get_ticks_usec()
	for _frame in range(1200):
		await process_frame
		var current := Time.get_ticks_usec()
		intervals_ms.append(float(current - previous) / 1000.0)
		previous = current
	intervals_ms.sort()
	print("PHASE5B_PERF frames=%d median_ms=%.3f p95_ms=%.3f p99_ms=%.3f max_ms=%.3f" % [
		intervals_ms.size(),
		intervals_ms[int(intervals_ms.size() * 0.50)],
		intervals_ms[int(intervals_ms.size() * 0.95)],
		intervals_ms[int(intervals_ms.size() * 0.99)],
		intervals_ms.back(),
	])
	quit()
