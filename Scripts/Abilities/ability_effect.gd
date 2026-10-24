# Base for everything a unit can do on the grid: Move, Attack and abilities.
# An Ability resource points at a script extending this via ability_script.
# Combat creates one when the action's button is pressed, asks it what to
# preview and whether a target is valid, then executes it on click.
extends RefCounted
class_name AbilityEffect

const MOVEMENT_COLOUR := Color(1, 1, 0)
const DESTINATION_COLOUR := Color(0, 0, 1) # Hovered tile the unit will end up on
const DAMAGE_COLOUR := Color(0, 0, 0)
const INVALID_COLOUR := Color(1, 0, 0)

var ability: Ability # Data for this action (name, cost, range, damage...)
var caster: Unit
var combat # Combat scene, for grid queries like get_unit_at_cell or has_line_of_sight

# Preview colour (and default hover colour) when the target is valid
var colour := DAMAGE_COLOUR

func setup(p_ability: Ability, p_caster: Unit, p_combat) -> void:
	ability = p_ability
	caster = p_caster
	combat = p_combat

# Grid cells to highlight while hovering a target, already capped to range. [] for none
func get_preview_cells(_target: Vector2i) -> Array:
	return []

# Colour of the hovered tile itself when the target is valid (preview cells use colour)
func get_hover_colour(_target: Vector2i) -> Color:
	return colour

# "" if the target is valid, otherwise the reason it isn't (the action stays selected)
func validate_target(_target: Vector2i) -> String:
	return ""

# Carries out the action on a validated target. Combat charges get_cost() afterwards
func execute(_target: Vector2i) -> void:
	pass

func get_cost() -> int:
	return ability.cost if ability != null else 0
