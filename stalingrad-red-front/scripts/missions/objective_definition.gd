extends Resource
class_name ObjectiveDefinition
## Static display text and stable identity for one sequential mission objective.

@export var objective_id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var trigger_position: Vector3 = Vector3.ZERO
