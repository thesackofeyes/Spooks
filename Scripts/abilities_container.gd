extends Node2D

const ABILITY_BUTTON_SCENE := preload("res://Scenes/ability_button.tscn")

signal ability_toggled(ability_button, toggled_on)

@onready var ability_container = $VBoxContainer

var button_group: ButtonGroup # Set by Combat so ability buttons share it with Move/Attack

# Rebuilds the buttons for a unit's abilities; called at the start of each turn
func update_abilities(unit):
	# Clear existing ability buttons
	for child in ability_container.get_children():
		child.queue_free()

	for ability in unit.data.abilities:
		var ability_button := ABILITY_BUTTON_SCENE.instantiate() as AbilityButton
		ability_button.setup(ability, unit)
		ability_button.button_group = button_group
		ability_button.ability_toggled.connect(ability_toggled.emit)
		ability_container.add_child(ability_button)

	refresh_affordability(unit)

# Disables every ability button, e.g. while the unit is mid-action
func set_unavailable():
	for ability_button in ability_container.get_children():
		ability_button.set_visual_state(GameButton.VisualState.UNAVAILABLE)

# Marks buttons for abilities the unit can't currently afford
func refresh_affordability(unit):
	for ability_button in ability_container.get_children():
		if ability_button.ability.cost > unit.current_ap:
			ability_button.set_visual_state(GameButton.VisualState.UNAFFORDABLE)
		else:
			ability_button.set_visual_state(GameButton.VisualState.AVAILABLE)
