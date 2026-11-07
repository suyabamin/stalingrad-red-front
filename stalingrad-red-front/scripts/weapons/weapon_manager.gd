extends Node
class_name WeaponManager
## Owns the player's two weapon instances, switching, cooldown, ADS and recoil.

signal weapon_state_changed(weapon_name: String, magazine_ammo: int, magazine_capacity: int, reserve_ammo: int, reloading: bool)

const MOSIN_SCENE: PackedScene = preload("res://scenes/weapons/mosin_nagant.tscn")
const PPSH_SCENE: PackedScene = preload("res://scenes/weapons/ppsh_41.tscn")
const WEAPON_POSITION := Vector3(0.22, -0.22, -0.38)
const ADS_POSITION := Vector3(0.055, -0.16, -0.30)

@export_range(1.0, 30.0, 0.5) var sway_speed: float = 10.0
@export_range(0.0, 0.05, 0.001) var sway_amount: float = 0.008
@export_range(0.01, 1.0, 0.01) var ads_transition_speed: float = 12.0
@export_range(0.01, 1.0, 0.01) var recoil_recovery_speed: float = 8.0

var current_weapon: WeaponBase
var _camera: Camera3D
var _player: PlayerController
var _reload_timer: Timer
var _reloading_weapon: WeaponBase
var _sway_time: float = 0.0
var _recoil_offset: float = 0.0
var _base_fov: float = 80.0
var _weapons: Dictionary = {}

func _ready() -> void:
	_player = get_parent() as PlayerController
	_camera = _player.get_node("Head/Camera3D") as Camera3D
	_base_fov = _camera.fov
	_reload_timer = Timer.new()
	_reload_timer.one_shot = true
	_reload_timer.timeout.connect(_on_reload_timeout)
	add_child(_reload_timer)
	_add_weapon("Mosin-Nagant", MOSIN_SCENE)
	_add_weapon("PPSH-41", PPSH_SCENE)
	switch_weapon(1)

func _unhandled_input(event: InputEvent) -> void:
	if _player == null or _player.is_dead:
		return
	if event.is_action_pressed("weapon_1"):
		switch_weapon(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("weapon_2"):
		switch_weapon(2)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("reload"):
		_start_reload()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if current_weapon == null or _player == null:
		return
	current_weapon.fire_cooldown = maxf(0.0, current_weapon.fire_cooldown - delta)
	if not _player.is_dead and not current_weapon.is_reloading and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var trigger_down: bool = Input.is_action_pressed("fire") if current_weapon.data.automatic else Input.is_action_just_pressed("fire")
		if trigger_down and current_weapon.fire_cooldown <= 0.0:
			_fire_current_weapon()
		_update_aim_and_sway(delta)
	else:
		_camera.fov = lerpf(_camera.fov, _base_fov, clampf(delta * ads_transition_speed, 0.0, 1.0))
		_recoil_offset = move_toward(_recoil_offset, 0.0, recoil_recovery_speed * delta)
		_camera.rotation.x = _recoil_offset
		current_weapon.position = current_weapon.position.lerp(WEAPON_POSITION, clampf(delta * ads_transition_speed, 0.0, 1.0))

func switch_weapon(slot: int) -> void:
	var weapon_name: String = "Mosin-Nagant" if slot == 1 else "PPSH-41" if slot == 2 else ""
	if weapon_name.is_empty() or not _weapons.has(weapon_name):
		return
	if current_weapon != null:
		current_weapon.visible = false
	current_weapon = _weapons[weapon_name] as WeaponBase
	current_weapon.visible = true
	current_weapon.position = WEAPON_POSITION
	current_weapon.configure(_camera, _player)
	current_weapon.emit_current_state()
	_emit_weapon_state(current_weapon.data.weapon_name, current_weapon.magazine_ammo, current_weapon.data.magazine_capacity, current_weapon.reserve_ammo, current_weapon.is_reloading)

func _add_weapon(weapon_name: String, scene: PackedScene) -> void:
	var instance: WeaponBase = scene.instantiate() as WeaponBase
	if instance == null:
		push_error("Weapon scene '%s' root must use WeaponBase." % weapon_name)
		return
	_camera.add_child(instance)
	instance.name = weapon_name.replace("-", "")
	instance.visible = false
	instance.position = WEAPON_POSITION
	instance.configure(_camera, _player)
	instance.state_changed.connect(_on_weapon_state_changed)
	instance.shot_fired.connect(_on_shot_fired)
	_weapons[weapon_name] = instance

func _fire_current_weapon() -> void:
	if current_weapon.magazine_ammo <= 0:
		current_weapon.play_empty_sound()
		current_weapon.fire_cooldown = 0.25
		return
	if current_weapon.fire():
		current_weapon.fire_cooldown = 1.0 / current_weapon.data.rounds_per_second

func _start_reload() -> void:
	if _reload_timer.is_stopped() and current_weapon.begin_reload():
		_reloading_weapon = current_weapon
		_reload_timer.start(current_weapon.data.reload_duration)

func _on_reload_timeout() -> void:
	if _reloading_weapon != null:
		_reloading_weapon.finish_reload()
		_reloading_weapon = null

func _update_aim_and_sway(delta: float) -> void:
	var aiming: bool = Input.is_action_pressed("aim")
	var ads_fov: float = current_weapon.data.ads_fov if aiming else _base_fov
	_camera.fov = lerpf(_camera.fov, ads_fov, clampf(delta * ads_transition_speed, 0.0, 1.0))
	var target_position: Vector3 = ADS_POSITION if aiming else WEAPON_POSITION
	_sway_time += delta * sway_speed
	var moving: bool = Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
	var sway: Vector3 = Vector3(sin(_sway_time) * sway_amount, absf(cos(_sway_time)) * sway_amount, 0.0) if moving else Vector3.ZERO
	current_weapon.position = current_weapon.position.lerp(target_position + sway, clampf(delta * ads_transition_speed, 0.0, 1.0))
	_recoil_offset = move_toward(_recoil_offset, 0.0, recoil_recovery_speed * delta)
	_camera.rotation.x = _recoil_offset

func _on_shot_fired(strength: float) -> void:
	_recoil_offset = clampf(_recoil_offset + strength, 0.0, 0.12)
	_camera.rotation.x = _recoil_offset

func publish_current_state() -> void:
	if current_weapon != null:
		_emit_weapon_state(current_weapon.data.weapon_name, current_weapon.magazine_ammo, current_weapon.data.magazine_capacity, current_weapon.reserve_ammo, current_weapon.is_reloading)

func _on_weapon_state_changed(weapon_name: String, magazine_ammo: int, capacity: int, reserve: int, reloading: bool) -> void:
	if current_weapon != null and weapon_name == current_weapon.data.weapon_name:
		_emit_weapon_state(weapon_name, magazine_ammo, capacity, reserve, reloading)

func _emit_weapon_state(weapon_name: String, magazine_ammo: int, capacity: int, reserve: int, reloading: bool) -> void:
	weapon_state_changed.emit(weapon_name, magazine_ammo, capacity, reserve, reloading)
