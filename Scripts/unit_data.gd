extends Resource
class_name UnitData

# Image Data
@export var sprite: Texture2D

@export var sprite_h_frames: int
@export var sprite_v_frames: int

@export var sprite_scale: float = 1.0

@export var icon_x: int = 0
@export var icon_y: int = 0

@export var hero_sprite_x: int = 0
@export var hero_sprite_y: int = 0


# Unit Data
@export var start_position: Vector2i

@export var unit_class: String = ""
@export var unit_subclass: String = ""

@export var player_unit: bool = true
@export var level: int = 1


# Stats
@export var base_hp: int = 12
@export var speed: int = 3
@export var dexterity: int = 5
@export var strength: int = 5
@export var resolve: int = 5
@export var stamina: int = 5
@export var intelligence: int = 5
@export var presence: int = 5

# Combat
@export var base_attack_range: int = 1
@export var base_attack_damage: int = 3

# Abilities
@export var abilities: Array[Ability] = []
