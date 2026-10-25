# Dash 0-2 tiles towards a target in a straight line, then circle one step
# counter-clockwise around it and strike from its flank.
# The route is fixed by the target, so any blocked tile (including the sidestep) invalidates it
extends "res://Scripts/Abilities/attack_effect.gd"

const MAX_DASH := 2
const DIRECTIONS := [Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 1)]

# Counter-clockwise as seen on screen. The isometric projection mirrors the grid's
# handedness, so this is the opposite of the textbook (-y, x) rotation
static func rotate_ccw(dir: Vector2i) -> Vector2i:
	return Vector2i(dir.y, -dir.x)

# Cells the caster moves through, starting with their own and ending on the strike tile.
# [] if the target isn't 1 to MAX_DASH + 1 tiles away in a straight line
func get_route(target: Vector2i) -> Array:
	var start = caster.get_cell()
	for forward in DIRECTIONS:
		for dash in range(MAX_DASH + 1):
			if start + forward * (dash + 1) != target:
				continue
			var route = []
			for i in range(dash + 1):
				route.append(start + forward * i)
			# Caster is beside the target at -forward; a quarter turn CCW around it
			# puts them at -rotate_ccw(forward), one diagonal step away
			route.append(target - rotate_ccw(forward))
			return route
	return []

# The basic attack's tooltip omits cost, and its range would read as 1 despite the dash
func get_tooltip_body() -> String:
	return ability.description + "\nDamage: " + str(get_damage()) \
		+ "\nReach: " + str(MAX_DASH + 1) + " tiles"

func get_preview_cells(target: Vector2i) -> Array:
	var route = get_route(target)
	return route + [target] if not route.is_empty() else []

func get_destination(target: Vector2i) -> Vector2i:
	var route = get_route(target)
	return route.back() if not route.is_empty() else NO_CELL

func validate_target(target: Vector2i) -> String:
	var route = get_route(target)
	if route.is_empty():
		return "Target must be in a straight line, up to " + str(MAX_DASH + 1) + " tiles away"
	# Skip the caster's own cell
	for i in range(1, route.size()):
		if not combat.is_cell_free(route[i]):
			return "Sidestep blocked" if i == route.size() - 1 else "Dash blocked"
	return validate_attack(route.back(), target)

func execute(target: Vector2i) -> void:
	# The caster's own cell is dropped so the dash doesn't open with a pause in place
	var route = get_route(target).slice(1)
	var tween = combat.tween_along_path(caster, route, get_step_duration(), -1, -0.5, Tween.TRANS_LINEAR)
	await tween.finished
	combat.get_unit_at_cell(target).process_damage(get_damage(), caster)
