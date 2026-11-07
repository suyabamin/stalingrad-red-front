extends Resource
class_name WeaponData
## Tunable weapon definition shared by weapon scenes and the weapon manager.

@export var weapon_name: String = "Weapon"
@export_range(1, 1000, 1) var damage: int = 20
@export_range(0.1, 30.0, 0.1) var rounds_per_second: float = 1.0
@export_range(1, 200, 1) var magazine_capacity: int = 5
@export_range(0, 1000, 1) var starting_magazine_ammo: int = 5
@export_range(0, 5000, 1) var starting_reserve_ammo: int = 30
@export_range(0.1, 20.0, 0.1) var reload_duration: float = 2.0
@export var automatic: bool = false
@export_range(0.0, 0.2, 0.001) var recoil_strength: float = 0.025
@export_range(40.0, 80.0, 0.5) var ads_fov: float = 62.0
@export_range(1.0, 1000.0, 1.0) var maximum_range: float = 250.0
@export var fire_sound: AudioStream
@export var reload_sound: AudioStream
@export var empty_sound: AudioStream
@export var impact_sound: AudioStream
