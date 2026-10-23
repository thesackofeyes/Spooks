extends Button
class_name AbilityButton

var data

@onready var CombatScene = get_tree().get_current_scene().get_node("Combat")


func _on_mouse_entered() -> void:
	TooltipManager.show_tooltip(
		data.name,
		data.description + "\nCost: " +  str(data.cost)
	)


func _on_mouse_exited() -> void:
	TooltipManager.hide_tooltip()


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		CombatScene.unpress_action_buttons()
		CombatScene.unpress_ability_buttons(self)
	if data.ability_script != null:
		var ability_script_instance = data.ability_script.new()

		if ability_script_instance != null:
			ability_script_instance.execute(data, self, CombatScene)
