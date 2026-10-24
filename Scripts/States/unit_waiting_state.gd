extends State
class_name UnitWaitingState

func enter(unit: Node) -> void:
	# Called when the unit enters the waiting state
	pass

func update(unit: Node, delta: float) -> void:
	# Do nothing while waiting
	pass

func exit(unit: Node) -> void:
	# Called when the unit leaves waiting state
	pass
