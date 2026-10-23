# Utils.gd
extends Node

func local_to_cell(pos: Vector2) -> Vector2i:
	var half = GameConfig.tile_size / 2.0
	var cx = (pos.x / half.x + pos.y / half.y) * 0.5
	var cy = (pos.y / half.y - pos.x / half.x) * 0.5
	
	return Vector2i(round(cx), round(cy))

func cell_to_local(cell: Vector2i) -> Vector2: 
	var half = GameConfig.tile_size / 2 
	return Vector2((cell.x - cell.y) * half.x, (cell.x + cell.y) * half.y)

func tilemap_local_to_cell(tilemap: TileMapLayer, pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(pos)

func tilemap_cell_to_local(tilemap: TileMapLayer, cell: Vector2i) -> Vector2:
	return tilemap.map_to_local(cell)

func grid_cell_to_tilemap_cell(tilemap: TileMapLayer, cell: Vector2i) -> Vector2i:
	return tilemap_local_to_cell(tilemap, cell_to_local(cell))

# Tile distance on a 4-directional grid (Manhattan)
func grid_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

# Cells on a straight line between two cells, inclusive of both ends.
# 4-connected (one axis per step), so the number of steps equals grid_distance
# lines cannot slip diagonally between two touching obstacles
func get_line_cells(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var nx = abs(to.x - from.x)
	var ny = abs(to.y - from.y)
	var step = Vector2i(sign(to.x - from.x), sign(to.y - from.y))

	var current = from
	var cells: Array[Vector2i] = [current]
	var ix = 0
	var iy = 0
	while ix < nx or iy < ny:
		# Step along whichever axis keeps the line closest to the true diagonal
		if (1 + 2 * ix) * ny < (1 + 2 * iy) * nx:
			current.x += step.x
			ix += 1
		else:
			current.y += step.y
			iy += 1
		cells.append(current)
	return cells
	
	
# -----------------------------
# Whether a TILEMAP cell (not a grid cell) is inside the painted floor.
# The floor in combat.tscn is painted at tilemap x -1..8, y 0..9, because tilemap
# cells sit one column left of grid cells: tilemap (x, y) == grid (x + 1, y).
# Use grid_cell_to_tilemap_cell to convert rather than offsetting by hand
func is_valid_cell(cell: Vector2i) -> bool:
	return (
		cell.x >= -1 and cell.x < GameConfig.grid_width - 1
		and cell.y >= 0 and cell.y < GameConfig.grid_height
	)

# -----------------------------
# Heuristic (Manhattan for 4-dir grid)
func heuristic(a: Vector2i, b: Vector2i) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

# -----------------------------
# Get neighbors for 4-directional grid
func get_neighbors(pos: Vector2i) -> Array:
	return [
		pos + Vector2i(1, 0),
		pos + Vector2i(-1, 0),
		pos + Vector2i(0, 1),
		pos + Vector2i(0, -1)
	]

# -----------------------------
# Reconstruct path from came_from dictionary
func reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path : Array[Vector2i] = [current]
	while current in came_from:
		current = came_from[current]
		path.insert(0, current)
	return path
