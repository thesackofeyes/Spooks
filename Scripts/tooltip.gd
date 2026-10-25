extends Control

@onready var title_label = $PanelContainer/VBoxContainer/Title
@onready var body_label = $PanelContainer/VBoxContainer/Body
@onready var image_texture = $PanelContainer/HBoxContainer/Icon

func set_content(title: String, body: String, image: Texture2D = null) -> void:
	title_label.text = title
	body_label.text = body
	image_texture.visible = image != null
	image_texture.texture = image

func show_at_position(pos: Vector2) -> void:
	position = pos
	show()
