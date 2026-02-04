extends Node2D

@onready var spook := get_node('Spook')
@onready var tilemap_node := $Grid
@onready var hover_grid : HoverGrid = $HoverGrid
@onready var obstacles_tilemap := $"Grid/Obstacles"
@onready var move_button := $MoveButton

@onready var current_unit = spook #This needs to update to be dyamic to 'current unit' based on turns

var action = ''

func _ready() -> void:
	# For multiple units, use unit position (0/1,0/1 stored on unit stats storage)
	var start_square = Vector2(GameConfig.grid_width - 1, GameConfig.grid_height - 1)
	move_to(current_unit, start_square, 0)
	hover_grid.clicked.connect(_on_grid_clicked)

func _process(delta: float) -> void:
	draw_traversable_path(spook, 3)

func draw_traversable_path(unit, distance):
	if action == 'movement':
		hover_grid.set_overlay_path(Pathfinding.astar_find_path(tilemap_node, obstacles_tilemap, unit.position, hover_grid.hover_cell))
		hover_grid.overlay_distance = distance
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
		tween_along_path(unit, path, 0.4, distance_cap)

func _on_grid_clicked(visual_cell: Vector2i):
	if visual_cell == Vector2i(-1, -1):
		return
	if action == 'movement':
		move_to(current_unit, visual_cell, 1.1, SaveManager.data.units[0].speed)

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
