# UnitIdleState.gd
extends "res://scripts/states/state.gd"

func enter(unit: Node) -> void:
	print("%s is idle" % unit.name)

func update(unit: Node, delta: float) -> void:
	if unit.input_received():
		unit.change_state("Acting")
