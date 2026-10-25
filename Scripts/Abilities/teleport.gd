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

# Instant at movement_speed -1, otherwise one straight glide to the target taking a single step's duration
func execute(target: Vector2i) -> void:
	var duration = get_step_duration()
	if duration <= 0:
		combat.place_unit(caster, target)
	else:
		await combat.tween_along_path(caster, [target], duration, -1).finished
