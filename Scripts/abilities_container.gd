extends Node2D

@onready var ability_container = $VBoxContainer
@onready var ability_button_scene: PackedScene = preload("res://Scenes/ability_button.tscn")

func _ready() -> void:
	pass

func update_abilites(abilities):
	# Clear existing ability buttons
	for child in ability_container.get_children():
		child.queue_free()

	if abilities.size() > 0:
		for i in range(abilities.size()):
			var ability_button := ability_button_scene.instantiate() as AbilityButton
			ability_button.data = abilities[i]
			var label = ability_button.get_node('Name')
			var icon = ability_button.get_node('ButtonIcon')
			label.text = abilities[i].name
			icon.frame = abilities[i].icon_y * icon.hframes + abilities[i].icon_x
			
			ability_container.add_child(ability_button)
