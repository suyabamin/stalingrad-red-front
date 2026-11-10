extends RefCounted
class_name EnvironmentMaterialLibrary
## Shared, opaque materials for the Mission 01 battlefield.

const MATERIALS: Dictionary = {
	&"earth": preload("res://resources/environment/materials/earth.tres"),
	&"mud": preload("res://resources/environment/materials/mud.tres"),
	&"road": preload("res://resources/environment/materials/road.tres"),
	&"brick": preload("res://resources/environment/materials/brick.tres"),
	&"brick_dark": preload("res://resources/environment/materials/brick_dark.tres"),
	&"concrete": preload("res://resources/environment/materials/concrete.tres"),
	&"dark_concrete": preload("res://resources/environment/materials/dark_concrete.tres"),
	&"wood": preload("res://resources/environment/materials/wood.tres"),
	&"weathered_wood": preload("res://resources/environment/materials/weathered_wood.tres"),
	&"metal": preload("res://resources/environment/materials/metal.tres"),
	&"rusted_metal": preload("res://resources/environment/materials/rusted_metal.tres"),
	&"water": preload("res://resources/environment/materials/water.tres"),
}


static func get_material(material_id: StringName) -> StandardMaterial3D:
	return MATERIALS.get(material_id)
