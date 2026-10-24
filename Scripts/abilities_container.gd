extends Node2D

const ABILITY_BUTTON_SCENE := preload("res://Scenes/ability_button.tscn")

@onready var ability_container = $VBoxContainer

# Rebuilds the buttons for a unit's abilities; called at the start of each turn
func update_abilities(unit):
	# Clear existing ability buttons
	for child in ability_container.get_children():
		child.queue_free()

	if unit.data.abilities.size() > 0:
		for i in range(unit.data.abilities.size()):
			var ability_button := ABILITY_BUTTON_SCENE.instantiate() as AbilityButton
			ability_button.data = unit.data.abilities[i]
			var label = ability_button.get_node('Name')
			var icon = ability_button.get_node('ButtonIcon')
			label.text = unit.data.abilities[i].name
			icon.frame_coords = Vector2i(unit.data.abilities[i].icon_x, unit.data.abilities[i].icon_y)

			ability_container.add_child(ability_button)

	refresh_affordability(unit)

# Disables buttons for abilities the unit can't currently afford
func refresh_affordability(unit):
	for ability_button in ability_container.get_children():
		ability_button.disabled = ability_button.data.cost > unit.current_ap
