extends Node3D
## Lightweight, connected graybox route from the Volga landing to a ruined street.

const MISSION_01: MissionDefinition = preload("res://resources/missions/mission_01.tres")
const OBJECTIVE_TRIGGER: PackedScene = preload("res://scenes/missions/objective_trigger.tscn")
const MATERIAL_LIBRARY = preload("res://scripts/environment/environment_material_library.gd")
const GLTFAssetLoader = preload("res://scripts/core/gltf_asset_loader.gd")
const PHASE_05B1_HOUSE: PackedScene = preload("res://assets/models/phase_5b/ruined_house_low_poly/scene.gltf")
const PHASE_05B1_RUBBLE: PackedScene = preload("res://assets/models/phase_5b/rubble_pile_game_ready__2k_pbr/scene.gltf")
const PHASE_05B1_SANDBAG: PackedScene = preload("res://assets/models/phase_5b/sandbag-wall-segment.glb")
const PHASE_05B1_CRATE: PackedScene = preload("res://assets/models/phase_5b/old_military_crate_2k.gltf/old_military_crate_2k.gltf")

func _ready() -> void:
	_build_battlefield()
	_build_navigation()
	_build_objective_triggers()
	_add_phase_05b1_pilot_visuals()
	_build_phase_05c_story_dressing()
	_build_integrated_battlefield_assets()
	MissionManager.prepare_mission(MISSION_01)

func _add_pilot_model(label: String, packed: PackedScene, at: Vector3, yaw: float, model_scale: Vector3) -> void:
	var model := packed.instantiate() as Node3D
	if model == null:
		push_error("Phase 5B.1 asset did not instantiate as Node3D: %s" % label)
		return
	model.name = label
	model.position = at
	model.rotation.y = yaw
	model.scale = model_scale
	add_child(model)

func _add_phase_05b1_pilot_visuals() -> void:
	# The matching box meshes are hidden in _box(); their original bodies and collision shapes remain.
	_add_pilot_model("Phase05B1RuinedFacade", PHASE_05B1_HOUSE, Vector3(17.0, 0.0, -28.0), PI * 0.5, Vector3.ONE)
	_add_pilot_model("Phase05B1Rubble", PHASE_05B1_RUBBLE, Vector3(8.0, 0.02, -33.0), deg_to_rad(15.0), Vector3(1.6, 1.6, 3.2))
	_add_pilot_model("Phase05B1SandbagWall", PHASE_05B1_SANDBAG, Vector3(10.1, 0.0, -38.0), 0.0, Vector3.ONE)
	_add_pilot_model("Phase05B1MilitaryCrate", PHASE_05B1_CRATE, Vector3(9.6, 0.0, -23.5), 0.0, Vector3(1.0, 2.0, 1.0))
	# Reuse the same low-poly ruin and rubble resources at distinct, non-route slots.
	# Each replaces only its matching visual box; existing bodies and collision stay in place.
	_add_pilot_model("LandingRuinedFacade", PHASE_05B1_HOUSE, Vector3(-17.0, 0.0, 2.0), -PI * 0.5, Vector3.ONE)
	_add_pilot_model("TransitionRuinedFacade", PHASE_05B1_HOUSE, Vector3(17.0, 0.0, -13.0), PI * 0.5, Vector3(0.98, 1.0, 0.96))
	_add_pilot_model("StreetRuinedFacade", PHASE_05B1_HOUSE, Vector3(-17.0, 0.0, -58.0), PI * 0.5, Vector3.ONE)
	_add_pilot_model("ForwardRuinedFacade", PHASE_05B1_HOUSE, Vector3(17.0, 0.0, -73.0), -PI * 0.5, Vector3(1.0, 1.0, 0.98))
	_add_pilot_model("LandingRubble", PHASE_05B1_RUBBLE, Vector3(8.0, 0.02, -3.0), deg_to_rad(-12.0), Vector3(1.5, 1.5, 2.8))
	_add_pilot_model("TransitionRubble", PHASE_05B1_RUBBLE, Vector3(-8.0, 0.02, -18.0), deg_to_rad(28.0), Vector3(1.65, 1.6, 3.0))
	_add_pilot_model("StreetRubble", PHASE_05B1_RUBBLE, Vector3(8.0, 0.02, -78.0), deg_to_rad(-24.0), Vector3(1.5, 1.7, 2.8))
	_build_wartime_sign_and_debris()

func _build_wartime_sign_and_debris() -> void:
	# Render-only signs and timber fragments sit on shoulders, clear of triggers and lanes.
	_box(self, "LandingSignPost", Vector3(0.16, 2.2, 0.16), Vector3(9.0, 1.1, 10.0), "weathered_wood", false, Vector3(0, 0, 0.04))
	_box(self, "LandingSignBoard", Vector3(1.5, 0.58, 0.12), Vector3(9.0, 2.0, 10.0), "rusted_metal", false, Vector3(0, -0.08, -0.03))
	_label("VOLGA", Vector3(8.45, 1.92, 9.91), Color(0.78, 0.72, 0.57))
	_box(self, "LandingBrokenPlank", Vector3(2.2, 0.12, 0.24), Vector3(-7.5, 0.16, 29.0), "weathered_wood", false, Vector3(0.03, 0.18, 0.02))
	_box(self, "TransitionBrokenPlank", Vector3(2.5, 0.12, 0.22), Vector3(7.1, 0.14, -16.0), "wood", false, Vector3(0.02, -0.24, 0.04))
	_box(self, "StreetBrokenPlank", Vector3(1.9, 0.12, 0.2), Vector3(-8.4, 0.14, -63.0), "weathered_wood", false, Vector3(0.04, 0.31, 0.02))
	_add_battlefield_barrel("LandingFuelBarrel", Vector3(-8.8, 0.58, 26.0), 0.12)
	_add_battlefield_barrel("TransitionFuelBarrel", Vector3(9.0, 0.58, -23.0), -0.2)
	_add_battlefield_barrel("StreetFuelBarrel", Vector3(9.0, 0.58, -62.0), 0.3)
	# Broken fence remnants are short, render-only shoulder details.
	_box(self, "BrokenFencePost", Vector3(0.14, 1.35, 0.14), Vector3(9.5, 0.68, -57.0), "weathered_wood", false, Vector3(0.08, 0.0, 0.12))
	_box(self, "BrokenFenceBoard", Vector3(2.2, 0.12, 0.16), Vector3(10.5, 0.72, -57.4), "wood", false, Vector3(0.1, 0.05, 0.1))

func _build_phase_05c_story_dressing() -> void:
	# Area A — Volga River Landing (4 render-only shoulder props)
	_box(self, "LandingDamagedCrate", Vector3(1.1, 0.8, 0.9), Vector3(14.5, 0.4, 21.0), "weathered_wood", false, Vector3(0.12, 0.4, -0.08))
	_box(self, "LandingCharredBeam", Vector3(0.24, 0.22, 3.2), Vector3(12.8, 0.22, 16.5), "weathered_wood", false, Vector3(0.06, -0.35, 0.14))
	_box(self, "LandingEquipmentTin", Vector3(0.55, 0.32, 0.75), Vector3(-7.2, 0.18, 22.0), "rusted_metal", false, Vector3(-0.04, 0.55, 0.02))
	_add_render_cylinder("LandingScorchedDebris", 1.2, 1.35, 0.06, Vector3(7.5, 0.08, 14.0), "dark_concrete", 0.2)

	# Area B — Battlefield Transition (4 render-only shoulder props)
	_box(self, "TransitionDamagedSupplyBox", Vector3(1.2, 0.65, 0.8), Vector3(11.2, 0.32, -36.5), "weathered_wood", false, Vector3(0.08, -0.22, 0.05))
	_box(self, "TransitionBrokenTimberCross", Vector3(0.22, 0.20, 2.8), Vector3(-8.8, 0.18, -25.0), "weathered_wood", false, Vector3(0.04, 0.72, 0.06))
	_add_render_cylinder("TransitionDiscardedCanister", 0.22, 0.24, 0.75, Vector3(8.5, 0.22, -18.5), "rusted_metal", 0.3, Vector3(deg_to_rad(85.0), 0.3, 0))
	_add_render_cylinder("TransitionImpactCraterRim", 1.4, 1.6, 0.08, Vector3(9.2, 0.10, -31.0), "dark_concrete", 0.5)

	# Area C — Ruined Stalingrad Street (4 render-only shoulder props)
	_box(self, "StreetFallenRafter", Vector3(0.25, 0.22, 3.6), Vector3(-8.5, 0.6, -52.0), "weathered_wood", false, Vector3(0.18, 0.45, -0.15))
	_box(self, "StreetAbandonedAmmoBox", Vector3(0.65, 0.42, 0.55), Vector3(8.6, 0.35, -67.0), "rusted_metal", false, Vector3(0.05, -0.4, 0.08))
	_box(self, "StreetBrokenFenceSpur", Vector3(0.16, 1.1, 0.16), Vector3(10.2, 0.55, -59.5), "weathered_wood", false, Vector3(-0.15, 0.1, 0.2))
	_box(self, "StreetMasonrySlab", Vector3(1.4, 0.18, 1.1), Vector3(-8.2, 0.18, -72.0), "concrete", false, Vector3(0.14, 0.32, -0.09))

func _build_integrated_battlefield_assets() -> void:
	# Area A — Volga River Shoreline Landmark: Crashed Henschel Hs 129
	var plane := GLTFAssetLoader.instantiate_crashed_hs129()
	if plane != null:
		plane.name = "VolgaCrashedHs129"
		plane.position = Vector3(-18.5, 0.4, 18.0)
		plane.rotation_degrees = Vector3(5, 75, -8)
		add_child(plane)

	# Area B — Battlefield Transition Shoulder: Knocked-out Panzer I Tank
	var tank := GLTFAssetLoader.instantiate_panzer_i()
	if tank != null:
		tank.name = "TransitionKnockedOutPanzerI"
		tank.position = Vector3(-13.0, 0.0, -32.0)
		tank.rotation_degrees = Vector3(0, 115, 0)
		add_child(tank)

	# Defensive Shoulder Prop: German Stick Grenades Crate
	var grenades_b := GLTFAssetLoader.instantiate_stick_grenades()
	if grenades_b != null:
		grenades_b.name = "TransitionGrenadeCrate"
		grenades_b.position = Vector3(10.8, 0.02, -37.5)
		grenades_b.rotation_degrees = Vector3(0, 25, 0)
		add_child(grenades_b)

	# Area C — Ruined Stalingrad Street: Modular City Ruins Facade
	var ruins := GLTFAssetLoader.instantiate_city_ruins()
	if ruins != null:
		ruins.name = "StreetCityRuinsFacade"
		ruins.position = Vector3(22.0, 0.0, -62.0)
		ruins.rotation_degrees = Vector3(0, -90, 0)
		add_child(ruins)

	var grenades_c := GLTFAssetLoader.instantiate_stick_grenades()
	if grenades_c != null:
		grenades_c.name = "StreetGrenadeCrate"
		grenades_c.position = Vector3(7.5, 0.02, -68.0)
		grenades_c.rotation_degrees = Vector3(0, -40, 0)
		add_child(grenades_c)

func _add_render_cylinder(label: String, top_r: float, bot_r: float, h: float, at: Vector3, color_key: String, yaw: float, rot := Vector3.ZERO) -> void:
	var instance := MeshInstance3D.new()
	instance.name = label
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_r
	mesh.bottom_radius = bot_r
	mesh.height = h
	mesh.radial_segments = 10
	instance.mesh = mesh
	instance.material_override = _material(color_key)
	instance.position = at
	if rot != Vector3.ZERO:
		instance.rotation = rot
	else:
		instance.rotation.y = yaw
	add_child(instance)


func _add_battlefield_barrel(label: String, at: Vector3, yaw: float) -> void:
	var instance := MeshInstance3D.new()
	instance.name = label
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.34
	mesh.bottom_radius = 0.38
	mesh.height = 1.05
	mesh.radial_segments = 12
	instance.mesh = mesh
	instance.material_override = _material("rusted_metal")
	instance.position = at
	instance.rotation.y = yaw
	add_child(instance)

func _build_navigation() -> void:
	var nav_mesh := NavigationMesh.new()
	nav_mesh.vertices = PackedVector3Array([
		Vector3(-4.2, 0.08, -94.0), Vector3(-4.2, 0.08, 44.0),
		Vector3(4.2, 0.08, 44.0), Vector3(4.2, 0.08, -94.0)
	])
	nav_mesh.polygons = [PackedInt32Array([0, 1, 2, 3])]
	var region := NavigationRegion3D.new()
	region.name = "MissionNavigation"
	region.navigation_mesh = nav_mesh
	add_child(region)

func _build_objective_triggers() -> void:
	for index in range(MISSION_01.objectives.size()):
		var trigger := OBJECTIVE_TRIGGER.instantiate() as ObjectiveTrigger
		if trigger == null:
			push_error("Mission 01 objective trigger scene has the wrong root type.")
			return
		var objective := MISSION_01.objectives[index]
		trigger.name = "ObjectiveTrigger%02d" % (index + 1)
		trigger.objective_id = objective.objective_id
		trigger.marker_label = "OBJECTIVE %d" % (index + 1)
		trigger.position = objective.trigger_position
		add_child(trigger)

func _material(key: String) -> StandardMaterial3D:
	return MATERIAL_LIBRARY.get_material(StringName(key))

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
	if label == "RuinedBuildingShell" or label == "CollapsedMasonryCover":
		var target_match := (label == "RuinedBuildingShell" and _is_facade_slot(position)) or (label == "CollapsedMasonryCover" and _is_rubble_slot(position))
		if target_match:
			mesh_instance.visible = false
	holder.add_child(mesh_instance)
	if collision:
		var shape_node := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		shape_node.shape = shape
		(holder as StaticBody3D).add_child(shape_node)
	return body

func _is_facade_slot(position: Vector3) -> bool:
	for slot in [Vector3(17.0, 4.0, -28.0), Vector3(-17.0, 3.5, 2.0), Vector3(17.0, 3.5, -13.0), Vector3(-17.0, 4.0, -58.0), Vector3(17.0, 4.0, -73.0)]:
		if position.distance_to(slot) < 0.01:
			return true
	return false

func _is_rubble_slot(position: Vector3) -> bool:
	for slot in [Vector3(8.0, 0.58, -33.0), Vector3(8.0, 0.58, -3.0), Vector3(-8.0, 0.58, -18.0), Vector3(8.0, 0.58, -78.0)]:
		if position.distance_to(slot) < 0.01:
			return true
	return false

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
	_box(self, "SupplyCrate", Vector3(1.4, 1.25, 1.2), Vector3(11.0, 0.63, 22.5), "weathered_wood")
	_box(self, "SupplyCrate", Vector3(1.1, 0.95, 1.0), Vector3(12.1, 0.48, 22.9), "weathered_wood", true, Vector3(0, 0.3, 0.05))
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
		_box(self, "WreckedLorryChassis", Vector3(3.2, 0.8, 5.2), Vector3(-6.7, 0.9, -46), "rusted_metal")
	_box(self, "WreckedLorryCab", Vector3(2.8, 1.7, 1.8), Vector3(-6.7, 2.05, -44.4), "dark_concrete")
	_box(self, "LorryBed", Vector3(2.7, 1.15, 2.9), Vector3(-6.7, 1.75, -47.2), "wood")
	for x in [-8.0, -5.4]:
		for z in [-48.0, -44.0]:
			_box(self, "LorryWheel", Vector3(0.35, 1.0, 0.8), Vector3(x, 0.7, z), "metal")
	for z in [0.0, -30.0, -60.0, -88.0]:
		_box(self, "BrokenUtilityPole", Vector3(0.24, 5.0, 0.24), Vector3(-9.3, 2.5, z), "wood", true, Vector3(0, 0, 0.07))
	_label("RUINED INDUSTRIAL STREET", Vector3(0, 5.8, -78))
