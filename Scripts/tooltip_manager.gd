extends CanvasLayer

const TOOLTIP_SCENE := preload("res://Scenes/tooltip.tscn")

# Keeps the tooltip from sitting directly under the mouse cursor
const MOUSE_OFFSET := Vector2(16, 16)

var tooltip_instance: Control

func _ready():
	tooltip_instance = TOOLTIP_SCENE.instantiate()
	add_child(tooltip_instance)
	tooltip_instance.hide()

func _process(_delta):
	if tooltip_instance.visible:
		tooltip_instance.set_global_position(_get_tooltip_position())

func show_tooltip(title: String, body: String):
	tooltip_instance.set_content(title, body)
	# Same position as _process uses, so it doesn't jump on the next frame
	tooltip_instance.show_at_position(_get_tooltip_position())

func hide_tooltip():
	tooltip_instance.hide()

func is_showing() -> bool:
	return tooltip_instance.visible

func _get_tooltip_position() -> Vector2:
	return get_viewport().get_mouse_position() + MOUSE_OFFSET
