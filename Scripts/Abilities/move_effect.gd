# Walks along a path, up to the caster's remaining moves.
# Unreachable targets walk as close as possible rather than being rejected
extends AbilityEffect

func _init() -> void:
	colour = MOVEMENT_COLOUR

func get_tooltip_body() -> String:
	return str(caster.current_moves) + " Tiles"

func get_preview_cells(target: Vector2i) -> Array:
	# Path includes the starting cell, hence + 1
	return combat.find_walk_path(caster, target).slice(0, caster.current_moves + 1)

# The last tile of the capped path - where the walk stops, even when the target is out of reach
func get_destination(target: Vector2i) -> Vector2i:
	var preview = get_preview_cells(target)
	return preview.back() if not preview.is_empty() else NO_CELL

func execute(target: Vector2i) -> void:
	caster.current_moves -= await combat.walk_unit(caster, target, caster.current_moves)
