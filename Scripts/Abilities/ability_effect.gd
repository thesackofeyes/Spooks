# Base for everything a unit can do on the grid: Move, Attack and abilities.
# An Ability resource points at a script extending this via ability_script.
# Combat creates one when the action's button is pressed, asks it what to
# preview and whether a target is valid, then executes it on click.
extends RefCounted
class_name AbilityEffect

const MOVEMENT_COLOUR := Color(1, 1, 0)
const DESTINATION_COLOUR := Color(0, 0, 1) # Tile the caster will end up on
const DAMAGE_COLOUR := Color(0, 0, 0)
const INVALID_COLOUR := Color(1, 0, 0)

const NO_CELL := Vector2i(-1, -1)

var ability: Ability # Data for this action (name, cost, range, damage...)
var caster: Unit
var combat # Combat scene, for grid queries like get_unit_at_cell or has_line_of_sight

# Preview colour (and default hover colour) when the target is valid
var colour := DAMAGE_COLOUR

# Effect for an ability, or null if it has no script yet
static func create(p_ability: Ability, p_caster: Unit, p_combat) -> AbilityEffect:
	if p_ability.ability_script == null:
		return null
	var effect: AbilityEffect = p_ability.ability_script.new()
	effect.setup(p_ability, p_caster, p_combat)
	return effect

# For reading tooltip text only. Falls back to the base effect for abilities without a script
static func create_for_tooltip(p_ability: Ability, p_caster: Unit) -> AbilityEffect:
	var effect = create(p_ability, p_caster, null)
	if effect == null:
		effect = AbilityEffect.new()
		effect.setup(p_ability, p_caster, null)
	return effect

func setup(p_ability: Ability, p_caster: Unit, p_combat) -> void:
	ability = p_ability
	caster = p_caster
	combat = p_combat

# Tooltip body for this action's button. Title is the ability name
func get_tooltip_body() -> String:
	return ability.description

func get_tooltip_cost() -> String:
	return str(get_cost()) + " AP" if get_cost() > 0 else ""

# Grid cells to highlight while hovering a target, already capped to range. [] for none
func get_preview_cells(_target: Vector2i) -> Array:
	return []

# Cell the caster will end up on for a valid target, or NO_CELL if this action doesn't move them
func get_destination(_target: Vector2i) -> Vector2i:
	return NO_CELL

# "" if the target is valid, otherwise the reason it isn't (the action stays selected)
func validate_target(_target: Vector2i) -> String:
	return ""

# Carries out the action on a validated target. Combat charges get_cost() just before,
# and awaits this, so it can await tweens/animations
func execute(_target: Vector2i) -> void:
	pass

# Seconds per tile for movement this action animates, from the ability's movement_speed.
# 0 for instant movement
func get_step_duration() -> float:
	if ability == null or ability.movement_speed == 0:
		return combat.WALK_STEP_DURATION
	if ability.movement_speed < 0:
		return 0.0
	return combat.WALK_STEP_DURATION / ability.movement_speed

func get_cost() -> int:
	return ability.cost if ability != null else 0
