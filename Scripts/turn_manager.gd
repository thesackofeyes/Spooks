# TurnManager.gd
extends Node

var units: Array = []
var current_index: int = 0
var current_unit: Node = null

func start_battle(unit_list: Array) -> void:
	units = unit_list.duplicate()
	current_index = 0
	# Set all units to waiting first
	for unit in units:
		unit.change_state("Waiting")

	units.sort_custom(_sort_by_initiative)
	start_turn()

func _sort_by_initiative(a, b):
	var initiative_a = round((a.data.dexterity * 1.2) + (a.data.resolve * 0.6) + (randi() % 10 * 0.3))
	var initiative_b = round((b.data.dexterity * 1.2) + (b.data.resolve * 0.6) + (randi() % 10 * 0.3))
	return initiative_b - initiative_a  # Sort in descending order

func start_turn() -> void:
	if units.is_empty():
		print("No units to take turns!")
		return
	current_unit = units[current_index]
	current_unit.start_turn()  # sets state to Idle
	print("It's %s's turn!" % current_unit.name)

func end_turn() -> void:
	if units.is_empty():
		return
	# Move to next unit
	current_index = (current_index + 1) % units.size()
	start_turn()
