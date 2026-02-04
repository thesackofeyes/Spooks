extends Button

@onready var sprite = $ButtonIcon
@onready var label = $Label

@export var icon_sheet: Texture = null

@export var hframes: int = 0
@export var vframes: int = 0
@export var icon_x: int = 0
@export var icon_y: int = 0

@export var label_text: String = ""

func _ready() -> void:
	if icon_sheet != null and sprite != null:
		sprite.texture = icon_sheet
		sprite.hframes = hframes
		sprite.vframes = vframes
		sprite.frame = icon_y * hframes + icon_x
	
	if label_text != "" and label != null:
		label.text = label_text
		
