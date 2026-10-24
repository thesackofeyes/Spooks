extends Node2D

const ABILITY_BUTTON_SCENE := preload("res://Scenes/ability_button.tscn")

@onready var ability_container = $VBoxContainer

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
			icon.frame = unit.data.abilities[i].icon_y * icon.hframes + unit.data.abilities[i].icon_x

			if unit.data.abilities[i].cost > unit.current_ap:
				ability_button.disabled = true

			ability_container.add_child(ability_button)
