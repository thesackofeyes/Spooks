# TurnManager.gd
extends Node

signal turn_started(unit)
signal round_started(round_number: int)

var units: Array = []
var current_index: int = 0
var current_unit: Node = null
var round_number: int = 0
var initiatives: Dictionary = {} # Unit -> int, re-rolled each round

func start_battle(unit_list: Array) -> void:
	units = unit_list.duplicate()
	round_number = 0
	# Set all units to waiting first
	for unit in units:
		unit.change_state("Waiting")

	start_round()

func start_round() -> void:
	# Without a living unit, skipping defeated turns would loop forever
	if units.all(func(unit): return unit.is_defeated()):
		print("No living units to take turns!")
		return

	round_number += 1
	current_index = 0

	# Roll once per unit so the sort compares fixed values
	initiatives.clear()
	for unit in units:
		initiatives[unit] = roll_initiative(unit)

	units.sort_custom(_sort_by_initiative)

	print("Round ", round_number)
	for unit in units:
		print("Turn order: ", unit.data.unit_class, unit.data.unit_subclass, " (initiative ", initiatives[unit], ")")

	round_started.emit(round_number)
	start_turn()

func roll_initiative(unit) -> int:
	return round((unit.data.dexterity * 1.2) + (unit.data.resolve * 0.6) + (randi() % 10 * 0.3))

func _sort_by_initiative(a, b) -> bool:
	return initiatives[a] > initiatives[b]  # Sort in descending order

func start_turn() -> void:
	if units.is_empty():
		print("No units to take turns!")
		return
	current_unit = units[current_index]

	# if current unit is defeated, skip turn and move to next unit
	# (checked before start_turn so corpses don't play the active animation)
	if current_unit.is_defeated():
		print("Current unit ", current_unit.data.unit_class, current_unit.data.unit_subclass,
			" is defeated. Skipping turn.")
		end_turn()
		return

	current_unit.start_turn()  # sets state to Idle
	turn_started.emit(current_unit)

	# if current unit is an enemy, trigger AI behavior here

func end_turn() -> void:
	if units.is_empty():
		return
	# Move to next unit, starting a new round once everyone has acted
	current_index += 1
	if current_index >= units.size():
		start_round()
	else:
		start_turn()
