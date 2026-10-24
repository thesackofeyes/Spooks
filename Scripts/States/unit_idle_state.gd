extends State
class_name UnitIdleState

func enter(unit: Node) -> void:
	pass

func update(unit: Node, delta: float) -> void:
	# Player input is handled by the combat UI; enemy AI can drive transitions from here later
	pass
