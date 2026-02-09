extends CanvasLayer

@export var tooltip_scene:= preload("res://Scenes/tooltip.tscn")

var tooltip_instance: Control

func _ready():
	tooltip_instance = tooltip_scene.instantiate()
	add_child(tooltip_instance)
	tooltip_instance.hide()

func _process(_delta):
	if tooltip_instance.visible:
	# offset by 16px on both axes to prevent tooltip from being directly under the mouse cursor
		var position = get_viewport().get_mouse_position() + Vector2(16, 16)
		tooltip_instance.set_global_position(position)

func show_tooltip(title: String, body: String):
	tooltip_instance.set_content(title, body)


	# Set tooltip to follow mouse position
	var position = get_viewport().get_mouse_position()
	
	tooltip_instance.show_at_position(position)

func hide_tooltip():
	tooltip_instance.hide()
