# res://states/State.gd
extends RefCounted  # Use RefCounted instead of Reference in Godot 4.6

func enter(unit: Node) -> void:
	pass

func exit(unit: Node) -> void:
	pass

func update(unit: Node, delta: float) -> void:
	pass
