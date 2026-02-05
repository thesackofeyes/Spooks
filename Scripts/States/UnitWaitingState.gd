extends "res://scripts/states/state.gd"

func enter(unit: Node) -> void:
	# Called when the unit enters the waiting state
	print("%s is now waiting" % unit.name)

func update(unit: Node, delta: float) -> void:
	# Do nothing while waiting
	pass

func exit(unit: Node) -> void:
	# Called when the unit leaves waiting state
	print("%s is no longer waiting" % unit.name)
