# Base for all game buttons: icon/label/background setup, its own tooltip,
# and a visual state for availability
extends Button
class_name GameButton

enum VisualState {
	AVAILABLE,
	USED,         # Single-use action already spent this turn (e.g. Attack, Move at 0)
	UNAFFORDABLE, # Not enough AP
	UNAVAILABLE,  # Not usable right now (e.g. enemy turn)
}

@onready var sprite = $ButtonIcon
@onready var label = $Label
@onready var background = $ButtonBackground

@export var background_texture: Texture = null
@export var icon_sheet: Texture = null

@export var hframes: int = 0
@export var vframes: int = 0
@export var icon_x: int = 0
@export var icon_y: int = 0

@export var label_text: String = ""

# Set for action buttons (Move, Attack, abilities) to drive the tooltip
var ability: Ability
var unit: Unit

var visual_state := VisualState.AVAILABLE

func _ready() -> void:
	if icon_sheet != null and sprite != null:
		sprite.texture = icon_sheet
		sprite.hframes = hframes
		sprite.vframes = vframes
		sprite.frame_coords = Vector2i(icon_x, icon_y)

	if label_text != "" and label != null:
		label.text = label_text

	if background_texture != null:
		background.texture = background_texture

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_visual_state(state: VisualState) -> void:
	visual_state = state
	disabled = state != VisualState.AVAILABLE
	_apply_visual_state()

# Hook for per-state visuals (see Todos: unique visuals for used single-use
# actions and for not enough AP). Currently all non-available states just look disabled
func _apply_visual_state() -> void:
	pass

# [title, body] to show on hover, or [] for no tooltip
func get_tooltip_content() -> Array:
	if ability == null or unit == null:
		return []
	return [ability.name, AbilityEffect.create_for_tooltip(ability, unit).get_tooltip_cost(), AbilityEffect.create_for_tooltip(ability, unit).get_tooltip_body()]

func _on_mouse_entered() -> void:
	var content = get_tooltip_content()
	if not content.is_empty():
		TooltipManager.show_tooltip(content[0], content[1], content[2])

func _on_mouse_exited() -> void:
	TooltipManager.hide_tooltip()
