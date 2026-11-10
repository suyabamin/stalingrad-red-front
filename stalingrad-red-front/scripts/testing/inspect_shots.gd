extends SceneTree

func _initialize() -> void:
	call_deferred("_inspect_shots")

func _inspect_shots() -> void:
	var path := "res://assets/library/audio/weapons/soviet/mosin_battle_shots.wav"
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		print("Could not open %s" % path)
		quit(1)
		return
	
	var bytes := file.get_buffer(file.get_length())
	file.close()
	print("Loaded %s (%d bytes)" % [path, bytes.size()])
	
	# Parse fmt chunk to get rate and channels
	var channels := 2
	var rate := 48000
	var bits := 24
	var data_pos := 72 + 8
	var data_len := 3823932
	
	# Find gunshot transient peaks in the 24-bit stereo stream
	var bytes_per_sample := channels * (bits / 8) # 2 * 3 = 6 bytes
	var total_frames := data_len / bytes_per_sample
	print("Total frames: %d (%.2f seconds)" % [total_frames, float(total_frames) / float(rate)])
	
	var peaks: Array[Dictionary] = []
	var prev_amp := 0.0
	for f in range(0, total_frames, 240): # check every 5ms
		var offset := data_pos + f * bytes_per_sample
		if offset + 6 > bytes.size(): break
		# Read left channel 24-bit
		var b0 := bytes[offset]
		var b1 := bytes[offset + 1]
		var b2 := bytes[offset + 2]
		var val := (b0 | (b1 << 8) | (b2 << 16))
		if val & 0x800000:
			val = val - 0x1000000
		var norm: float = absf(float(val) / 8388607.0)
		if norm > 0.4 and (norm - prev_amp) > 0.2:
			var t := float(f) / float(rate)
			peaks.append({"t": t, "frame": f, "amp": norm})
			print("Detected gunshot peak at t=%.3fs amp=%.2f" % [t, norm])
		prev_amp = norm
		
	# If we found peaks, extract the first clean gunshot (1.2 seconds duration) as 16-bit PCM WAV!
	if not peaks.is_empty():
		var first_peak: Dictionary = peaks[0]
		var start_frame: int = maxi(0, first_peak["frame"] - int(rate * 0.05)) # 50ms before peak
		var shot_len_frames := int(rate * 1.4) # 1.4 seconds
		var out_samples := PackedByteArray()
		out_samples.resize(shot_len_frames * 2 * 2) # stereo 16-bit
		var out_p := 0
		for sf in range(shot_len_frames):
			var in_frame := start_frame + sf
			if in_frame >= total_frames: break
			var in_offset := data_pos + in_frame * bytes_per_sample
			var l0 := bytes[in_offset]
			var l1 := bytes[in_offset + 1]
			var l2 := bytes[in_offset + 2]
			var l_val := (l0 | (l1 << 8) | (l2 << 16))
			if l_val & 0x800000: l_val -= 0x1000000
			
			var r0 := bytes[in_offset + 3]
			var r1 := bytes[in_offset + 4]
			var r2 := bytes[in_offset + 5]
			var r_val := (r0 | (r1 << 8) | (r2 << 16))
			if r_val & 0x800000: r_val -= 0x1000000
			
			# Normalize and convert 24-bit to 16-bit
			var s16_l := clampi(int(clampf(float(l_val) / 8388607.0 * 1.25, -1.0, 1.0) * 32767.0), -32768, 32767)
			var s16_r := clampi(int(clampf(float(r_val) / 8388607.0 * 1.25, -1.0, 1.0) * 32767.0), -32768, 32767)
			out_samples.encode_s16(out_p, s16_l)
			out_samples.encode_s16(out_p + 2, s16_r)
			out_p += 4
			
		var out_path := "res://assets/library/audio/weapons/soviet/mosin_fire.wav"
		_save_wav(out_path, 2, rate, 16, out_samples)
		print("Extracted and saved Mosin single shot to %s" % out_path)
	quit()

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
	file.store_16(1) # PCM
	file.store_16(channels)
	file.store_32(rate)
	file.store_32(rate * channels * (bits / 8))
	file.store_16(channels * (bits / 8))
	file.store_16(bits)
	file.store_buffer("data".to_ascii_buffer())
	file.store_32(data_size)
	file.store_buffer(data)
	file.close()
