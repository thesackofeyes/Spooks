# Basic attack. Damage and range come from the caster's stats, so each unit
# keeps its own reach while sharing the same attack ability
extends AbilityEffect

func _init() -> void:
	colour = DAMAGE_COLOUR

func get_range() -> int:
	return caster.data.base_attack_range

func get_damage() -> int:
	return caster.data.base_attack_damage

func get_preview_cells(target: Vector2i) -> Array:
	# Line includes the caster's cell, hence + 1
	return Utils.get_line_cells(caster.get_cell(), target).slice(0, get_range() + 1)

func validate_target(target: Vector2i) -> String:
	if Utils.grid_distance(caster.get_cell(), target) > get_range():
		return "Attacking out of range"
	if not combat.has_line_of_sight(caster.get_cell(), target):
		return "No line of sight to target"

	var target_unit = combat.get_unit_at_cell(target)
	if target_unit == null:
		return "Attacking an empty tile"
	if target_unit.data.player_unit == caster.data.player_unit:
		return "Cannot attack unit on the same side"
	return ""

func execute(target: Vector2i) -> void:
	combat.get_unit_at_cell(target).process_damage(get_damage(), caster)
	caster.has_attacked = true
