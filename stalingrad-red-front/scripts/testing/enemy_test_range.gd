extends Node3D
## Builds a compact obstacle course and its low-cost navigation map.

@onready var enemy: EnemyController = $Enemy
var status_label: Label

func _ready() -> void:
	_build_test_geometry()
	_build_navigation()
	_build_status_display()
	enemy.health.health_changed.connect(_on_enemy_health_changed)
	enemy.health.died.connect(_on_enemy_died)
	_on_enemy_health_changed(enemy.health.current_health, enemy.health.maximum_health)

func _build_status_display() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	status_label = Label.new()
	status_label.position = Vector2(20.0, 20.0)
	status_label.add_theme_font_size_override("font_size", 20)
	layer.add_child(status_label)

func _on_enemy_health_changed(current: int, maximum: int) -> void:
	status_label.text = "ENEMY  %d / %d   |   Fire to test damage and death" % [current, maximum]

func _on_enemy_died() -> void:
	status_label.text = "ENEMY DEFEATED   |   Death confirmed"

func _build_test_geometry() -> void:
	var floor_body := StaticBody3D.new()
	floor_body.name = "NavigationFloor"
	add_child(floor_body)
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(24.0, 1.0, 30.0)
	floor_shape.shape = floor_box
	floor_shape.position = Vector3(0.0, -0.5, 0.0)
	floor_body.add_child(floor_shape)
	var floor_mesh := MeshInstance3D.new()
	var floor_box_mesh := BoxMesh.new()
	floor_box_mesh.size = floor_box.size
	floor_mesh.mesh = floor_box_mesh
	floor_mesh.position = floor_shape.position
	floor_body.add_child(floor_mesh)
	_add_obstacle(Vector3(0.0, 0.9, 0.0), Vector3(3.2, 1.8, 3.2), "CenterBarrier")
	_add_obstacle(Vector3(-5.0, 0.5, -5.0), Vector3(2.0, 1.0, 2.0), "SideBlock")

func _add_obstacle(position: Vector3, size: Vector3, label: String) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = position
	add_child(body)
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	body.add_child(shape)
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	body.add_child(mesh_instance)
	var navigation_obstacle := NavigationObstacle3D.new()
	navigation_obstacle.position = position
	navigation_obstacle.avoidance_enabled = true
	navigation_obstacle.radius = maxf(size.x, size.z) * 0.5 + 0.5
	navigation_obstacle.height = size.y
	add_child(navigation_obstacle)

func _build_navigation() -> void:
	var region := NavigationRegion3D.new()
	region.name = "NavigationRegion"
	var navigation_mesh := NavigationMesh.new()
	navigation_mesh.vertices = PackedVector3Array([
		Vector3(-11.5, 0.01, -14.5), Vector3(-11.5, 0.01, 14.5),
		Vector3(11.5, 0.01, 14.5), Vector3(11.5, 0.01, -14.5)
	])
	navigation_mesh.polygons = [PackedInt32Array([0, 1, 2, 3])]
	region.navigation_mesh = navigation_mesh
	add_child(region)
