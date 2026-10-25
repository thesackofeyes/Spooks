extends Control

@onready var title_label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Title
@onready var bodyA_label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Body
@onready var bodyB_label = $PanelContainer/MarginContainer/VBoxContainer/BodySmall
@onready var image_texture = $PanelContainer/MarginContainer/HBoxContainer/Icon

# bodyB fits its text up to this width, then wraps
const BODY_B_MAX_WIDTH := 200.0

func set_content(title: String, bodyA: String, bodyB: String, image: Texture2D = null) -> void:
	title_label.visible = title != ""
	bodyA_label.visible = bodyA != ""
	bodyB_label.visible = bodyB != ""
	image_texture.visible = image != null
	
	title_label.text = title
	bodyA_label.text = bodyA
	bodyB_label.text = bodyB
	image_texture.texture = image
	_fit_body_b_width()

# RichTextLabel can't size to its text while wrapping, so wrap only when the text
# is too wide, and fix the width at the max in that case
func _fit_body_b_width() -> void:
	var font = bodyB_label.get_theme_font("normal_font")
	var font_size = bodyB_label.get_theme_font_size("normal_font_size")
	var text_width = font.get_multiline_string_size(bodyB_label.get_parsed_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var fits = text_width <= BODY_B_MAX_WIDTH
	bodyB_label.autowrap_mode = TextServer.AUTOWRAP_OFF if fits else TextServer.AUTOWRAP_WORD_SMART
	bodyB_label.custom_minimum_size.x = 0.0 if fits else BODY_B_MAX_WIDTH

func show_at_position(pos: Vector2) -> void:
	position = pos
	show()
