extends Node3D
class_name Phase5CAtmosphere
## Phase 5C atmospheric effects controller (dust & distant smoke).
## Adheres strictly to <= 120 particles total and <= 4 emitters.
## Presentation-only, no collisions, trails, or physics interactions.

@onready var landing_dust: CPUParticles3D = $LandingDust
@onready var transition_dust: CPUParticles3D = $TransitionDust
@onready var smoke_west: CPUParticles3D = $DistantSmokePlumeWest
@onready var smoke_east: CPUParticles3D = $DistantSmokePlumeEast

var _is_low_quality: bool = false

func _ready() -> void:
	# Ensure emitters are running
	for emitter in get_emitters():
		emitter.emitting = true

func get_emitters() -> Array[CPUParticles3D]:
	var list: Array[CPUParticles3D] = []
	if is_instance_valid(landing_dust): list.append(landing_dust)
	if is_instance_valid(transition_dust): list.append(transition_dust)
	if is_instance_valid(smoke_west): list.append(smoke_west)
	if is_instance_valid(smoke_east): list.append(smoke_east)
	return list

func get_active_particle_count() -> int:
	var total: int = 0
	for emitter in get_emitters():
		if emitter.emitting:
			total += emitter.amount
	return total

func apply_low_quality(low: bool) -> void:
	_is_low_quality = low
	if is_instance_valid(smoke_west):
		smoke_west.emitting = not low
	if is_instance_valid(smoke_east):
		smoke_east.emitting = not low
	if is_instance_valid(landing_dust):
		landing_dust.amount = 12 if low else 24
	if is_instance_valid(transition_dust):
		transition_dust.amount = 12 if low else 24
