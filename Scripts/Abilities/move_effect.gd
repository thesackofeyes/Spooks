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

# Blue only if the walk would actually end on the hovered tile
func get_hover_colour(target: Vector2i) -> Color:
	var preview = get_preview_cells(target)
	if not preview.is_empty() and preview.back() == target:
		return DESTINATION_COLOUR
	return colour

func execute(target: Vector2i) -> void:
	caster.current_moves -= combat.walk_unit(caster, target, caster.current_moves)
