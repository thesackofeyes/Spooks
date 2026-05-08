extends Button
class_name AbilityButton

var data

@onready var CombatScene = get_tree().get_current_scene().get_node("Combat")

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


func _on_toggled(_toggled_on: bool) -> void:
	CombatScene.unpress_action_buttons()
	if data.ability_script != null:
		print("Loading ability script: ", data.ability_script)
		var ability_script_instance = data.ability_script.new()
		print("Ability script instance: ", ability_script_instance)

		if ability_script_instance != null:
			ability_script_instance.execute(data, self, CombatScene)