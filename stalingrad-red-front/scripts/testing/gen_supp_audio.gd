extends SceneTree

func _initialize() -> void:
	call_deferred("_generate_supplementary_audio")

func _generate_supplementary_audio() -> void:
	_generate_dry_fire("res://assets/library/audio/weapons/dry_fire_click.wav")
	_generate_ppsh_reload("res://assets/library/audio/weapons/soviet/ppsh_reload.wav")
	quit()

func _generate_dry_fire(path: String) -> void:
	var rate := 44100
	var duration := 0.12 # 120 ms
	var total_samples := int(rate * duration)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2) # mono 16-bit
	var rng := RandomNumberGenerator.new()
	rng.seed = 71239
	
	for i in range(total_samples):
		var t := float(i) / float(rate)
		# Dual metal strike clicks (firing pin drop)
		var click1 := sin(t * 1850.0 * TAU) * exp(-t * 85.0)
		var click2 := 0.0
		if t > 0.015:
			click2 = sin((t - 0.015) * 3200.0 * TAU) * exp(-(t - 0.015) * 110.0) * 0.7
		var noise := rng.randf_range(-1.0, 1.0) * exp(-t * 90.0) * 0.3
		var s := clampi(int(clampf((click1 + click2 + noise) * 0.85, -1.0, 1.0) * 32767.0), -32768, 32767)
		pcm.encode_s16(i * 2, s)
		
	_save_wav(path, 1, rate, 16, pcm)

func _generate_ppsh_reload(path: String) -> void:
	var rate := 44100
	var duration := 2.2 # matches reload_duration
	var total_samples := int(rate * duration)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2 * 2) # stereo 16-bit
	var rng := RandomNumberGenerator.new()
	rng.seed = 55431
	var out_p := 0
	
	for i in range(total_samples):
		var t := float(i) / float(rate)
		# 1. Drum release latch at t = 0.3s
		var latch := 0.0
		if absf(t - 0.3) < 0.08:
			latch = sin((t - 0.3) * 1200.0 * TAU) * exp(-absf(t - 0.3) * 45.0) * 0.5
		# 2. Heavy drum magazine slide out at t = 0.55s
		var mag_out := 0.0
		if t >= 0.5 and t < 0.8:
			mag_out = rng.randf_range(-0.3, 0.3) * sin((t - 0.5) * 800.0 * TAU) * exp(-(t - 0.5) * 8.0)
		# 3. New drum insertion & lock at t = 1.35s
		var mag_in := 0.0
		if absf(t - 1.35) < 0.12:
			mag_in = sin((t - 1.35) * 950.0 * TAU) * exp(-absf(t - 1.35) * 35.0) * 0.75
		# 4. Bolt pull & chamber at t = 1.85s
		var bolt := 0.0
		if absf(t - 1.85) < 0.15:
			bolt = (sin((t - 1.85) * 1450.0 * TAU) + 0.4 * rng.randf_range(-1.0, 1.0)) * exp(-absf(t - 1.85) * 28.0) * 0.85
			
		var val := latch + mag_out + mag_in + bolt
		var s := clampi(int(clampf(val * 0.9, -1.0, 1.0) * 32767.0), -32768, 32767)
		pcm.encode_s16(out_p, s)
		pcm.encode_s16(out_p + 2, s)
		out_p += 4
		
	_save_wav(path, 2, rate, 16, pcm)

func _save_wav(res_path: String, channels: int, rate: int, bits: int, data: PackedByteArray) -> void:
	var global_path := ProjectSettings.globalize_path(res_path)
	var file := FileAccess.open(global_path, FileAccess.WRITE)
	if not file: return
	var data_size := data.size()
	file.store_buffer("RIFF".to_ascii_buffer())
	file.store_32(36 + data_size)
	file.store_buffer("WAVE".to_ascii_buffer())
	file.store_buffer("fmt ".to_ascii_buffer())
	file.store_32(16)
	file.store_16(1)
	file.store_16(channels)
	file.store_32(rate)
	file.store_32(rate * channels * (bits / 8))
	file.store_16(channels * (bits / 8))
	file.store_16(bits)
	file.store_buffer("data".to_ascii_buffer())
	file.store_32(data_size)
	file.store_buffer(data)
	file.close()
	print("Saved WAV: %s" % res_path)
