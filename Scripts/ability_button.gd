extends Button
class_name AbilityButton

var data

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_mouse_entered() -> void:
	TooltipManager.show_tooltip(
		data.name,
		data.description + "\nCost: " +  str(data.cost)
	)


func _on_mouse_exited() -> void:
	TooltipManager.hide_tooltip()


func _on_toggled(toggled_on: bool) -> void:
	print("Ability data: ", data)
	if toggled_on:
		print("Ability ", data.name, " activated.")
		if data.ability_script != null:
			print("Loading ability script: ", data.ability_script)
			var ability_script_instance = data.ability_script.new()
			print("Ability script instance: ", ability_script_instance)

			if ability_script_instance != null:
				ability_script_instance.execute(TurnManager.current_unit)
	else:
		print("Ability ", data.name, " deactivated.")
