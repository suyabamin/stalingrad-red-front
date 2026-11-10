extends SceneTree

func _init() -> void:
	print("Converting audio files to native AudioStreamWAV .tres resources...")
	_convert_wav("res://assets/library/audio/weapons/soviet/mosin_fire.wav", "res://assets/library/audio/weapons/soviet/mosin_fire.tres")
	_convert_wav("res://assets/library/audio/weapons/soviet/mosin_reload.wav", "res://assets/library/audio/weapons/soviet/mosin_reload.tres")
	_convert_wav("res://assets/library/audio/weapons/soviet/ppsh_fire.wav", "res://assets/library/audio/weapons/soviet/ppsh_fire.tres")
	_convert_wav("res://assets/library/audio/weapons/soviet/ppsh_reload.wav", "res://assets/library/audio/weapons/soviet/ppsh_reload.tres")
	_convert_wav("res://assets/library/audio/weapons/dry_fire_click.wav", "res://assets/library/audio/weapons/dry_fire_click.tres")
	
	# Also test loading bullet_impact_masonry.mp3
	_convert_mp3("res://assets/library/audio/impacts/bullet_impact_masonry.mp3", "res://assets/library/audio/impacts/bullet_impact_masonry.tres")
	
	print("Audio conversion completed successfully.")
	quit(0)

func _convert_wav(wav_path: String, out_tres: String) -> void:
	var global_path := ProjectSettings.globalize_path(wav_path)
	var file := FileAccess.open(global_path, FileAccess.READ)
	if not file:
		print("Failed to open %s" % wav_path)
		return
	var bytes := file.get_buffer(file.get_length())
	file.close()
	
	# Parse simple RIFF WAV header
	var channels: int = bytes.decode_u16(22)
	var sample_rate: int = bytes.decode_u32(24)
	var bits_per_sample: int = bytes.decode_u16(34)
	
	# Find "data" chunk
	var data_offset := 36
	for i in range(12, bytes.size() - 8):
		if bytes[i] == 100 and bytes[i+1] == 97 and bytes[i+2] == 116 and bytes[i+3] == 97: # 'data'
			data_offset = i + 8
			break
	
	var pcm := bytes.slice(data_offset)
	
	var stream := AudioStreamWAV.new()
	stream.stereo = (channels == 2)
	stream.mix_rate = sample_rate
	stream.format = AudioStreamWAV.FORMAT_16_BITS if bits_per_sample == 16 else AudioStreamWAV.FORMAT_8_BITS
	stream.data = pcm
	
	var err := ResourceSaver.save(stream, out_tres)
	print("Saved %s -> %s (rate=%d, ch=%d, bits=%d, err=%d)" % [wav_path, out_tres, sample_rate, channels, bits_per_sample, err])

func _convert_mp3(mp3_path: String, out_tres: String) -> void:
	var global_path := ProjectSettings.globalize_path(mp3_path)
	var file := FileAccess.open(global_path, FileAccess.READ)
	if not file:
		print("Failed to open %s" % mp3_path)
		return
	var bytes := file.get_buffer(file.get_length())
	file.close()
	
	var stream := AudioStreamMP3.new()
	stream.data = bytes
	var err := ResourceSaver.save(stream, out_tres)
	print("Saved %s -> %s (bytes=%d, err=%d)" % [mp3_path, out_tres, bytes.size(), err])
