extends Node2D
@onready var tilemap_node := $Grid
@onready var hover_grid : HoverGrid = $HoverGrid
@onready var obstacles_tilemap := $"Grid/Obstacles"
@onready var move_button := $MoveButton
@onready var abilities_container := $Abilities
@export var unit_scene: PackedScene = load("res://Scenes/unit.tscn")

var player_units: Array = []
var current_unit
var previous_unit
var available_movement
var available_ap

var action = ''

func _ready() -> void:
	# For multiple units, use unit position (0/1,0/1 stored on unit stats storage)
	var start_square = Vector2i(GameConfig.grid_width - 1, GameConfig.grid_height - 1)
	var units = SaveManager.data.units
	
	for unit in units:
		var new_unit := unit_scene.instantiate() as Unit
		new_unit.data = unit
		
		player_units.append(new_unit)
		add_child(new_unit)
		
		var new_unit_start = start_square - new_unit.data.start_position
		move_to(new_unit, new_unit_start, 0)
	
	current_unit = player_units[0]
	TurnManager.start_battle(player_units)
	hover_grid.clicked.connect(_on_grid_clicked)

func _process(delta: float) -> void:
	if current_unit != previous_unit:
		available_ap = current_unit.data.stamina
		available_movement = current_unit.data.speed
		previous_unit = current_unit
		abilities_container.update_abilites(current_unit.data.abilities)
	
	current_unit = TurnManager.current_unit
	draw_traversable_path(current_unit)
	$CharacterPortrait.update_moves(available_movement)
	$CharacterPortrait.update_ap(available_ap)
	

func draw_traversable_path(unit):
	if action == 'movement':
		hover_grid.set_overlay_path(Pathfinding.astar_find_path(tilemap_node, obstacles_tilemap, unit.position, hover_grid.hover_cell))
		hover_grid.overlay_distance = available_movement
	else:
		hover_grid.overlay_distance = 0

func move_to(unit, destination, speed, distance_cap: int = -1):
	action = ''
	if move_button.is_pressed():
		move_button.set_pressed(false)

	var destination_local_pos = Utils.cell_to_local(Vector2i(destination))
	var destination_grid_pos = tilemap_node.position + destination_local_pos
	
	# Teleport
	if speed == 0:
		var tween := create_tween()
		tween.tween_property(unit, "position", destination_grid_pos, speed)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)

	#Walk
	if speed > 0:
		var path = Pathfinding.astar_find_path(tilemap_node, obstacles_tilemap, unit.position, destination)
		var number_of_tiles_moved = path.size() - 1
		if distance_cap < number_of_tiles_moved:
			number_of_tiles_moved = distance_cap
		available_movement -= number_of_tiles_moved
		tween_along_path(unit, path, 0.4, distance_cap)

func _on_grid_clicked(visual_cell: Vector2i):
	if visual_cell == Vector2i(-1, -1):
		return
	if action == 'movement':
		move_to(current_unit, visual_cell, 1.1, available_movement)

# Moves a unit along a path of Vector2i tiles using Tweens
func tween_along_path(unit: Node2D, path: Array, speed: float, distance_cap: int, overlap: float = -0.5):
	if path.size() == 0:
		return

	var tween := create_tween()
	tween.set_parallel(false)

	for i in range(path.size()):
		if distance_cap != -1 and distance_cap < i:
			break
		
		var cell = Utils.local_to_cell(Utils.tilemap_cell_to_local(tilemap_node, path[i]))
		var destination = Utils.cell_to_local(cell)
		
		# Move unit to next tile
		tween.tween_property(unit, "position", destination, speed)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)

		# If overlap > 0, slightly reduce pause before next tween
		if overlap > 0 and i < path.size() - 1:
			tween.tween_interval(overlap)

func _on_button_toggled(toggled_on: bool, source: BaseButton, extra_arg_0: String) -> void:
	if toggled_on == true:
		action = extra_arg_0
	else:
		action = ''


func _on_end_turn_pressed(extra_arg_0: String) -> void:
	TurnManager.end_turn()
	
	
