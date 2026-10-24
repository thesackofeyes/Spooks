# Instantly moves the caster to any unoccupied tile
extends AbilityEffect

func _init() -> void:
	colour = MOVEMENT_COLOUR

# Only called for valid targets, which teleport always lands on exactly
func get_hover_colour(_target: Vector2i) -> Color:
	return DESTINATION_COLOUR

func validate_target(target: Vector2i) -> String:
	if not combat.is_cell_free(target):
		return "Cannot teleport onto an occupied tile"
	return ""

func execute(target: Vector2i) -> void:
	combat.place_unit(caster, target)
