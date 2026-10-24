extends Button
class_name AbilityButton

# Bubbled up through the abilities container to Combat, which runs the ability
signal ability_toggled(ability_button, toggled_on)

var data


func _on_mouse_entered() -> void:
	TooltipManager.show_tooltip(
		data.name,
		data.description + "\nCost: " +  str(data.cost)
	)


func _on_mouse_exited() -> void:
	TooltipManager.hide_tooltip()


func _on_toggled(toggled_on: bool) -> void:
	ability_toggled.emit(self, toggled_on)
