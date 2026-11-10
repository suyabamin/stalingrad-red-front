extends SceneTree

var sample_runs: int = 1
var frames_per_run: int = 1200

func _initialize() -> void:
	call_deferred("_sample")

func _sample() -> void:
	var packed := load("res://scenes/main/main.tscn") as PackedScene
	var main := packed.instantiate()
	root.add_child(main)
	for _frame in range(15):
		await physics_frame
	root.get_node("MissionManager").call("begin_mission")
	await process_frame
	
	for run_idx in range(3):
		var intervals_ms: Array[float] = []
		var draw_calls: Array[int] = []
		var primitives: Array[int] = []
		var previous := Time.get_ticks_usec()
		for _frame in range(frames_per_run):
			await process_frame
			var current := Time.get_ticks_usec()
			intervals_ms.append(float(current - previous) / 1000.0)
			previous = current
			draw_calls.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
			primitives.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
			
		intervals_ms.sort()
		var n := intervals_ms.size()
		var over_33ms: int = 0
		for t in intervals_ms:
			if t > 33.3:
				over_33ms += 1
		var pct_over_33ms: float = (float(over_33ms) / float(n)) * 100.0
		
		var med_draw: int = draw_calls[int(draw_calls.size() * 0.5)]
		var med_prim: int = primitives[int(primitives.size() * 0.5)]
		var mem_static: int = OS.get_static_memory_usage()
		var vram_used: int = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)
		
		print("PHASE5C_PERF_RUN_%d frames=%d median_ms=%.3f p95_ms=%.3f p99_ms=%.3f max_ms=%.3f over_33ms_pct=%.2f%% draw_calls=%d primitives=%d mem_static_bytes=%d vram_bytes=%d" % [
			run_idx + 1,
			n,
			intervals_ms[int(n * 0.50)],
			intervals_ms[int(n * 0.95)],
			intervals_ms[int(n * 0.99)],
			intervals_ms.back(),
			pct_over_33ms,
			med_draw,
			med_prim,
			mem_static,
			vram_used
		])
	quit()
