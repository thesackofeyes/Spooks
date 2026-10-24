extends Node2D
class_name Unit

@export var data: UnitData

const DEFEATED_MODULATE := Color(0.4, 0.4, 0.4, 0.6)

@onready var sprite = $Sprite2D
@onready var sprite_animation_player = $Sprite2D/AnimationPlayer
@onready var combat_node = get_parent().get_parent()
var state_machine: Dictionary = {}
var current_state

var current_hp: int
var current_ap: int
var current_moves: int

func _ready() -> void:
	sprite.texture = data.sprite
	sprite.hframes = data.sprite_h_frames if data.sprite_h_frames > 0 else 1
	sprite.vframes = data.sprite_v_frames if data.sprite_v_frames > 0 else 1
	sprite.frame = data.icon_y * sprite.hframes + data.icon_x
	sprite.scale = Vector2(data.sprite_scale, data.sprite_scale)
	state_machine = {
		"Idle": UnitIdleState.new(),
		"Acting": UnitActingState.new(),
		"Waiting": UnitWaitingState.new()
	}
	current_state = state_machine["Waiting"]
	current_hp = data.base_hp

func start_turn():
	change_state("Idle")
	sprite_animation_player.play("active_unit")

func end_turn():
	sprite_animation_player.stop()
	TurnManager.end_turn()

func change_state(new_state: String):
	if current_state != null:
		current_state.exit(self)
	current_state = state_machine[new_state]
	current_state.enter(self)

func process_damage(amount: int, attacker: Unit):
	var updated_hp = current_hp - amount
	current_hp = max(updated_hp, 0)
	print("Unit ", data.unit_class, data.unit_subclass, " takes ", amount, " damage from ", attacker.data.unit_class, attacker.data.unit_subclass, ". Updated HP: ", current_hp)

	if current_hp <= 0:
		unit_defeated(attacker)

func is_defeated() -> bool:
	return current_hp <= 0

func unit_defeated(attacker: Unit):
	print("Unit ", data.unit_class, data.unit_subclass, " has been defeated by ", attacker.data.unit_class, attacker.data.unit_subclass, ".")
	# Leave a dimmed corpse; it no longer blocks movement, can't be targeted and gets no turns.
	# Can be converted to a death animation or similar in the future
	modulate = DEFEATED_MODULATE
	change_state("Waiting")
	
	# keeps living units drawn over the corpse when sharing a tile
	get_parent().move_child(self, 0)

	if data.player_unit:
		print("Player unit defeated. Check for game over conditions.")

	if !data.player_unit:
		attacker.data.current_xp += data.experience_reward
		print("Attacker ", attacker.data.unit_class, attacker.data.unit_subclass, " gains ", data.experience_reward, " XP. Total XP: ", attacker.data.current_xp)
		
	combat_node.check_combat_end_conditions()

func update_ap(value: int):
	current_ap = max(current_ap + value, 0)
	combat_node.unpress_ability_buttons()
	combat_node.load_ability_buttons()

func _process(delta):
	if current_state != state_machine["Waiting"]:
		current_state.update(self, delta)
