extends Node

# -----------------------------
# A* Pathfinding for 2D Tile Grids
# Returns an Array of Vector2i coordinates
# -----------------------------

# Main function
func astar_find_path(tilemap: TileMapLayer, obstacle_tilemap: TileMapLayer, start: Vector2i, goal: Vector2i, units: Array) -> Array[Vector2i]:
	start = Utils.tilemap_local_to_cell(tilemap, start)
	goal = Utils.tilemap_local_to_cell(tilemap, Utils.cell_to_local(goal))
	
	var open_set: Array[Vector2i] = [start]
	var closed_set: Dictionary = {} # Vector2i -> bool

	var came_from: Dictionary = {} # Vector2i -> Vector2i
	var g_score: Dictionary = {start: 0.0}
	var f_score: Dictionary = {start: Utils.heuristic(start, goal)}

	var closest: Vector2i = start
	var closest_distance: float = Utils.heuristic(start, goal)

	while open_set.size() > 0:
		# pick node with lowest f_score
		var current: Vector2i = open_set[0]
		for node in open_set:
			if f_score.get(node, INF) < f_score.get(current, INF):
				current = node
		open_set.erase(current)
		closed_set[current] = true

		# update closest reachable tile
		var dist := Utils.heuristic(current, goal)
		if dist < closest_distance:
			closest_distance = dist
			closest = current

		# goal reached
		if current == goal:
			return Utils.reconstruct_path(came_from, current)

		# evaluate neighbors
		for neighbor in Utils.get_neighbors(current):
			# skip out-of-bounds neighbors
			if not Utils.is_valid_cell(neighbor):
				continue
			# skip already processed nodes
			if closed_set.has(neighbor):
				continue
			# skip blocked neighbors
			if obstacle_tilemap.get_cell_tile_data(neighbor) != null:
				continue
			
			# for each unit, calculate position (tilemap_local_to_cell)
			var unit_in_neighbor = false
			for unit in units:
				var unit_cell = Utils.tilemap_local_to_cell(tilemap, unit.position)
				if unit_cell == neighbor:
					unit_in_neighbor = true
			
			if unit_in_neighbor == true:
				continue

			var tentative_g: float = g_score.get(current, INF) + 1
			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + Utils.heuristic(neighbor, goal)
				if neighbor not in open_set:
					open_set.append(neighbor)

	# goal unreachable, return path to closest reachable tile
	if closest != start:
		return Utils.reconstruct_path(came_from, closest)
	return []
