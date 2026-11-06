extends CharacterBody3D
class_name PlayerController
## First-person movement with acceleration, sprint, jumping and mouse look.

@export var walk_speed := 5.0
@export var sprint_speed := 8.0
@export var jump_velocity := 4.5
@export var acceleration := 18.0
@export var deceleration := 22.0
@export var mouse_sensitivity := 0.0025
@export var look_limit_degrees := 88.0

@onready var camera: Camera3D = $Head/Camera3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_pitch := 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.register_player(self)
	SettingsManager.sensitivity_changed.connect(_on_sensitivity_changed)
	mouse_sensitivity = SettingsManager.mouse_sensitivity

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		look_pitch = clampf(look_pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-look_limit_degrees), deg_to_rad(look_limit_degrees))
		$Head.rotation.x = look_pitch
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	var target_speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	var rate := acceleration if direction.length_squared() > 0.0 else deceleration
	velocity.x = move_toward(velocity.x, direction.x * target_speed, rate * delta)
	velocity.z = move_toward(velocity.z, direction.z * target_speed, rate * delta)
	move_and_slide()

func _on_sensitivity_changed(value: float) -> void:
	mouse_sensitivity = value
