extends CanvasLayer
## Minimal in-world controls hint and reticle for the first playable build.

func _ready() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var reticle := Label.new()
	reticle.text = "+"
	reticle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reticle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	reticle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	reticle.position = Vector2(-8, -15)
	reticle.add_theme_font_size_override("font_size", 24)
	root.add_child(reticle)
	var hint := Label.new()
	hint.text = "MISSION 01  |  WASD MOVE  ·  SHIFT SPRINT  ·  SPACE JUMP  ·  ESC RELEASE MOUSE"
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_left = 20
	hint.offset_top = -38
	hint.offset_bottom = -12
	hint.add_theme_font_size_override("font_size", 14)
	root.add_child(hint)
