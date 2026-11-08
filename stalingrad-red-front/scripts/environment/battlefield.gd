extends Node3D
## Lightweight, connected graybox route from the Volga landing to a ruined street.

const COLORS := {
	"earth": Color(0.24, 0.22, 0.18),
	"mud": Color(0.32, 0.27, 0.20),
	"road": Color(0.29, 0.28, 0.25),
	"concrete": Color(0.36, 0.34, 0.30),
	"dark_concrete": Color(0.27, 0.28, 0.27),
	"brick": Color(0.38, 0.27, 0.22),
	"brick_dark": Color(0.30, 0.25, 0.22),
	"wood": Color(0.30, 0.23, 0.16),
	"water": Color(0.15, 0.27, 0.31),
	"metal": Color(0.20, 0.22, 0.21),
}

var _materials: Dictionary = {}

func _ready() -> void:
	_build_battlefield()
	MissionManager.start_mission("mission_01")

func _material(key: String) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key]
	var material := StandardMaterial3D.new()
	material.albedo_color = COLORS[key]
	material.roughness = 1.0
	_materials[key] = material
	return material

func _box(parent: Node3D, label: String, size: Vector3, position: Vector3, color_key: String, collision := true, rotation := Vector3.ZERO) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new() if collision else null
	var holder: Node3D = body if collision else Node3D.new()
	holder.name = label
	parent.add_child(holder)
	holder.position = position
	holder.rotation = rotation
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _material(color_key)
	holder.add_child(mesh_instance)
	if collision:
		var shape_node := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		shape_node.shape = shape
		(holder as StaticBody3D).add_child(shape_node)
	return body

func _label(text: String, position: Vector3, color := Color(0.91, 0.78, 0.54)) -> void:
	var sign := Label3D.new()
	sign.text = text
	sign.position = position
	sign.font_size = 48
	sign.pixel_size = 0.008
	sign.modulate = color
	sign.outline_size = 8
	sign.no_depth_test = false
	add_child(sign)

func _build_battlefield() -> void:
	# The full route is a single level ground slab; the river bank is a raised shore beside it.
	_box(self, "ContinuousGround", Vector3(74, 1, 142), Vector3(0, -0.5, -25), "earth")
	_box(self, "RuinedStreetRoad", Vector3(10, 0.10, 100), Vector3(0, 0.05, -30), "road", false)
	_box(self, "LandingMud", Vector3(31, 0.12, 29), Vector3(-14, 0.06, 24), "mud", false)
	_box(self, "VolgaWater", Vector3(40, 0.12, 75), Vector3(32, 0.04, 29), "water", false)
	_box(self, "RiverShore", Vector3(0.8, 0.5, 54), Vector3(11.6, 0.25, 25), "mud")

	# A short, solid timber landing stage gives the player a clear start landmark.
	_box(self, "LandingPier", Vector3(8, 0.45, 13), Vector3(16.5, 0.36, 25), "wood")
	for x in [13.3, 19.7]:
		for z in [20.0, 30.0]:
			_box(self, "PierSupport", Vector3(0.45, 2.5, 0.45), Vector3(x, -0.7, z), "wood")
	_box(self, "SupplyCrate", Vector3(1.4, 1.25, 1.2), Vector3(11.0, 0.63, 22.5), "wood")
	_box(self, "SupplyCrate", Vector3(1.1, 0.95, 1.0), Vector3(12.1, 0.48, 22.9), "wood", true, Vector3(0, 0.3, 0.05))
	_label("VOLGA LANDING", Vector3(-8, 4.2, 11))

	# Low cover and debris point down the central route without blocking it.
	var rubble_colors := ["concrete", "dark_concrete", "brick_dark"]
	for i in range(28):
		var side := -1.0 if i % 2 == 0 else 1.0
		var z := 14.0 - float(i) * 3.55
		var x := side * (5.6 + float(i % 4) * 0.55)
		var dims := Vector3(0.65 + float(i % 3) * 0.32, 0.35 + float(i % 3) * 0.22, 0.6 + float(i % 4) * 0.2)
		_box(self, "RoadsideMasonry", dims, Vector3(x, dims.y * 0.5, z), rubble_colors[i % rubble_colors.size()], true, Vector3(0.08, float(i) * 0.47, 0.04))

	# Ruined building shells frame a broad, open road. Segmented walls leave readable gaps.
	var facade_colors := ["brick", "concrete", "brick_dark", "dark_concrete"]
	for section in range(6):
		var z := 2.0 - float(section) * 15.0
		for side in [-1.0, 1.0]:
			if section == 0 and side > 0.0:
				continue
			var x: float = side * 17.0
			var h := 7.0 + float((section + int(side + 1.0)) % 3)
			var tone: String = facade_colors[(section + int(side + 1.0)) % facade_colors.size()]
			_box(self, "RuinedBuildingShell", Vector3(12, h, 13), Vector3(x, h * 0.5, z), tone)
			# Broken wall cap and exposed beam suggest a bombed upper storey.
			_box(self, "BrokenUpperWall", Vector3(7.0, 1.0, 3.2), Vector3(x - side * 2.0, h + 0.5, z - 1.0), "concrete", true, Vector3(0, 0, side * 0.08))
			_box(self, "ExposedBeam", Vector3(0.32, 4.0, 0.32), Vector3(x + side * 3.1, h - 1.6, z + 3.0), "wood", true, Vector3(0.08, 0, side * 0.05))
		# Large low rubble piles sit against the facades as cover, leaving a 10 m road.
		for side in [-1.0, 1.0]:
			var pile_x: float = side * (8.0 + float(section % 2))
			_box(self, "CollapsedMasonryCover", Vector3(2.8, 1.15, 4.0), Vector3(pile_x, 0.58, z - 5.0), "concrete", true, Vector3(0, side * 0.12, 0))
			_box(self, "TimberStreetCover", Vector3(2.4, 0.85, 0.45), Vector3(side * 6.1, 0.43, z + 2.2), "wood", true, Vector3(0, 0, side * 0.04))

	# Simple damaged lorry silhouette and street-side poles serve as scale cues.
	_box(self, "WreckedLorryChassis", Vector3(3.2, 0.8, 5.2), Vector3(-6.7, 0.9, -46), "metal")
	_box(self, "WreckedLorryCab", Vector3(2.8, 1.7, 1.8), Vector3(-6.7, 2.05, -44.4), "dark_concrete")
	_box(self, "LorryBed", Vector3(2.7, 1.15, 2.9), Vector3(-6.7, 1.75, -47.2), "wood")
	for x in [-8.0, -5.4]:
		for z in [-48.0, -44.0]:
			_box(self, "LorryWheel", Vector3(0.35, 1.0, 0.8), Vector3(x, 0.7, z), "metal")
	for z in [0.0, -30.0, -60.0, -88.0]:
		_box(self, "BrokenUtilityPole", Vector3(0.24, 5.0, 0.24), Vector3(-9.3, 2.5, z), "wood", true, Vector3(0, 0, 0.07))
	_label("RUINED INDUSTRIAL STREET", Vector3(0, 5.8, -78))
