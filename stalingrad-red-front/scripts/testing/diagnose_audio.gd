extends SceneTree

func _initialize() -> void:
	call_deferred("_diagnose")

func _diagnose() -> void:
	print("=== AUDIO SYSTEM DIAGNOSTIC ===")
	
	# 1. Inspect AudioServer and Buses
	var bus_count := AudioServer.bus_count
	print("AudioServer bus count: %d" % bus_count)
	for i in range(bus_count):
		print("  Bus %d: '%s' vol=%.1fdB mute=%s send='%s'" % [
			i,
			AudioServer.get_bus_name(i),
			AudioServer.get_bus_volume_db(i),
			AudioServer.is_bus_mute(i),
			AudioServer.get_bus_send(i)
		])
	
	# 2. Inspect Player and AudioListener3D
	var packed_player := load("res://scenes/player/player.tscn") as PackedScene
	var player := packed_player.instantiate() as Node3D
	root.add_child(player)
	
	var vp := root
	print("Viewport is_audio_listener_3d: %s" % vp.is_audio_listener_3d())
	
	var listener := player.find_child("*Listener*", true, false)
	print("Player has AudioListener3D: %s" % (listener != null))
	if listener != null:
		print("  Listener current: %s" % listener.get("current"))
	
	# 3. Inspect WeaponData resources
	var mosin_data: WeaponData = load("res://resources/weapons/mosin_nagant.tres")
	print("Mosin data: fire_sound=%s reload_sound=%s empty_sound=%s" % [
		mosin_data.fire_sound, mosin_data.reload_sound, mosin_data.empty_sound
	])
	var ppsh_data: WeaponData = load("res://resources/weapons/ppsh_41.tres")
	print("PPSH data: fire_sound=%s reload_sound=%s empty_sound=%s" % [
		ppsh_data.fire_sound, ppsh_data.reload_sound, ppsh_data.empty_sound
	])
	
	# 4. Inspect Main scene audio components
	var packed_main := load("res://scenes/main/main.tscn") as PackedScene
	var main := packed_main.instantiate() as Node3D
	root.add_child(main)
	await process_frame
	
	var soundscape := main.get_node_or_null("Soundscape")
	print("Soundscape node present: %s" % (soundscape != null))
	if soundscape:
		var wind: AudioStreamPlayer = soundscape.get_node_or_null("WindBed")
		var art: AudioStreamPlayer3D = soundscape.get_node_or_null("DistantArtillery")
		var bat: AudioStreamPlayer3D = soundscape.get_node_or_null("DistantBattlefield")
		print("  WindBed: stream=%s playing=%s bus=%s vol=%.1f" % [wind.stream != null, wind.playing, wind.bus, wind.volume_db])
		print("  Artillery: stream=%s playing=%s bus=%s vol=%.1f max_dist=%.1f" % [art.stream != null, art.playing, art.bus, art.volume_db, art.max_distance])
		print("  Battlefield: stream=%s playing=%s bus=%s vol=%.1f max_dist=%.1f" % [bat.stream != null, bat.playing, bat.bus, bat.volume_db, bat.max_distance])
		
		# Check waveform amplitudes in wind_ambient.wav
		if wind.stream is AudioStreamWAV:
			var wav: AudioStreamWAV = wind.stream
			var data := wav.data
			var max_amp := 0
			for p in range(0, mini(data.size(), 20000), 2):
				var s := data.decode_s16(p)
				if abs(s) > max_amp:
					max_amp = abs(s)
			print("  WindBed WAV sample peak (first 10k samples): %d / 32767 (%.1f dBFS)" % [
				max_amp,
				20.0 * log(float(max_amp) / 32767.0) / log(10.0) if max_amp > 0 else -100.0
			])
	
	quit()
