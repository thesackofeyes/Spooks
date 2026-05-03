extends Node2D
class_name Unit

@export var data: UnitData

@onready var sprite = $Sprite2D
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
		"Idle": preload("res://Scripts/States/UnitIdleState.gd").new(),
		"Acting": preload("res://Scripts/States/UnitActingState.gd").new(),
		"Waiting": preload("res://Scripts/States/UnitWaitingState.gd").new()
	}
	current_state = state_machine["Waiting"]
	current_hp = data.base_hp

func start_turn():
	change_state("Idle")

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

func unit_defeated(attacker: Unit):
	print("Unit ", data.unit_class, data.unit_subclass, " has been defeated by ", attacker.data.unit_class, attacker.data.unit_subclass, ".")
	visible = false # Currently hides, can be converted to a death animation or similar in the future

	if data.player_unit:
		print("Player unit defeated. Check for game over conditions.")

	if !data.player_unit:
		attacker.data.current_xp += data.experience_reward
		print("Attacker ", attacker.data.unit_class, attacker.data.unit_subclass, " gains ", data.experience_reward, " XP. Total XP: ", attacker.data.current_xp)
		
	combat_node.check_combat_end_conditions()


func input_received() -> bool:
	# For example: press "Enter" or "Space" to act
	return Input.is_action_just_pressed("ui_accept")

func _process(delta):
	if current_state != state_machine["Waiting"]:
		current_state.update(self, delta)
