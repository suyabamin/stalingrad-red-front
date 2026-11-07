extends CharacterBody3D
class_name EnemyController
## Minimal navigation foundation. This actor follows one configured target and has no combat AI.

signal animation_state_changed(state: StringName)

enum AnimationState { IDLE, WALKING, RUNNING, HIT, DEATH }

@export var navigation_target_path: NodePath
@export_range(0.1, 8.0, 0.1) var move_speed: float = 2.2
@export_range(0.1, 10.0, 0.1) var running_speed: float = 3.5
@export_range(0.1, 3.0, 0.05) var stopping_distance: float = 0.8
@export_range(0.1, 2.0, 0.05) var hit_state_duration: float = 0.35

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var health: EnemyHealth = $Health
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_dead: bool = false
var _navigation_target: Node3D
var _animation_state: AnimationState = AnimationState.IDLE
var _hit_state_timer: float = 0.0
var _last_target_position: Vector3 = Vector3.INF

func _ready() -> void:
	navigation_agent.path_desired_distance = stopping_distance
	navigation_agent.target_desired_distance = stopping_distance
	navigation_agent.max_speed = running_speed
	navigation_agent.avoidance_enabled = true
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	health.died.connect(_on_died)
	_navigation_target = get_node_or_null(navigation_target_path) as Node3D
	animation_player.add_animation_library(&"", _build_placeholder_animations())
	_set_animation_state(AnimationState.IDLE)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if _hit_state_timer > 0.0:
		_hit_state_timer = maxf(0.0, _hit_state_timer - delta)
		if _hit_state_timer == 0.0:
			_update_movement_animation()
	if not is_instance_valid(_navigation_target):
		_stop_movement()
		return

	var navigation_map: RID = navigation_agent.get_navigation_map()
	if not navigation_map.is_valid() or NavigationServer3D.map_get_iteration_id(navigation_map) == 0:
		_stop_movement()
		return

	var target_position: Vector3 = _navigation_target.global_position
	if _last_target_position.distance_squared_to(target_position) > 0.01:
		navigation_agent.target_position = target_position
		_last_target_position = target_position
	if navigation_agent.is_navigation_finished():
		_stop_movement()
		_update_movement_animation()
		return

	var next_position: Vector3 = navigation_agent.get_next_path_position()
	var planar_direction: Vector3 = next_position - global_position
	planar_direction.y = 0.0
	var desired_speed: float = running_speed if global_position.distance_to(_navigation_target.global_position) > 7.0 else move_speed
	if planar_direction.length_squared() <= 0.0001:
		velocity = Vector3.ZERO
	else:
		planar_direction = planar_direction.normalized()
		velocity = planar_direction * desired_speed
		rotation.y = lerp_angle(rotation.y, atan2(-planar_direction.x, -planar_direction.z), delta * 7.0)
	navigation_agent.set_velocity(velocity)

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
	velocity = Vector3.ZERO
	navigation_agent.set_velocity(Vector3.ZERO)
	navigation_agent.avoidance_enabled = false
	navigation_agent.target_position = global_position
	collision_shape.set_deferred("disabled", true)
	_set_animation_state(AnimationState.DEATH)

func _update_movement_animation() -> void:
	if is_dead or _hit_state_timer > 0.0:
		return
	var horizontal_speed: float = Vector2(velocity.x, velocity.z).length()
	if horizontal_speed < 0.1:
		_set_animation_state(AnimationState.IDLE)
	elif horizontal_speed > (move_speed + running_speed) * 0.5:
		_set_animation_state(AnimationState.RUNNING)
	else:
		_set_animation_state(AnimationState.WALKING)

func _set_animation_state(state: AnimationState) -> void:
	if _animation_state == state and animation_player.is_playing():
		return
	_animation_state = state
	var animation_name: StringName
	match state:
		AnimationState.IDLE: animation_name = &"idle"
		AnimationState.WALKING: animation_name = &"walking"
		AnimationState.RUNNING: animation_name = &"running"
		AnimationState.HIT: animation_name = &"hit"
		AnimationState.DEATH: animation_name = &"death"
	animation_player.play(animation_name)
	animation_state_changed.emit(animation_name)

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
	var position_track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(position_track, NodePath("Visual:position"))
	animation.track_insert_key(position_track, 0.0, Vector3.ZERO)
	if looping and bob_height > 0.0:
		animation.track_insert_key(position_track, duration * 0.5, Vector3(0.0, bob_height, 0.0))
		animation.track_insert_key(position_track, duration, Vector3.ZERO)
	var rotation_track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(rotation_track, NodePath("Visual:rotation"))
	animation.track_insert_key(rotation_track, 0.0, Vector3.ZERO)
	if not looping and tilt != 0.0:
		var final_rotation: Vector3 = Vector3(tilt, 0.0, 0.0) if animation_name == &"hit" else Vector3(0.0, 0.0, tilt)
		animation.track_insert_key(rotation_track, duration * 0.45, final_rotation)
		animation.track_insert_key(rotation_track, duration, Vector3.ZERO if animation_name == &"hit" else final_rotation)
	library.add_animation(animation_name, animation)
