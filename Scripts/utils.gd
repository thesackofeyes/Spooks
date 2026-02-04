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
	
	
# -----------------------------
# clamp a cell to grid bounds
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
