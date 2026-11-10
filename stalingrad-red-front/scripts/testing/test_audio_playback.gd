extends Node

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	print("--- BEGIN AUDIO VALIDATION TEST ---")
	
	# 1. Verify Audio Bus Layout
	var bus_count: int = AudioServer.bus_count
	print("Total audio buses: %d" % bus_count)
	var env_bus_idx: int = AudioServer.get_bus_index("Environment")
	print("Environment bus index: %d (volume: %.1f dB)" % [env_bus_idx, AudioServer.get_bus_volume_db(env_bus_idx) if env_bus_idx >= 0 else -999.0])
	assert(env_bus_idx >= 0, "Environment bus missing!")
	
	# 2. Verify Mosin WeaponData
	var mosin: WeaponData = load("res://resources/weapons/mosin_nagant.tres")
	assert(mosin != null, "Mosin data failed to load")
	print("Mosin fire_sound: %s" % (mosin.fire_sound.resource_path if mosin.fire_sound else "NULL"))
	print("Mosin reload_sound: %s" % (mosin.reload_sound.resource_path if mosin.reload_sound else "NULL"))
	print("Mosin empty_sound: %s" % (mosin.empty_sound.resource_path if mosin.empty_sound else "NULL"))
	print("Mosin impact_sound: %s" % (mosin.impact_sound.resource_path if mosin.impact_sound else "NULL"))
	assert(mosin.fire_sound != null, "Mosin fire_sound is null")
	assert(mosin.reload_sound != null, "Mosin reload_sound is null")
	assert(mosin.reload_sound.get_length() <= 3.5, "Mosin reload clip still contains repeated cycles")
	assert(mosin.empty_sound != null, "Mosin empty_sound is null")
	assert(mosin.impact_sound != null, "Mosin impact_sound is null")
	
	# 3. Verify PPSH-41 WeaponData
	var ppsh: WeaponData = load("res://resources/weapons/ppsh_41.tres")
	assert(ppsh != null, "PPSH data failed to load")
	print("PPSH fire_sound: %s" % (ppsh.fire_sound.resource_path if ppsh.fire_sound else "NULL"))
	print("PPSH reload_sound: %s" % (ppsh.reload_sound.resource_path if ppsh.reload_sound else "NULL"))
	print("PPSH empty_sound: %s" % (ppsh.empty_sound.resource_path if ppsh.empty_sound else "NULL"))
	print("PPSH impact_sound: %s" % (ppsh.impact_sound.resource_path if ppsh.impact_sound else "NULL"))
	assert(ppsh.fire_sound != null, "PPSH fire_sound is null")
	assert(ppsh.reload_sound != null, "PPSH reload_sound is null")
	assert(ppsh.empty_sound != null, "PPSH empty_sound is null")
	assert(ppsh.impact_sound != null, "PPSH impact_sound is null")
	
	# 4. Verify Phase5CSoundscape Scene
	var soundscape_scene: PackedScene = load("res://scenes/environment/phase_5c_soundscape.tscn")
	var soundscape_inst: Node = soundscape_scene.instantiate()
	var wind_bed: AudioStreamPlayer = soundscape_inst.get_node_or_null("WindBed") as AudioStreamPlayer
	var dist_art: AudioStreamPlayer3D = soundscape_inst.get_node_or_null("DistantArtillery") as AudioStreamPlayer3D
	var dist_bat: AudioStreamPlayer3D = soundscape_inst.get_node_or_null("DistantBattlefield") as AudioStreamPlayer3D
	
	print("WindBed stream: %s (bus: %s, vol: %.1f dB)" % [wind_bed.stream.resource_path if wind_bed and wind_bed.stream else "NULL", wind_bed.bus if wind_bed else "NULL", wind_bed.volume_db if wind_bed else 0.0])
	print("DistantArtillery stream: %s (bus: %s, vol: %.1f dB)" % [dist_art.stream.resource_path if dist_art and dist_art.stream else "NULL", dist_art.bus if dist_art else "NULL", dist_art.volume_db if dist_art else 0.0])
	print("DistantBattlefield stream: %s (bus: %s, vol: %.1f dB)" % [dist_bat.stream.resource_path if dist_bat and dist_bat.stream else "NULL", dist_bat.bus if dist_bat else "NULL", dist_bat.volume_db if dist_bat else 0.0])
	
	assert(wind_bed != null and wind_bed.stream != null, "WindBed missing or stream null")
	assert(dist_art != null and dist_art.stream != null, "DistantArtillery missing or stream null")
	assert(dist_bat != null and dist_bat.stream != null, "DistantBattlefield missing or stream null")
	soundscape_inst.free()
	
	print("--- AUDIO VALIDATION TEST PASSED SUCCESSFULLY ---")
	get_tree().quit(0)
