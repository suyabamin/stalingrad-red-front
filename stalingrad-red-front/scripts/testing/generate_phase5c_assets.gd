extends SceneTree

func _initialize() -> void:
	_generate_particle_texture()
	_generate_audio()
	quit()

func _generate_particle_texture() -> void:
	var size := 64
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := float(size - 1) * 0.5
	var max_r := center
	for y in range(size):
		for x in range(size):
			var dx := float(x) - center
			var dy := float(y) - center
			var dist := sqrt(dx * dx + dy * dy)
			var norm := dist / max_r
			if norm >= 1.0:
				img.set_pixel(x, y, Color(1, 1, 1, 0))
			else:
				# Smooth cubic falloff
				var factor := 1.0 - norm
				var a := factor * factor * (3.0 - 2.0 * factor)
				# Soft exponent
				a = pow(a, 1.4)
				img.set_pixel(x, y, Color(1, 1, 1, a))
	var path := "res://assets/textures/environment/particle_soft.png"
	var err := img.save_png(path)
	print("Generated particle texture %s err=%d" % [path, err])

func _generate_audio() -> void:
	_generate_wind_wav("res://assets/audio/environment/wind_ambient.wav")
	_generate_artillery_wav("res://assets/audio/environment/distant_artillery.wav")
	_generate_battlefield_wav("res://assets/audio/environment/distant_battlefield.wav")

func _generate_wind_wav(path: String) -> void:
	var rate := 22050
	var duration := 10.0
	var total_samples := int(rate * duration)
	var rng := RandomNumberGenerator.new()
	rng.seed = 98143
	
	# Generate raw noise and filter it into smooth wind rumble
	var left_raw := PackedFloat32Array()
	var right_raw := PackedFloat32Array()
	left_raw.resize(total_samples)
	right_raw.resize(total_samples)
	
	var b0_l := 0.0
	var b1_l := 0.0
	var b0_r := 0.0
	var b1_r := 0.0
	for i in range(total_samples):
		var white_l := rng.randf_range(-1.0, 1.0)
		var white_r := rng.randf_range(-1.0, 1.0)
		# Lowpass filter for deep wind hiss/rumble
		b0_l = 0.94 * b0_l + 0.06 * white_l
		b1_l = 0.90 * b1_l + 0.10 * b0_l
		b0_r = 0.94 * b0_r + 0.06 * white_r
		b1_r = 0.90 * b1_r + 0.10 * b0_r
		
		# Slow wind swell LFO
		var t := float(i) / float(rate)
		var swell := 0.65 + 0.35 * sin(t * 0.18 * TAU + 0.3) * cos(t * 0.09 * TAU)
		var gust := 0.15 * sin(t * 0.45 * TAU + 1.2)
		var gain := (swell + gust) * 0.22
		
		left_raw[i] = b1_l * gain
		right_raw[i] = b1_r * gain * 0.95
	
	# Seamless loop crossfade across 1.0 second (22050 samples)
	var fade_len := rate
	for i in range(fade_len):
		var frac := float(i) / float(fade_len)
		var head_idx := i
		var tail_idx := total_samples - fade_len + i
		var blended_l := left_raw[tail_idx] * (1.0 - frac) + left_raw[head_idx] * frac
		var blended_r := right_raw[tail_idx] * (1.0 - frac) + right_raw[head_idx] * frac
		left_raw[head_idx] = blended_l
		left_raw[tail_idx] = blended_l
		right_raw[head_idx] = blended_r
		right_raw[tail_idx] = blended_r

	# Pack stereo 16-bit PCM
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 4) # 2 channels * 2 bytes
	var p := 0
	for i in range(total_samples):
		var sl := clampi(int(clampf(left_raw[i], -1.0, 1.0) * 32767.0), -32768, 32767)
		var sr := clampi(int(clampf(right_raw[i], -1.0, 1.0) * 32767.0), -32768, 32767)
		pcm.encode_s16(p, sl)
		pcm.encode_s16(p + 2, sr)
		p += 4
	
	_write_riff_wav(path, 2, rate, 16, pcm)

func _generate_artillery_wav(path: String) -> void:
	var rate := 22050
	var duration := 4.5
	var total_samples := int(rate * duration)
	var rng := RandomNumberGenerator.new()
	rng.seed = 44719
	
	var samples := PackedFloat32Array()
	samples.resize(total_samples)
	
	var b0 := 0.0
	var b1 := 0.0
	for i in range(total_samples):
		var t := float(i) / float(rate)
		# Deep low transient thump
		var thump := 0.0
		if t < 0.6:
			var freq := lerpf(68.0, 36.0, t / 0.6)
			thump = sin(t * freq * TAU) * exp(-t * 6.0) * 0.75
		
		# Low rumble tail
		var white := rng.randf_range(-1.0, 1.0)
		b0 = 0.95 * b0 + 0.05 * white
		b1 = 0.92 * b1 + 0.08 * b0
		var rumble_env := exp(-t * 0.95) * (0.8 if t > 0.05 else t / 0.05)
		var rumble := b1 * rumble_env * 0.6
		
		samples[i] = thump + rumble
	
	# Pack mono 16-bit PCM
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)
	for i in range(total_samples):
		var s := clampi(int(clampf(samples[i] * 0.65, -1.0, 1.0) * 32767.0), -32768, 32767)
		pcm.encode_s16(i * 2, s)
	
	_write_riff_wav(path, 1, rate, 16, pcm)

func _generate_battlefield_wav(path: String) -> void:
	var rate := 22050
	var duration := 6.0
	var total_samples := int(rate * duration)
	var rng := RandomNumberGenerator.new()
	rng.seed = 82195
	
	var samples := PackedFloat32Array()
	samples.resize(total_samples)
	
	var b0 := 0.0
	var b1 := 0.0
	for i in range(total_samples):
		var t := float(i) / float(rate)
		var white := rng.randf_range(-1.0, 1.0)
		b0 = 0.96 * b0 + 0.04 * white
		b1 = 0.93 * b1 + 0.07 * b0
		
		# Several distant rolling bursts
		var env1 := exp(-absf(t - 1.2) * 2.2) * 0.45
		var env2 := exp(-absf(t - 3.8) * 1.8) * 0.38
		var bed := 0.12 * (1.0 + 0.3 * sin(t * 0.5 * TAU))
		var total_env := env1 + env2 + bed
		
		var pop := 0.0
		if absf(t - 1.2) < 0.2:
			pop = sin((t - 1.2) * 55.0 * TAU) * 0.35 * exp(-absf(t - 1.2) * 12.0)
		if absf(t - 3.8) < 0.25:
			pop += sin((t - 3.8) * 48.0 * TAU) * 0.30 * exp(-absf(t - 3.8) * 10.0)
			
		samples[i] = (b1 * total_env * 0.6) + pop
	
	# Pack mono 16-bit PCM
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)
	for i in range(total_samples):
		var s := clampi(int(clampf(samples[i] * 0.55, -1.0, 1.0) * 32767.0), -32768, 32767)
		pcm.encode_s16(i * 2, s)
		
	_write_riff_wav(path, 1, rate, 16, pcm)

func _write_riff_wav(res_path: String, channels: int, rate: int, bits: int, data: PackedByteArray) -> void:
	var global_path := ProjectSettings.globalize_path(res_path)
	var file := FileAccess.open(global_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open %s for write" % res_path)
		return
	
	# RIFF header
	var data_size := data.size()
	var chunk_size := 36 + data_size
	file.store_buffer("RIFF".to_ascii_buffer())
	file.store_32(chunk_size)
	file.store_buffer("WAVE".to_ascii_buffer())
	
	# fmt subchunk
	file.store_buffer("fmt ".to_ascii_buffer())
	file.store_32(16) # subchunk1 size (16 for PCM)
	file.store_16(1)  # audio format (1 = PCM)
	file.store_16(channels)
	file.store_32(rate)
	var byte_rate := rate * channels * (bits / 8)
	file.store_32(byte_rate)
	var block_align := channels * (bits / 8)
	file.store_16(block_align)
	file.store_16(bits)
	
	# data subchunk
	file.store_buffer("data".to_ascii_buffer())
	file.store_32(data_size)
	file.store_buffer(data)
	file.close()
	print("Wrote %s (%d bytes)" % [res_path, 44 + data_size])
