extends Resource
class_name MissionDefinition
## Data for a mission briefing and its ordered objective sequence.

@export var mission_id: StringName
@export var title: String = ""
@export_multiline var historical_context: String = ""
@export_multiline var briefing: String = ""
@export var objectives: Array[ObjectiveDefinition] = []
