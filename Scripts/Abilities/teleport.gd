# Instantly moves the caster to any unoccupied tile
extends AbilityEffect

func _init() -> void:
	colour = MOVEMENT_COLOUR

# Teleport always lands exactly on the target
func get_destination(target: Vector2i) -> Vector2i:
	return target

func validate_target(target: Vector2i) -> String:
	if not combat.is_cell_free(target):
		return "Cannot teleport onto an occupied tile"
	return ""

func execute(target: Vector2i) -> void:
	combat.place_unit(caster, target)
