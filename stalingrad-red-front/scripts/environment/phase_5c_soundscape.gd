extends Node3D
class_name Phase5CSoundscape
## Phase 5C environmental soundscape controller.
## Manages wind ambience bed and sparse distant combat rumblings on the Environment bus.
## Presentation-only, clean lifecycle, no impact on weapon SFX.

@onready var wind_player: AudioStreamPlayer = $WindBed
@onready var artillery_player: AudioStreamPlayer3D = $DistantArtillery
@onready var battlefield_player: AudioStreamPlayer3D = $DistantBattlefield

var _artillery_timer: float = 0.0
var _battlefield_timer: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	if not GameManager.pause_changed.is_connected(_on_pause_changed):
		GameManager.pause_changed.connect(_on_pause_changed)
	_artillery_timer = _rng.randf_range(2.0, 5.0)
	_battlefield_timer = _rng.randf_range(7.0, 14.0)
	
	if is_instance_valid(wind_player):
		if wind_player.stream is AudioStreamWAV:
			var wind_stream := wind_player.stream as AudioStreamWAV
			var bytes_per_sample := 2 if wind_stream.format == AudioStreamWAV.FORMAT_16_BITS else 1
			var channels := 2 if wind_stream.stereo else 1
			wind_stream.loop_begin = 0
			wind_stream.loop_end = wind_stream.data.size() / (bytes_per_sample * channels)
			wind_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		if not wind_player.playing:
			wind_player.play()

func _on_pause_changed(is_paused: bool) -> void:
	if not is_paused and is_instance_valid(wind_player) and wind_player.stream != null and not wind_player.playing:
		wind_player.play()

func _process(delta: float) -> void:
	_artillery_timer -= delta
	if _artillery_timer <= 0.0:
		_artillery_timer = _rng.randf_range(16.0, 28.0)
		if is_instance_valid(artillery_player) and not artillery_player.playing:
			artillery_player.play()
			
	_battlefield_timer -= delta
	if _battlefield_timer <= 0.0:
		_battlefield_timer = _rng.randf_range(20.0, 36.0)
		if is_instance_valid(battlefield_player) and not battlefield_player.playing:
			battlefield_player.play()

func stop_all() -> void:
	if is_instance_valid(wind_player): wind_player.stop()
	if is_instance_valid(artillery_player): artillery_player.stop()
	if is_instance_valid(battlefield_player): battlefield_player.stop()

func _exit_tree() -> void:
	stop_all()
