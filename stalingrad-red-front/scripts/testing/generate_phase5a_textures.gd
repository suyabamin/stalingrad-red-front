extends SceneTree

const SIZE := 256
const OUT := "res://assets/textures/environment/"

func _initialize() -> void:
	_generate("earth_surface.png", 0)
	_generate("mud_surface.png", 1)
	_generate("masonry_surface.png", 2)
	_generate("timber_surface.png", 3)
	_generate("water_surface.png", 4)
	quit()

func _generate(file_name: String, kind: int) -> void:
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 541 + kind * 97
	var cells := PackedFloat32Array()
	for i in range(64 * 64):
		cells.append(rng.randf())
	for y in range(SIZE):
		for x in range(SIZE):
			var value := _noise(cells, float(x) / 4.0, float(y) / 4.0, 64)
			var fine := _noise(cells, float(x) / 2.0, float(y) / 2.0, 64)
			var pattern := 0.0
			match kind:
				0: # Compacted earth with broad soil patches and small grit.
					pattern = value * 0.72 + fine * 0.28
				1: # Damp mud: irregular puddle stains, subdued rather than glossy.
					pattern = value * 0.82 + fine * 0.18
				2: # Uneven brick courses and mortar joints, seamless at all edges.
					var row := int(floor(float(y) / 32.0))
					var local_x := fposmod(float(x) + (16.0 if row % 2 else 0.0), 64.0)
					var mortar := (fposmod(float(y), 32.0) < 4.0 or local_x < 4.0)
					pattern = (value * 0.72 + fine * 0.28) * (0.30 if mortar else 1.0)
				3: # Timber grain, narrow streaks with light knots.
					pattern = _noise(cells, float(x) / 2.0, float(y) / 8.0, 64) * 0.7 + fine * 0.3
				4: # Broad, irregular river variation with finer surface breakup.
					var broad_water := _noise(cells, float(x) / 16.0, float(y) / 16.0, 64)
					pattern = broad_water * 0.72 + value * 0.20 + fine * 0.08
			var center := 0.50
			var amplitudes: Array[float] = [0.33, 0.34, 0.37, 0.30, 0.82]
			var amplitude: float = amplitudes[kind]
			var gray := clampf(center + (pattern - 0.5) * amplitude, 0.12, 0.90)
			image.set_pixel(x, y, Color(gray, gray, gray))
	var error := image.save_png(OUT + file_name)
	if error != OK:
		push_error("Unable to write texture %s: %s" % [file_name, error])

func _noise(data: PackedFloat32Array, px: float, py: float, grid: int) -> float:
	var x0 := int(floor(px)) % grid
	var y0 := int(floor(py)) % grid
	var x1 := (x0 + 1) % grid
	var y1 := (y0 + 1) % grid
	var tx := fposmod(px, 1.0)
	var ty := fposmod(py, 1.0)
	tx = tx * tx * (3.0 - 2.0 * tx)
	ty = ty * ty * (3.0 - 2.0 * ty)
	var a := lerpf(data[y0 * grid + x0], data[y0 * grid + x1], tx)
	var b := lerpf(data[y1 * grid + x0], data[y1 * grid + x1], tx)
	return lerpf(a, b, ty)
