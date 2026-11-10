extends SceneTree

const WARMUP_SEC := 30.0
const RUN_SEC := 120.0
const TOTAL_SESSION_SEC := 600.0 # Full 10-minute warmed session

func _initialize() -> void:
	call_deferred("_run_benchmark")

func _run_benchmark() -> void:
	var packed := load("res://scenes/main/main.tscn") as PackedScene
	var main := packed.instantiate()
	root.add_child(main)
	
	# Start mission
	for _f in range(15):
		await physics_frame
	root.get_node("MissionManager").call("begin_mission")
	await process_frame
	
	print("BENCHMARK_START warming up for %.1f seconds..." % WARMUP_SEC)
	var session_start := Time.get_ticks_msec()
	while (Time.get_ticks_msec() - session_start) < int(WARMUP_SEC * 1000.0):
		await process_frame
	
	print("WARMUP_COMPLETE. Starting 3 x 120s benchmark runs...")
	
	var all_runs_p95: Array[float] = []
	for run_idx in range(3):
		var run_start := Time.get_ticks_msec()
		var intervals_ms: Array[float] = []
		var draw_calls: Array[int] = []
		var primitives: Array[int] = []
		var prev_time := Time.get_ticks_usec()
		
		while (Time.get_ticks_msec() - run_start) < int(RUN_SEC * 1000.0):
			await process_frame
			var curr_time := Time.get_ticks_usec()
			var dt_ms := float(curr_time - prev_time) / 1000.0
			prev_time = curr_time
			intervals_ms.append(dt_ms)
			draw_calls.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
			primitives.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
		
		intervals_ms.sort()
		var n := intervals_ms.size()
		var over_33ms := 0
		for t in intervals_ms:
			if t > 33.3:
				over_33ms += 1
		var pct_over_33ms: float = (float(over_33ms) / float(n)) * 100.0
		var med_draw: int = draw_calls[int(draw_calls.size() * 0.5)]
		var med_prim: int = primitives[int(primitives.size() * 0.5)]
		var mem_static: int = OS.get_static_memory_usage()
		var vram_used: int = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)
		var p95 := intervals_ms[int(n * 0.95)]
		all_runs_p95.append(p95)
		
		print("BENCHMARK_120S_RUN_%d duration_s=%.1f frames=%d median_ms=%.3f p95_ms=%.3f p99_ms=%.3f max_ms=%.3f over_33ms_pct=%.3f%% (%d frames) draw_calls=%d primitives=%d mem_bytes=%d vram_bytes=%d" % [
			run_idx + 1,
			float(Time.get_ticks_msec() - run_start) / 1000.0,
			n,
			intervals_ms[int(n * 0.50)],
			p95,
			intervals_ms[int(n * 0.99)],
			intervals_ms.back(),
			pct_over_33ms,
			over_33ms,
			med_draw,
			med_prim,
			mem_static,
			vram_used
		])
	
	print("3 x 120s RUNS FINISHED. Continuing soak session up to 10 minutes (600s total)...")
	var soak_start := Time.get_ticks_msec()
	var soak_intervals: Array[float] = []
	var prev_soak_time := Time.get_ticks_usec()
	while (Time.get_ticks_msec() - session_start) < int(TOTAL_SESSION_SEC * 1000.0):
		await process_frame
		var curr_time := Time.get_ticks_usec()
		var dt_ms := float(curr_time - prev_soak_time) / 1000.0
		prev_soak_time = curr_time
		soak_intervals.append(dt_ms)
	
	soak_intervals.sort()
	var sn := soak_intervals.size()
	var soak_over_33 := 0
	for t in soak_intervals:
		if t > 33.3:
			soak_over_33 += 1
	var soak_pct_over_33: float = (float(soak_over_33) / float(sn)) * 100.0
	var final_mem_static: int = OS.get_static_memory_usage()
	var final_vram: int = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)
	var total_elapsed_s := float(Time.get_ticks_msec() - session_start) / 1000.0
	
	print("10_MINUTE_SOAK_COMPLETE total_session_s=%.1f soak_frames=%d soak_median_ms=%.3f soak_p95_ms=%.3f soak_p99_ms=%.3f soak_max_ms=%.3f soak_over_33ms_pct=%.3f%% final_mem_bytes=%d final_vram_bytes=%d" % [
		total_elapsed_s,
		sn,
		soak_intervals[int(sn * 0.50)],
		soak_intervals[int(sn * 0.95)],
		soak_intervals[int(sn * 0.99)],
		soak_intervals.back(),
		soak_pct_over_33,
		final_mem_static,
		final_vram
	])
	quit()
