extends Node2D
class_name HoverGrid

@onready var CombatScene = get_tree().get_current_scene().get_node("Combat")

signal clicked(visual_cell: Vector2i)

const HOVER_COLOUR := Color(1, 0, 0)
const MOVEMENT_HOVER_COLOUR := Color(0, 0, 1)
const PATH_COLOUR := Color(1, 1, 0)
const FILL_ALPHA := 0.25
const OUTLINE_WIDTH := 2

var hover_cell := Vector2i.ZERO

var overlay_path: Array[Vector2i] = [] # Grid cells
var overlay_distance := 0

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

	# Current mouse hover: blue while moving, red otherwise
	if CombatScene.action == 'movement':
		_draw_tile(hover_cell, MOVEMENT_HOVER_COLOUR)
	else:
		_draw_tile(hover_cell, HOVER_COLOUR)

	# Movement path / attack line
	if overlay_distance > 0:
		for i in range(overlay_path.size()):
			if i > overlay_distance:
				break
			_draw_tile(overlay_path[i], PATH_COLOUR)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(get_mouse_cell())
