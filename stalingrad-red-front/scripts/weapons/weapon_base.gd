extends Node3D
class_name WeaponBase
## Reusable weapon state and camera-centered hitscan implementation.

signal state_changed(weapon_name: String, magazine_ammo: int, magazine_capacity: int, reserve_ammo: int, reloading: bool)
signal shot_fired(recoil_strength: float)

@export var data: WeaponData

var magazine_ammo: int = 0
var reserve_ammo: int = 0
var is_reloading: bool = false
var fire_cooldown: float = 0.0
var _camera: Camera3D
var _shooter: CharacterBody3D
var _audio_players: Dictionary = {}

func _ready() -> void:
	if data == null:
		push_error("WeaponBase requires a WeaponData resource.")
		return
	magazine_ammo = mini(data.magazine_capacity, data.starting_magazine_ammo)
	reserve_ammo = data.starting_reserve_ammo
	_build_placeholder_model()
	_create_audio_players()

func configure(camera: Camera3D, shooter: CharacterBody3D) -> void:
	_camera = camera
	_shooter = shooter

func fire() -> bool:
	if data == null or _camera == null or _shooter == null or is_reloading or magazine_ammo <= 0:
		return false
	magazine_ammo -= 1
	_play_sound("fire")
	_perform_hitscan()
	# Resolve the shot from the current aim before the recoil signal moves the camera.
	shot_fired.emit(data.recoil_strength)
	_emit_state()
	return true

func begin_reload() -> bool:
	if data == null or is_reloading or magazine_ammo >= data.magazine_capacity or reserve_ammo <= 0:
		return false
	is_reloading = true
	_play_sound("reload")
	_emit_state()
	return true

func finish_reload() -> void:
	if data == null or not is_reloading:
		return
	var needed: int = data.magazine_capacity - magazine_ammo
	var transferred: int = mini(needed, reserve_ammo)
	magazine_ammo += transferred
	reserve_ammo -= transferred
	is_reloading = false
	_emit_state()

func play_empty_sound() -> void:
	_play_sound("empty")

func emit_current_state() -> void:
	_emit_state()

func _perform_hitscan() -> void:
	var origin: Vector3 = _camera.global_position
	var direction: Vector3 = -_camera.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * data.maximum_range)
	query.exclude = [_shooter.get_rid()]
	query.collision_mask = 0xFFFFFFFF
	var hit: Dictionary = _camera.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var collider: Object = hit.get("collider") as Object
	if collider == null or collider == _shooter:
		return
	if collider.has_method("apply_damage"):
		collider.call("apply_damage", data.damage)
	_spawn_impact(hit.get("position", Vector3.ZERO))
	_play_sound("impact")

func _build_placeholder_model() -> void:
	var metal := _make_material(Color(0.19, 0.20, 0.19))
	var wood := _make_material(Color(0.28, 0.20, 0.13))
	_add_box("Receiver", Vector3(0.11, 0.12, 0.28), Vector3(0.0, 0.0, 0.0), metal)
	_add_box("Stock", Vector3(0.09, 0.105, 0.22), Vector3(0.0, -0.01, 0.23), wood)
	_add_cylinder("Barrel", 0.018, 0.43, Vector3(0.0, 0.01, -0.34), metal)
	_add_box("Grip", Vector3(0.055, 0.13, 0.06), Vector3(0.0, -0.11, 0.03), wood)
	if data != null and data.automatic:
		_add_cylinder("DrumMagazine", 0.075, 0.065, Vector3(0.0, -0.13, -0.01), metal)
		_add_box("FrontSight", Vector3(0.055, 0.035, 0.045), Vector3(0.0, 0.035, -0.29), metal)
	else:
		_add_box("WoodForegrip", Vector3(0.075, 0.07, 0.22), Vector3(0.0, -0.025, -0.22), wood)
		_add_box("RearSight", Vector3(0.035, 0.04, 0.05), Vector3(0.0, 0.075, -0.07), metal)

func _add_box(label: String, size: Vector3, local_position: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	instance.name = label
	var box := BoxMesh.new()
	box.size = size
	instance.mesh = box
	instance.material_override = material
	instance.position = local_position
	add_child(instance)

func _add_cylinder(label: String, radius: float, height: float, local_position: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	instance.name = label
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	instance.mesh = cylinder
	instance.material_override = material
	instance.position = local_position
	instance.rotation.x = PI * 0.5
	add_child(instance)

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material

func _spawn_impact(position: Vector3) -> void:
	var marker := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.045
	mesh.height = 0.09
	marker.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.85, 0.42, 0.18)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	marker.material_override = material
	get_tree().current_scene.add_child(marker)
	marker.global_position = position
	var cleanup := Timer.new()
	cleanup.one_shot = true
	cleanup.wait_time = 1.5
	marker.add_child(cleanup)
	cleanup.timeout.connect(marker.queue_free)
	cleanup.start()

func _create_audio_players() -> void:
	for sound_name in ["fire", "reload", "empty", "impact"]:
		var player := AudioStreamPlayer3D.new()
		player.name = "%sAudio" % sound_name.capitalize()
		add_child(player)
		_audio_players[sound_name] = player

func _play_sound(sound_name: String) -> void:
	if data == null or not _audio_players.has(sound_name):
		return
	var stream: AudioStream
	match sound_name:
		"fire": stream = data.fire_sound
		"reload": stream = data.reload_sound
		"empty": stream = data.empty_sound
		"impact": stream = data.impact_sound
		_: return
	if stream != null:
		var player: AudioStreamPlayer3D = _audio_players[sound_name]
		player.stream = stream
		player.play()

func _emit_state() -> void:
	if data != null:
		state_changed.emit(data.weapon_name, magazine_ammo, data.magazine_capacity, reserve_ammo, is_reloading)
