extends Resource
class_name Ability

@export var name: String = ""
@export var icon_x: int = 0
@export var icon_y: int = 0
@export_multiline var description: String = ""

@export var ability_range: int = 1
@export var damage: int = 0
@export var movement_speed: int = 0
@export var cost: int = 0

@export var compatible_subclasses: Array[String] = []
