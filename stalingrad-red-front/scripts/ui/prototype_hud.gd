extends CanvasLayer
## Existing combat HUD plus signal-driven mission briefing and progression UI.

var health_label: Label
var health_bar: ProgressBar
var weapon_label: Label
var ammunition_label: Label
var reload_label: Label
var death_panel: ColorRect
var death_restart_button: Button
var objective_panel: PanelContainer
var objective_title_label: Label
var objective_description_label: Label
var objective_progress_label: Label
var objective_feedback_label: Label
var briefing_panel: ColorRect
var briefing_objectives: Label
var briefing_title_label: Label
var briefing_context_label: Label
var briefing_body_label: Label
var completion_panel: ColorRect
var completion_progress_label: Label
var completion_restart_button: Button
var start_mission_button: Button
var objective_feedback_timer: Timer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var health_box := VBoxContainer.new()
	health_box.position = Vector2(20, 18)
	health_box.custom_minimum_size = Vector2(220, 0)
	root.add_child(health_box)
	health_label = Label.new()
	health_label.text = "HEALTH 100 / 100"
	health_box.add_child(health_label)
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(220, 18)
	health_bar.show_percentage = false
	health_box.add_child(health_bar)
	weapon_label = Label.new()
	weapon_label.text = "WEAPON —"
	health_box.add_child(weapon_label)
	ammunition_label = Label.new()
	ammunition_label.text = "AMMO — / —"
	health_box.add_child(ammunition_label)
	reload_label = Label.new()
	reload_label.text = "RELOADING"
	reload_label.visible = false
	health_box.add_child(reload_label)
	var reticle := Label.new()
	reticle.text = "+"
	reticle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reticle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	reticle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	reticle.position = Vector2(-8, -15)
	reticle.add_theme_font_size_override("font_size", 24)
	root.add_child(reticle)
	var hint := Label.new()
	hint.text = "MISSION 01  |  WASD MOVE  |  SHIFT SPRINT  |  SPACE JUMP  |  ESC RELEASE MOUSE"
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_left = 20
	hint.offset_top = -38
	hint.offset_bottom = -12
	hint.add_theme_font_size_override("font_size", 14)
	root.add_child(hint)
	_build_death_panel(root)
	_build_objective_panel(root)
	_build_briefing_panel(root)
	_build_completion_panel(root)
	objective_feedback_timer = Timer.new()
	objective_feedback_timer.one_shot = true
	objective_feedback_timer.wait_time = 2.5
	objective_feedback_timer.timeout.connect(_hide_objective_feedback)
	add_child(objective_feedback_timer)
	GameManager.player_spawned.connect(_on_player_spawned)
	GameManager.player_died.connect(_show_death_panel)
	MissionManager.objective_started.connect(_on_objective_started)
	MissionManager.objective_completed.connect(_on_objective_completed)
	MissionManager.objective_failed.connect(_on_objective_failed)
	MissionManager.mission_completed.connect(_on_mission_completed)
	if GameManager.current_player != null:
		_on_player_spawned(GameManager.current_player)
	if MissionManager.current_definition != null and MissionManager.mission_state == MissionManager.MissionState.READY:
		_show_briefing(MissionManager.current_definition)
	elif MissionManager.mission_state == MissionManager.MissionState.ACTIVE:
		_update_objective(MissionManager.get_current_objective(), MissionManager.current_objective_index + 1, MissionManager.get_objective_count())
	else:
		objective_panel.visible = false

func _build_death_panel(root: Control) -> void:
	death_panel = ColorRect.new()
	death_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_panel.color = Color(0.05, 0.02, 0.02, 0.82)
	death_panel.visible = false
	root.add_child(death_panel)
	var content := VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	content.position = Vector2(-130, -65)
	content.custom_minimum_size = Vector2(260, 130)
	death_panel.add_child(content)
	var title := Label.new()
	title.text = "YOU ARE DOWN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	death_restart_button = Button.new()
	death_restart_button.text = "RESTART MISSION"
	death_restart_button.pressed.connect(GameManager.restart_current_scene)
	content.add_child(death_restart_button)
	var menu_button := Button.new()
	menu_button.text = "RETURN TO TITLE (UNAVAILABLE)"
	menu_button.disabled = true
	content.add_child(menu_button)

func _build_objective_panel(root: Control) -> void:
	objective_panel = PanelContainer.new()
	objective_panel.anchor_left = 1.0
	objective_panel.anchor_right = 1.0
	objective_panel.offset_left = -390.0
	objective_panel.offset_right = -20.0
	objective_panel.offset_top = 18.0
	objective_panel.offset_bottom = 142.0
	objective_panel.visible = false
	root.add_child(objective_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	objective_panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	margin.add_child(content)
	objective_title_label = Label.new()
	objective_title_label.add_theme_font_size_override("font_size", 17)
	objective_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(objective_title_label)
	objective_description_label = Label.new()
	objective_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(objective_description_label)
	objective_progress_label = Label.new()
	objective_progress_label.add_theme_color_override("font_color", Color(0.86, 0.73, 0.49))
	content.add_child(objective_progress_label)
	objective_feedback_label = Label.new()
	objective_feedback_label.visible = false
	objective_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_feedback_label.add_theme_color_override("font_color", Color(0.91, 0.79, 0.56))
	content.add_child(objective_feedback_label)

func _build_briefing_panel(root: Control) -> void:
	briefing_panel = _build_fullscreen_overlay(root, Color(0.035, 0.045, 0.045, 0.91))
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-365, -280)
	panel.custom_minimum_size = Vector2(730, 560)
	briefing_panel.add_child(panel)
	var margin := _add_panel_margin(panel, 28)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 13)
	margin.add_child(content)
	var title := Label.new()
	title.name = "BriefingTitle"
	briefing_title_label = title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	content.add_child(title)
	var context := Label.new()
	context.name = "HistoricalContext"
	briefing_context_label = context
	context.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	context.add_theme_color_override("font_color", Color(0.82, 0.70, 0.49))
	context.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(context)
	var body := Label.new()
	body.name = "BriefingText"
	briefing_body_label = body
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(0, 54)
	content.add_child(body)
	var heading := Label.new()
	heading.text = "MISSION OBJECTIVES"
	heading.add_theme_font_size_override("font_size", 16)
	content.add_child(heading)
	briefing_objectives = Label.new()
	briefing_objectives.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	briefing_objectives.custom_minimum_size = Vector2(0, 150)
	content.add_child(briefing_objectives)
	start_mission_button = Button.new()
	start_mission_button.text = "START MISSION"
	start_mission_button.custom_minimum_size = Vector2(220, 48)
	start_mission_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	start_mission_button.pressed.connect(_on_start_mission_pressed)
	content.add_child(start_mission_button)
	briefing_panel.visible = false

func _build_completion_panel(root: Control) -> void:
	completion_panel = _build_fullscreen_overlay(root, Color(0.025, 0.045, 0.035, 0.91))
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-280, -145)
	panel.custom_minimum_size = Vector2(560, 290)
	completion_panel.add_child(panel)
	var margin := _add_panel_margin(panel, 28)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	margin.add_child(content)
	var title := Label.new()
	title.text = "MISSION COMPLETED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	content.add_child(title)
	completion_progress_label = Label.new()
	completion_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(completion_progress_label)
	completion_restart_button = Button.new()
	completion_restart_button.text = "RESTART MISSION"
	completion_restart_button.custom_minimum_size = Vector2(220, 48)
	completion_restart_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	completion_restart_button.pressed.connect(GameManager.restart_current_scene)
	content.add_child(completion_restart_button)
	completion_panel.visible = false

func _build_fullscreen_overlay(root: Control, color: Color) -> ColorRect:
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = color
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(overlay)
	return overlay

func _add_panel_margin(panel: PanelContainer, value: int) -> MarginContainer:
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, value)
	panel.add_child(margin)
	return margin

func _show_briefing(definition: MissionDefinition) -> void:
	if definition == null:
		return
	briefing_title_label.text = definition.title.to_upper()
	briefing_context_label.text = definition.historical_context
	briefing_body_label.text = definition.briefing
	var lines: Array[String] = []
	for index in range(definition.objectives.size()):
		lines.append("%d. %s" % [index + 1, definition.objectives[index].display_name])
	briefing_objectives.text = "\n".join(lines)
	briefing_panel.visible = true
	completion_panel.visible = false
	objective_panel.visible = false
	death_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameManager.set_paused(true)
	start_mission_button.grab_focus()

func _on_start_mission_pressed() -> void:
	if not MissionManager.begin_mission():
		return
	briefing_panel.visible = false
	GameManager.set_paused(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_objective_started(objective: ObjectiveDefinition, number: int, total: int) -> void:
	_update_objective(objective, number, total)

func _update_objective(objective: ObjectiveDefinition, number: int, total: int) -> void:
	if objective == null:
		return
	objective_panel.visible = true
	objective_title_label.text = objective.display_name
	objective_description_label.text = objective.description
	objective_progress_label.text = "OBJECTIVE %d / %d" % [number, total]

func _on_objective_completed(_objective: ObjectiveDefinition, completed_count: int, total: int) -> void:
	objective_feedback_label.text = "OBJECTIVE COMPLETE  |  %d / %d" % [completed_count, total]
	objective_feedback_label.visible = true
	objective_feedback_timer.start()

func _on_objective_failed(objective: ObjectiveDefinition, reason: String) -> void:
	objective_panel.visible = true
	objective_title_label.text = "OBJECTIVE FAILED  |  %s" % objective.display_name
	objective_description_label.text = reason
	objective_progress_label.text = "MISSION FAILED"
	objective_feedback_label.visible = false

func _on_mission_completed(_mission_id: String) -> void:
	briefing_panel.visible = false
	death_panel.visible = false
	completion_progress_label.text = "Across the Volga  |  %d / %d objectives complete" % [MissionManager.completed_objective_count, MissionManager.get_objective_count()]
	completion_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameManager.set_paused(true)
	completion_restart_button.grab_focus()

func _hide_objective_feedback() -> void:
	objective_feedback_label.visible = false

func _on_player_spawned(player: Node3D) -> void:
	if player.has_node("Health"):
		var health: PlayerHealth = player.get_node("Health") as PlayerHealth
		if not health.health_changed.is_connected(_on_health_changed):
			health.health_changed.connect(_on_health_changed)
		_on_health_changed(health.current_health, health.maximum_health)
	if player.has_node("WeaponManager"):
		var weapon_manager: WeaponManager = player.get_node("WeaponManager") as WeaponManager
		if not weapon_manager.weapon_state_changed.is_connected(_on_weapon_state_changed):
			weapon_manager.weapon_state_changed.connect(_on_weapon_state_changed)
		weapon_manager.publish_current_state()

func _on_health_changed(current: int, maximum: int) -> void:
	health_label.text = "HEALTH %d / %d" % [current, maximum]
	health_bar.max_value = maximum
	health_bar.value = current
	var fraction: float = float(current) / float(maximum)
	health_bar.modulate = Color(0.85, 0.12, 0.08) if fraction <= 0.3 else Color(0.25, 0.8, 0.3)

func _on_weapon_state_changed(weapon_name: String, magazine: int, capacity: int, reserve: int, reloading: bool) -> void:
	weapon_label.text = "WEAPON %s" % weapon_name
	ammunition_label.text = "AMMO %d / %d  |  RESERVE %d" % [magazine, capacity, reserve]
	ammunition_label.modulate = Color(1.0, 0.35, 0.22) if magazine <= 3 else Color.WHITE
	reload_label.visible = reloading

func _show_death_panel() -> void:
	death_panel.visible = true
	death_panel.get_child(0).get_child(1).grab_focus()
