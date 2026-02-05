extends Node2D
class_name Unit

@export var data: UnitData

@onready var sprite = $Sprite2D

var state_machine: Dictionary = {}
var current_state

func _ready() -> void:
	print("Unit: ", data.sprite)
	
	sprite.texture = data.sprite
	sprite.hframes = data.sprite_h_frames
	sprite.vframes = data.sprite_v_frames
	sprite.frame = data.icon_y * sprite.hframes + data.icon_x
	state_machine = {
		"Idle": preload("res://Scripts/States/UnitIdleState.gd").new(),
		"Acting": preload("res://Scripts/States/UnitActingState.gd").new(),
		"Waiting": preload("res://Scripts/States/UnitWaitingState.gd").new()
	}
	current_state = state_machine["Waiting"]

func start_turn():
	print("%s is starting its turn!" % name)
	change_state("Idle")

func change_state(new_state: String):
	if current_state != null:
		current_state.exit(self)
	current_state = state_machine[new_state]
	current_state.enter(self)

func input_received() -> bool:
	# For example: press "Enter" or "Space" to act
	return Input.is_action_just_pressed("ui_accept")

func _process(delta):
	if current_state != state_machine["Waiting"]:
		current_state.update(self, delta)
