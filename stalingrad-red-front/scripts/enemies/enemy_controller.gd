extends CharacterBody3D
class_name EnemyController
## Reusable infantry detection, navigation, firing and ammunition state.

signal animation_state_changed(state: StringName)
signal combat_state_changed(state: StringName)

enum AnimationState { IDLE, WALKING, RUNNING, HIT, DEATH }
enum CombatState { IDLE, INVESTIGATE, CHASE, ATTACK, RELOAD, DEAD }

@export_range(1.0, 60.0, 0.5) var detection_range: float = 22.0
@export_range(1.0, 60.0, 0.5) var attack_range: float = 14.0
@export_range(1.0, 80.0, 0.5) var lose_target_range: float = 30.0
@export_range(0.1, 8.0, 0.1) var move_speed: float = 2.2
@export_range(0.1, 10.0, 0.1) var running_speed: float = 3.5
@export_range(0.1, 3.0, 0.05) var stopping_distance: float = 0.8
@export_range(0.1, 2.0, 0.05) var rotation_speed: float = 5.0
@export_range(1, 100, 1) var magazine_capacity: int = 5
@export_range(0, 500, 1) var reserve_ammunition: int = 25
@export_range(0.1, 10.0, 0.1) var reload_duration: float = 2.4
@export_range(0.1, 5.0, 0.05) var fire_interval: float = 0.8
@export_range(1, 100, 1) var damage_per_shot: int = 12
@export_range(0.0, 0.25, 0.005) var accuracy_spread: float = 0.045
@export_range(0.05, 2.0, 0.05) var detection_update_interval: float = 0.25
@export_range(0.5, 20.0, 0.5) var investigation_duration: float = 5.0
@export var navigation_target_path: NodePath
@export_range(0.1, 2.0, 0.05) var hit_state_duration: float = 0.35

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health: EnemyHealth = $Health
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visual_root: Node3D = $Visual

var is_dead: bool = false
var combat_state: CombatState = CombatState.IDLE
var magazine_ammunition: int
var _player: Node3D
var _player_health: Node
var _last_known_position: Vector3
var _detection_timer: float = 0.0
var _fire_timer: float = 0.0
var _reload_timer: float = 0.0
var _investigation_timer: float = 0.0
var _hit_state_timer: float = 0.0
var _has_sight: bool = false
var _animation_state: AnimationState = AnimationState.IDLE
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	magazine_capacity = maxi(1, magazine_capacity)
	magazine_ammunition = magazine_capacity
	navigation_agent.path_desired_distance = stopping_distance
	navigation_agent.target_desired_distance = stopping_distance
	navigation_agent.max_speed = running_speed
	navigation_agent.avoidance_enabled = true
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	health.died.connect(_on_died)
	_rng.randomize()
	animation_player.add_animation_library(&"", _build_placeholder_animations())
	_find_player()
	_set_animation_state(AnimationState.IDLE)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if _hit_state_timer > 0.0:
		_hit_state_timer = maxf(0.0, _hit_state_timer - delta)
	if is_instance_valid(_player) and is_instance_valid(_player_health) and _player_health.get("is_dead"):
		_set_combat_state(CombatState.IDLE)
		_stop_movement()
		return
	_detection_timer -= delta
	if _detection_timer <= 0.0:
		_detection_timer = detection_update_interval
		_update_detection()
	match combat_state:
		CombatState.IDLE:
			_stop_movement()
		CombatState.INVESTIGATE:
			_investigation_timer -= delta
			_move_to(_last_known_position, delta)
			if _has_sight and _distance_to_player() <= lose_target_range:
				_set_combat_state(CombatState.ATTACK if _distance_to_player() <= attack_range else CombatState.CHASE)
			elif _investigation_timer <= 0.0 or global_position.distance_to(_last_known_position) <= stopping_distance:
				_set_combat_state(CombatState.IDLE)
		CombatState.CHASE:
			if not is_instance_valid(_player):
				_set_combat_state(CombatState.INVESTIGATE)
				return
			_last_known_position = _player.global_position
			if _distance_to_player() <= attack_range and _has_sight:
				_set_combat_state(CombatState.ATTACK)
			elif _distance_to_player() > lose_target_range or not _has_sight:
				_set_combat_state(CombatState.INVESTIGATE)
			else:
				_move_to(_player.global_position, delta)
		CombatState.ATTACK:
			_stop_movement()
			if not is_instance_valid(_player) or _distance_to_player() > lose_target_range:
				_set_combat_state(CombatState.INVESTIGATE)
			elif _distance_to_player() > attack_range or not _has_sight:
				_set_combat_state(CombatState.CHASE)
			else:
				_face_player(delta)
				_fire_timer -= delta
				if magazine_ammunition <= 0:
					if reserve_ammunition > 0:
						_begin_reload()
				else:
					if _fire_timer <= 0.0:
						_fire_at_player()
		CombatState.RELOAD:
			_stop_movement()
			_reload_timer -= delta
			if _reload_timer <= 0.0:
				var transfer := mini(magazine_capacity - magazine_ammunition, reserve_ammunition)
				magazine_ammunition += transfer
				reserve_ammunition -= transfer
			if _reload_timer <= 0.0:
				if _target_valid() and _has_sight:
					_set_combat_state(CombatState.ATTACK if _distance_to_player() <= attack_range else CombatState.CHASE)
				else:
					_set_combat_state(CombatState.INVESTIGATE if _target_valid() else CombatState.IDLE)
	_update_movement_animation()

func _find_player() -> void:
	_player = GameManager.current_player as Node3D
	if is_instance_valid(_player):
		_player_health = _player.get_node_or_null("Health")
	if not is_instance_valid(_player) and not navigation_target_path.is_empty():
		_player = get_node_or_null(navigation_target_path) as Node3D
		if is_instance_valid(_player):
			_player_health = _player.get_node_or_null("Health")

func _update_detection() -> void:
	if not is_instance_valid(_player):
		_find_player()
	if not is_instance_valid(_player):
		return
	var distance := _distance_to_player()
	_has_sight = distance <= lose_target_range and _has_line_of_sight()
	if distance <= detection_range and _has_sight:
		_last_known_position = _player.global_position
		if combat_state == CombatState.RELOAD:
			return
		_set_combat_state(CombatState.ATTACK if distance <= attack_range else CombatState.CHASE)
	elif combat_state == CombatState.IDLE and distance <= detection_range:
		_last_known_position = _player.global_position
		_investigation_timer = investigation_duration
		_set_combat_state(CombatState.INVESTIGATE)

func _target_valid() -> bool:
	return is_instance_valid(_player) and is_instance_valid(_player_health) and not bool(_player_health.get("is_dead"))

func _distance_to_player() -> float:
	return global_position.distance_to(_player.global_position) if is_instance_valid(_player) else INF

func _has_line_of_sight() -> bool:
	if not _target_valid():
		return false
	var origin := global_position + Vector3.UP * 1.35
	var target := _player.global_position + Vector3.UP * 1.1
	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [get_rid()]
	query.collision_mask = 0xFFFFFFFF
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.get("collider") == _player

func _move_to(destination: Vector3, delta: float) -> void:
	var map := navigation_agent.get_navigation_map()
	if not map.is_valid() or NavigationServer3D.map_get_iteration_id(map) == 0:
		_stop_movement()
		return
	if navigation_agent.target_position.distance_squared_to(destination) > 0.25:
		navigation_agent.target_position = destination
	if navigation_agent.is_navigation_finished():
		_stop_movement()
		return
	var direction := navigation_agent.get_next_path_position() - global_position
	direction.y = 0.0
	if direction.length_squared() < 0.0001:
		_stop_movement()
		return
	direction = direction.normalized()
	velocity = direction * (running_speed if combat_state == CombatState.CHASE else move_speed)
	_face_direction(direction, delta)
	navigation_agent.set_velocity(velocity)

func _face_player(delta: float) -> void:
	if not is_instance_valid(_player):
		return
	var direction := _player.global_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.001:
		_face_direction(direction.normalized(), delta)

func _face_direction(direction: Vector3, delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), rotation_speed * delta)

func _fire_at_player() -> void:
	if not _target_valid() or not _has_line_of_sight():
		return
	magazine_ammunition -= 1
	_fire_timer = fire_interval
	var origin := global_position + Vector3.UP * 1.35
	var direction := (_player.global_position + Vector3.UP * 1.1 - origin).normalized()
	direction += Vector3(_rng.randf_range(-accuracy_spread, accuracy_spread), _rng.randf_range(-accuracy_spread, accuracy_spread), _rng.randf_range(-accuracy_spread, accuracy_spread))
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction.normalized() * attack_range)
	query.exclude = [get_rid()]
	query.collision_mask = 0xFFFFFFFF
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.get("collider") == _player and _target_valid():
		_player_health.call("apply_damage", damage_per_shot)
	if magazine_ammunition == 0 and reserve_ammunition > 0:
		_begin_reload()

func _begin_reload() -> void:
	_reload_timer = reload_duration
	_set_combat_state(CombatState.RELOAD)

func _set_combat_state(value: CombatState) -> void:
	if combat_state == value:
		return
	combat_state = value
	var names: Array[StringName] = [&"idle", &"investigate", &"chase", &"attack", &"reload", &"dead"]
	combat_state_changed.emit(names[value])

func apply_damage(amount: int) -> void:
	if is_dead:
		return
	health.apply_damage(amount)
	if not is_dead and amount > 0:
		_hit_state_timer = hit_state_duration
		_set_animation_state(AnimationState.HIT)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	if is_dead:
		return
	velocity = safe_velocity
	move_and_slide()
	_update_movement_animation()

func _stop_movement() -> void:
	velocity = Vector3.ZERO
	navigation_agent.set_velocity(Vector3.ZERO)
	move_and_slide()

func _on_died() -> void:
	if is_dead:
		return
	is_dead = true
	_set_combat_state(CombatState.DEAD)
	velocity = Vector3.ZERO
	navigation_agent.set_velocity(Vector3.ZERO)
	navigation_agent.avoidance_enabled = false
	navigation_agent.target_position = global_position
	collision_shape.set_deferred("disabled", true)
	collision_layer = 0
	collision_mask = 0
	_set_animation_state(AnimationState.DEATH)

func _update_movement_animation() -> void:
	if is_dead or _hit_state_timer > 0.0:
		return
	var speed := Vector2(velocity.x, velocity.z).length()
	if speed < 0.1:
		_set_animation_state(AnimationState.IDLE)
	elif speed > (move_speed + running_speed) * 0.5:
		_set_animation_state(AnimationState.RUNNING)
	else:
		_set_animation_state(AnimationState.WALKING)

func _set_animation_state(state: AnimationState) -> void:
	if _animation_state == state and animation_player.is_playing():
		return
	_animation_state = state
	var names: Array[StringName] = [&"idle", &"walking", &"running", &"hit", &"death"]
	animation_player.play(names[state])
	animation_state_changed.emit(names[state])

func _build_placeholder_animations() -> AnimationLibrary:
	var library := AnimationLibrary.new()
	_add_visual_animation(library, &"idle", 1.6, 0.015, 0.0, true)
	_add_visual_animation(library, &"walking", 0.55, 0.04, 0.0, true)
	_add_visual_animation(library, &"running", 0.35, 0.07, 0.0, true)
	_add_visual_animation(library, &"hit", 0.22, 0.0, -0.12, false)
	_add_visual_animation(library, &"death", 0.8, 0.0, 1.35, false)
	return library

func _add_visual_animation(library: AnimationLibrary, animation_name: StringName, duration: float, bob_height: float, tilt: float, looping: bool) -> void:
	var animation := Animation.new()
	animation.length = duration
	animation.loop_mode = Animation.LOOP_LINEAR if looping else Animation.LOOP_NONE
	var position_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(position_track, NodePath("Visual:position"))
	var base_position := visual_root.position
	animation.track_insert_key(position_track, 0.0, base_position)
	if looping and bob_height > 0.0:
		animation.track_insert_key(position_track, duration * 0.5, base_position + Vector3(0.0, bob_height, 0.0))
		animation.track_insert_key(position_track, duration, base_position)
	var rotation_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(rotation_track, NodePath("Visual:rotation"))
	var base_rotation := visual_root.rotation
	animation.track_insert_key(rotation_track, 0.0, base_rotation)
	if not looping and tilt != 0.0:
		var rotation_offset := Vector3(tilt, 0.0, 0.0) if animation_name == &"hit" else Vector3(0.0, 0.0, tilt)
		var final_rotation := base_rotation + rotation_offset
		animation.track_insert_key(rotation_track, duration * 0.45, final_rotation)
		animation.track_insert_key(rotation_track, duration, base_rotation if animation_name == &"hit" else final_rotation)
	library.add_animation(animation_name, animation)
