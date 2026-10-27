# Ranged token-damage attack that adds a stack of Slowed (fewer moves and less AP next turn)
# and a stack of Weakened (more damage taken for the rest of the fight).
# Doesn't use up the caster's basic attack
extends "res://Scripts/Abilities/attack_effect.gd"

func get_tooltip_body() -> String:
	return ability.description + "\nDamage: " + str(get_damage()) + "\nRange: " + str(get_range()) \
		+ "\n+1 Slowed (-%d moves, -%d AP next turn)\n+1 Weakened" % [Unit.SLOWED_MOVE_PENALTY, Unit.SLOWED_AP_PENALTY]

func execute(target: Vector2i) -> void:
	var target_unit = combat.get_unit_at_cell(target)
	# Damage before stacking, so this hit isn't boosted by its own Weakened
	target_unit.process_damage(get_damage(target_unit), caster)
	if target_unit.is_defeated():
		return
	target_unit.slowed_stacks += 1
	target_unit.weakened_stacks += 1
