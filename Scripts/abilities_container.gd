extends Node2D

@onready var ability_container = $VBoxContainer
@onready var ability_button_scene: PackedScene = preload("res://Scenes/ability_button.tscn")

func _ready() -> void:
	pass

func update_abilites(unit):
	# Clear existing ability buttons
	for child in ability_container.get_children():
		child.queue_free()

	if unit.data.abilities.size() > 0:
		for i in range(unit.data.abilities.size()):
			var ability_button := ability_button_scene.instantiate() as AbilityButton
			ability_button.data = unit.data.abilities[i]
			var label = ability_button.get_node('Name')
			var icon = ability_button.get_node('ButtonIcon')
			label.text = unit.data.abilities[i].name
			icon.frame = unit.data.abilities[i].icon_y * icon.hframes + unit.data.abilities[i].icon_x

			print("Ability Cost", unit.data.abilities[i].cost)

			if unit.data.abilities[i].cost > unit.current_ap:
				ability_button.disabled = true
			
			ability_container.add_child(ability_button)
