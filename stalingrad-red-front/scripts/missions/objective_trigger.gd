extends Area3D
class_name ObjectiveTrigger
## Non-blocking area that completes its objective only when the player enters in sequence.

@export var objective_id: StringName
@export var marker_label: String = ""

var _player_inside: bool = false
var _consumed: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	MissionManager.objective_started.connect(_on_objective_started)
	_build_marker()

func _on_body_entered(body: Node3D) -> void:
	if not body is PlayerController:
		return
	_player_inside = true
	_try_complete()

func _on_body_exited(body: Node3D) -> void:
	if body is PlayerController:
		_player_inside = false

func _on_objective_started(_objective: ObjectiveDefinition, _number: int, _total: int) -> void:
	_try_complete()

func _try_complete() -> void:
	if not _player_inside or _consumed or MissionManager.mission_state != MissionManager.MissionState.ACTIVE:
		return
	var objective := MissionManager.get_current_objective()
	if objective == null or objective.objective_id != objective_id:
		return
	_consumed = MissionManager.complete_objective(objective_id)

func _build_marker() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.58, 0.45, 0.24)
	material.roughness = 1.0
	for side in [-1.0, 1.0]:
		_add_marker_box(Vector3(0.18, 2.25, 0.18), Vector3(side * 4.6, 1.125, 0.0), material)
	_add_marker_box(Vector3(9.38, 0.18, 0.18), Vector3(0.0, 2.34, 0.0), material)
	var label := Label3D.new()
	label.text = marker_label
	label.position = Vector3(0.0, 2.75, -0.1)
	label.font_size = 32
	label.pixel_size = 0.006
	label.modulate = Color(0.92, 0.79, 0.56)
	label.outline_size = 6
	add_child(label)

func _add_marker_box(size: Vector3, local_position: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.position = local_position
	add_child(mesh_instance)
