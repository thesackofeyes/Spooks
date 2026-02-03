extends Node2D
class_name HoverGrid

@onready var tilemap_node := get_parent().get_node('Grid')
@onready var combat_node := get_parent()
signal clicked(cell: Vector2i)

var hover_cell := Vector2i.ZERO
var overlay_path: Array[Vector2i] = []
var overlay_distance := 0

func _ready():
	# Always draw on top
	z_index = 100

func _process(_delta):
	hover_cell = get_mouse_cell()
	queue_redraw()

func get_mouse_cell() -> Vector2i:
	var local_pos = to_local(get_global_mouse_position())

	# Shift by half tile height to align with diamond origin
	var half = GameConfig.tile_size / 2
	local_pos += Vector2(0, half.y)

	# Convert screen coordinates to isometric cell coordinates
	var x = floor((local_pos.y / half.y + local_pos.x / half.x) / 2)
	var y = floor((local_pos.y / half.y - local_pos.x / half.x) / 2)

	# Clamp to grid bounds
	x = clamp(x, 0, GameConfig.grid_width - 1)
	y = clamp(y, 0, GameConfig.grid_height - 1)
	return Vector2i(x, y)

func local_to_cell(pos: Vector2) -> Vector2i:
	var half = GameConfig.tile_size / 2.0

	var cx = (pos.x / half.x + pos.y / half.y) * 0.5
	var cy = (pos.y / half.y - pos.x / half.x) * 0.5

	return Vector2i(round(cx), round(cy))

func cell_to_local(cell: Vector2i) -> Vector2: 
	var half = GameConfig.tile_size / 2 
	return Vector2((cell.x - cell.y) * half.x, (cell.x + cell.y) * half.y)

func set_overlay_path(p: Array) -> void:
	overlay_path = p
	queue_redraw()

func _draw():
	#Draw Current Mouse Hover
	var half = GameConfig.tile_size / 2
	var origin = cell_to_local(hover_cell)

	var points = [
		origin + Vector2(0, -half.y),
		origin + Vector2(half.x, 0),
		origin + Vector2(0, half.y),
		origin + Vector2(-half.x, 0)
	]

	draw_colored_polygon(points, Color(1, 0, 0, 0.25))
	draw_polyline(points + [points[0]], Color(1, 0, 0), 2)
	
	#Draw Path (if movement selected)
	if overlay_distance > 0:
		for i in range(overlay_path.size()):
			if i > overlay_distance:
				break
			
			var destination = cell_to_local(overlay_path[i])
			points = [
				destination + Vector2(0, -half.y),
				destination + Vector2(half.x, 0),
				destination + Vector2(0, half.y),
				destination + Vector2(-half.x, 0)
			]
			
			draw_colored_polygon(points, Color(1, 2, 0, 0.25))
			draw_polyline(points + [points[0]], Color(1, 1, 0), 2)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("clicked", get_mouse_cell())
