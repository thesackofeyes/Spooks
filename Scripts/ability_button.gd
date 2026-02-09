extends Button
class_name AbilityButton

var data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Ability Data", data)
	pass


func _on_mouse_entered() -> void:
	TooltipManager.show_tooltip(
		data.name,
		data.description + "\nCost: " +  str(data.cost)
	)


func _on_mouse_exited() -> void:
	TooltipManager.hide_tooltip()
