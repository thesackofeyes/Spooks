extends Control

@onready var title_label = $PanelContainer/VBoxContainer/Title
@onready var body_label = $PanelContainer/VBoxContainer/Body

func set_content(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body

func show_at_position(pos: Vector2) -> void:
	position = pos
	show()
