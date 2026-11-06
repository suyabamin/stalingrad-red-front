extends Node3D
## Low-poly ruined street assembled from reusable primitive meshes at runtime.

func _ready() -> void:
	_build_battlefield()
	MissionManager.start_mission("mission_01")

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	return material

func _box(parent: Node3D, label: String, size: Vector3, position: Vector3, color: Color, collision := true, rotation := Vector3.ZERO) -> void:
	var body := StaticBody3D.new() if collision else Node3D.new()
	body.name = label
	parent.add_child(body)
	body.position = position
	body.rotation = rotation
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _material(color)
	body.add_child(mesh_instance)
	if collision:
		var shape_node := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		shape_node.shape = shape
		body.add_child(shape_node)

func _build_battlefield() -> void:
	_box(self, "Ground", Vector3(56, 1, 56), Vector3(0, -0.5, 0), Color(0.23, 0.22, 0.19))
	# Broad walkable route through a devastated factory district.
	_box(self, "Roadway", Vector3(9, 0.08, 52), Vector3(0, 0.04, 0), Color(0.31, 0.29, 0.25), false)
	var masonry := [Color(0.35, 0.32, 0.28), Color(0.29, 0.29, 0.27), Color(0.39, 0.34, 0.29)]
	# Building shells line both sides while keeping a central corridor clear.
	for side in [-1.0, 1.0]:
		for section in range(3):
			var z := -18.0 + float(section) * 17.0
			var x: float = side * 12.0
			var base_height := 8.0 + float((section + int(side + 1.0)) % 2) * 2.0
			_box(self, "RuinedFacade", Vector3(10, base_height, 13), Vector3(x, base_height * 0.5, z), masonry[section % masonry.size()])
			_box(self, "BrokenUpperWall", Vector3(6.0, 3.0, 3.0), Vector3(x - side * 2.0, base_height + 1.3, z - 2.0), masonry[(section + 1) % masonry.size()], true, Vector3(0, 0, side * 0.12))
	# Rubble piles are small collidable blocks, arranged at road edges.
	var rubble_colors := [Color(0.43, 0.39, 0.33), Color(0.27, 0.27, 0.25), Color(0.49, 0.42, 0.34)]
	for i in range(24):
		var side := -1.0 if i % 2 == 0 else 1.0
		var z := -22.0 + float(i) * 1.9
		var x := side * (5.3 + float(i % 3) * 0.7)
		var dims := Vector3(0.8 + float(i % 3) * 0.35, 0.45 + float(i % 2) * 0.45, 0.7 + float(i % 4) * 0.2)
		_box(self, "ConcreteDebris", dims, Vector3(x, dims.y * 0.5, z), rubble_colors[i % rubble_colors.size()], true, Vector3(0.1 * float(i % 2), float(i) * 0.41, 0.08))
	# Broken utility poles and a low concrete barricade provide scale and cover.
	for pole_z in [-13.0, 7.0, 24.0]:
		_box(self, "BrokenUtilityPole", Vector3(0.25, 5.5, 0.25), Vector3(-6.3, 2.6, pole_z), Color(0.22, 0.2, 0.17), true, Vector3(0, 0, -0.08))
	_box(self, "RoadsideBarricade", Vector3(4.2, 0.85, 0.7), Vector3(2.8, 0.42, 14.0), Color(0.34, 0.32, 0.28))
