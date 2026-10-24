extends Node2D
class_name HoverGrid

signal clicked(visual_cell: Vector2i)

const DEFAULT_HOVER_COLOUR := Color(1, 1, 1) # No action selected
const FILL_ALPHA := 0.25
const OUTLINE_WIDTH := 2

var hover_cell := Vector2i.ZERO

# Set by Combat from the selected action and whether the hovered target is valid
var hover_colour := DEFAULT_HOVER_COLOUR
var overlay_colour := DEFAULT_HOVER_COLOUR
var overlay_path: Array[Vector2i] = [] # Grid cells

func _ready():
	z_index = 100 # Always draw on top

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

	# if outside of grid bounds, do nothing
	if x < 0 or x >= GameConfig.grid_width or y < 0 or y >= GameConfig.grid_height:
		return Vector2i(-1, -1)

	return Vector2i(x, y)

# Takes grid cells; callers convert from tilemap cells first
func set_overlay_path(cells: Array) -> void:
	overlay_path.assign(cells)
	queue_redraw()

# Draws a translucent diamond with a solid outline over a grid cell
func _draw_tile(cell: Vector2i, colour: Color) -> void:
	var half = GameConfig.tile_size / 2
	var origin = Utils.cell_to_local(cell)
	var points = PackedVector2Array([
		origin + Vector2(0, -half.y),
		origin + Vector2(half.x, 0),
		origin + Vector2(0, half.y),
		origin + Vector2(-half.x, 0),
	])

	draw_colored_polygon(points, Color(colour, FILL_ALPHA))
	draw_polyline(points + PackedVector2Array([points[0]]), colour, OUTLINE_WIDTH)

func _draw():
	if hover_cell == Vector2i(-1, -1):
		return

	# Movement path / attack line. Skips the hovered cell so its colour isn't blended
	for cell in overlay_path:
		if cell != hover_cell:
			_draw_tile(cell, overlay_colour)

	_draw_tile(hover_cell, hover_colour)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(get_mouse_cell())
