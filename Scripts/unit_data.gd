extends Resource
class_name UnitData

@export var sprite: Texture2D

@export var sprite_h_frames: int
@export var sprite_v_frames: int

@export var icon_x: int = 0
@export var icon_y: int = 0

# This will be removed from the total height/width.
# 0,0 is 'start' tile, 1,1 is one in on both axis
@export var start_position: Vector2i

@export var unit_class: String = ""
@export var unit_subclass: String = ""
@export var level: int = 1
@export var speed: int = 3
@export var dexterity: int = 5
@export var strength: int = 5
@export var resolve: int = 5
@export var stamina: int = 5
@export var intelligence: int = 5
@export var presence: int = 5
@export var abilities: Array[Ability] = []
