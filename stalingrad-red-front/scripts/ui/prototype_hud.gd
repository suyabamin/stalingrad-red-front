extends CanvasLayer
## Prototype reticle, controls hint, health display and death recovery UI.

var health_label: Label
var health_bar: ProgressBar
var weapon_label: Label
var ammunition_label: Label
var reload_label: Label
var death_panel: ColorRect

func _ready() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
	GameManager.player_spawned.connect(_on_player_spawned)
	GameManager.player_died.connect(_show_death_panel)
	if GameManager.current_player != null:
		_on_player_spawned(GameManager.current_player)

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
	var restart_button := Button.new()
	restart_button.text = "RESTART MISSION"
	restart_button.pressed.connect(GameManager.restart_current_scene)
	content.add_child(restart_button)
	var menu_button := Button.new()
	menu_button.text = "RETURN TO TITLE (UNAVAILABLE)"
	menu_button.disabled = true
	content.add_child(menu_button)

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
