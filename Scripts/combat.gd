extends Node2D

@onready var spook := get_node('Spook')
@onready var tilemap_node := get_node('Grid')
@onready var hover_grid : HoverGrid = $HoverGrid
@onready var move_button := get_node('MoveButton')

@onready var current_unit = spook #This needs to update to be dyamic to 'current unit' based on turns

var action = ''


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	# For multiple units, use unit position (0/1,0/1 stored on unit stats storage)
	var start_square = Vector2(GameConfig.grid_width - 1, GameConfig.grid_height - 1)
	move_to(current_unit, start_square, 0)
	hover_grid.clicked.connect(_on_grid_clicked)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	draw_traversable_path(spook, 3)

func draw_traversable_path(unit, distance):
	if action == 'movement':
		hover_grid.set_overlay_path(find_path(hover_grid.local_to_cell(unit.position), hover_grid.hover_cell))
		hover_grid.overlay_distance = distance
	else:
		hover_grid.overlay_distance = 0

func move_to(unit, destination, speed, distance_cap: int = -1):
	action = ''
	if move_button.is_pressed():
		move_button.set_pressed(false)
	# Update to path around obstacles - this should work, just need to add 'validity' to tiles

	var destination_local_pos = hover_grid.cell_to_local(Vector2i(destination))
	var destination_grid_pos = tilemap_node.position + destination_local_pos
	
	# Teleport
	if speed == 0:
		var tween := create_tween()
		tween.tween_property(unit, "position", destination_grid_pos, speed)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)

	#Walk
	if speed > 0:
		var path = find_path(hover_grid.local_to_cell(unit.position), destination)
		tween_along_path(unit, path, 0.4, distance_cap)

func _on_grid_clicked(cell: Vector2i):
	if action == 'movement':
		move_to(current_unit, cell, 1.1, SaveManager.data.units[0].speed)


# -----------------------------
# A* Pathfinding for 2D Tile Grids
# Returns an Array of Vector2i coordinates
# -----------------------------

# Main function
func find_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var open_set := [start]
	var came_from := {} # Vector2i -> Vector2i
	var g_score := {start: 0.0}
	var f_score := {start: heuristic(start, goal)}

	while open_set.size() > 0:
		# pick node with lowest f_score
		var current : Vector2i = open_set[0]
		for node in open_set:
			if f_score.get(node, INF) < f_score.get(current, INF):
				current = node
		open_set.erase(current)

		# goal reached
		if current == goal:
			return reconstruct_path(came_from, current)

		# evaluate neighbors
		for neighbor in get_neighbors(current):
			var tentative_g = g_score.get(current, INF) + 1 # cost per tile
			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + heuristic(neighbor, goal)
				if neighbor not in open_set:
					open_set.append(neighbor)

	# no path found
	return []

# -----------------------------
# Heuristic (Manhattan for 4-dir grid)
func heuristic(a: Vector2i, b: Vector2i) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

# -----------------------------
# Reconstruct path from came_from dictionary
func reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path : Array[Vector2i] = [current]
	while current in came_from:
		current = came_from[current]
		path.insert(0, current)
	return path

# -----------------------------
# Get neighbors for 4-directional grid
func get_neighbors(pos: Vector2i) -> Array:
	return [
		pos + Vector2i(1, 0),
		pos + Vector2i(-1, 0),
		pos + Vector2i(0, 1),
		pos + Vector2i(0, -1)
	]

# Moves a unit along a path of Vector2i tiles using Tweens
func tween_along_path(unit: Node2D, path: Array, speed: float, distance_cap: int, overlap: float = -0.5):
	if path.size() == 0:
		return

	var tween := create_tween()
	tween.set_parallel(false) # sequential

	for i in range(path.size()):
		if distance_cap != -1 and distance_cap < i:
			break
		var cell = path[i]
		var local_pos = hover_grid.cell_to_local(cell)
		var destination = tilemap_node.position + local_pos

		# Move unit to next tile
		tween.tween_property(unit, "position", destination, speed)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)

		# If overlap > 0, slightly reduce pause before next tween
		if overlap > 0 and i < path.size() - 1:
			tween.tween_interval(overlap)

func _on_button_toggled(toggled_on: bool, source: BaseButton, extra_arg_0: String) -> void:
	print("Movement Button State: ", toggled_on, source, extra_arg_0)
	if toggled_on == true:
		action = extra_arg_0
