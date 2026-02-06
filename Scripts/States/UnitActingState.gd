# res://states/UnitActingState.gd
extends "res://scripts/states/state.gd"

var action_completed: bool = false  # tracks if the unit finished acting
var action_timer: float = 0.0       # optional delay for animations

func enter(unit: Node) -> void:
	print("%s is now acting!" % unit.name)
	action_completed = false

func update(unit: Node, delta: float) -> void:
	if not action_completed:
		print ("ACTION")
		action_completed = true
		unit.change_state("Waiting")  # after acting

func exit(unit: Node) -> void:
	print("%s finished acting" % unit.name)
	# Stop animation or reset as needed
	if unit.has_node("AnimatedSprite2D"):
		var sprite = unit.get_node("AnimatedSprite2D")
		sprite.stop()
