extends Node2D
@onready var tilemap_node := $Grid
@onready var hover_grid : HoverGrid = $HoverGrid
@onready var obstacles_tilemap := $"Grid/Obstacles"
@onready var move_button := $MoveButton
@onready var abilities_container := $Abilities

const UNIT_SCENE := preload("res://Scenes/unit.tscn")

var all_units: Array = []
var player_units: Array = []
var enemy_units: Array = []

var current_unit

var walk_speed = 1.1
var movement_speed = walk_speed
var default_movement_ap_cost = 0
var current_movement_ap_cost = default_movement_ap_cost

var action = ''

func _ready() -> void:
	# For multiple units, use unit position (0/1,0/1 stored on unit stats storage)
	var start_square = Vector2i(GameConfig.grid_width - 1, GameConfig.grid_height - 1)
	var units = SaveManager.data.units
	
	for unit in units:
		var new_unit := UNIT_SCENE.instantiate() as Unit
		new_unit.data = unit
		
		if new_unit.data.player_unit:
			player_units.append(new_unit)
		else:
			enemy_units.append(new_unit)

		all_units.append(new_unit)

		$Units.add_child(new_unit)
		new_unit.stats_changed.connect(_on_unit_stats_changed)
		new_unit.defeated.connect(_on_unit_defeated)

		print("Placing unit ", new_unit.data.unit_class, new_unit.data.unit_subclass, " at start position: ", new_unit.data.start_position)

		var new_unit_start = start_square - new_unit.data.start_position
		move_to(new_unit, new_unit_start, 0)

	TurnManager.turn_started.connect(_on_turn_started)
	TurnManager.start_battle(all_units)
	hover_grid.clicked.connect(_on_grid_clicked)

# Fires for every turn, including a unit acting twice in a row across rounds.
# The unit has already reset its own AP/moves/attack in Unit.start_turn
func _on_turn_started(unit) -> void:
	current_unit = unit
	unpress_action_buttons()
	unpress_ability_buttons()
	abilities_container.update_abilities(current_unit)
	refresh_ui()

func _on_unit_stats_changed(unit) -> void:
	if unit == current_unit:
		refresh_ui()

func _on_unit_defeated(_unit, _attacker) -> void:
	check_combat_end_conditions()

# Syncs buttons and portrait with the current unit. Called when the turn
# starts or the current unit's stats change, rather than every frame
func refresh_ui() -> void:
	if current_unit == null:
		return

	if current_unit.data.player_unit == false:
		# Disable Movement/Attack buttons during enemy turns
		$MoveButton.disabled = true
		$AttackButton.disabled = true
		# Uncomment after debug/enemy AI added:
		#$EndTurn.visible = false
		#$CharacterPortrait.visible = false
	else:
		$EndTurn.visible = true
		#$CharacterPortrait.visible = true
		$MoveButton.disabled = current_unit.current_moves <= 0
		$AttackButton.disabled = current_unit.has_attacked

	abilities_container.refresh_affordability(current_unit)
	$CharacterPortrait.update_portrait(current_unit.current_hp, current_unit.current_ap, current_unit.current_moves, Vector2i(current_unit.data.hero_sprite_x, current_unit.data.hero_sprite_y))

func _process(_delta: float) -> void:
	# Follows the mouse, so this one does need to run every frame
	draw_traversable_path(current_unit)

# Corpses are excluded so they don't block pathfinding or get targeted
func get_living_units() -> Array:
	return $Units.get_children().filter(func(unit): return not unit.is_defeated())

# Returns the living unit standing on a grid cell, or null
func get_unit_at_cell(cell: Vector2i):
	for unit in get_living_units():
		if unit.get_cell() == cell:
			return unit
	return null

func has_obstacle(cell: Vector2i) -> bool:
	return obstacles_tilemap.get_cell_tile_data(Utils.grid_cell_to_tilemap_cell(tilemap_node, cell)) != null

# A cell is free if it has no obstacle and no living unit (corpses don't block)
func is_cell_free(cell: Vector2i) -> bool:
	if has_obstacle(cell):
		return false
	return get_unit_at_cell(cell) == null

# Obstacles on the cells between the two ends block sight; units don't
func has_line_of_sight(from: Vector2i, to: Vector2i) -> bool:
	var line = Utils.get_line_cells(from, to)
	for i in range(1, line.size() - 1):
		if has_obstacle(line[i]):
			return false
	return true

func check_combat_end_conditions():
	if player_units.all(func(unit): return unit.is_defeated()):
		print("All player units defeated. Game Over.")

	# if no enemy units remain alive, trigger victory conditions
	if enemy_units.all(func(unit): return unit.is_defeated()):
		print("All enemy units defeated. Victory!")

func draw_traversable_path(unit):
	if action == 'movement' and movement_speed > 0:
		var path = Pathfinding.astar_find_path(tilemap_node, obstacles_tilemap, unit.position, hover_grid.hover_cell, get_living_units())
		hover_grid.set_overlay_path(path.map(func(cell): return Utils.tilemap_cell_to_grid_cell(tilemap_node, cell)))
	elif action == 'attack':
		# Show the straight line the attack travels along, rather than a walking path
		hover_grid.set_overlay_path(Utils.get_line_cells(unit.get_cell(), hover_grid.hover_cell))
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
		var path = Pathfinding.astar_find_path(tilemap_node, obstacles_tilemap, unit.position, destination, get_living_units())
		var number_of_tiles_moved = path.size() - 1
		if distance_cap < number_of_tiles_moved:
			number_of_tiles_moved = distance_cap
		current_unit.current_moves -= number_of_tiles_moved
		tween_along_path(unit, path, 0.4, distance_cap)
	
	unit.update_ap(current_movement_ap_cost*-1)
	# Ends any active ability (e.g. Teleport) now that the move is done
	unpress_ability_buttons()
	movement_speed = walk_speed
	current_movement_ap_cost = default_movement_ap_cost

func unpress_ability_buttons(except: Node = null):
	for ability_button in abilities_container.ability_container.get_children():
		if ability_button != except:
			ability_button.set_pressed(false)

func unpress_action_buttons():
	$MoveButton.set_pressed(false)
	$AttackButton.set_pressed(false)

func _on_grid_clicked(visual_cell: Vector2i):
	if visual_cell == Vector2i(-1, -1):
		return
	if action == 'movement':
		# Teleport (speed 0) lands exactly on the clicked cell, so it must be free.
		# Walking doesn't need this as pathfinding already avoids occupied cells
		if movement_speed == 0 and not is_cell_free(visual_cell):
			print("Cannot teleport onto an occupied tile, teleport preserved")
			return
		move_to(current_unit, visual_cell, movement_speed, current_unit.current_moves)

	if action == 'attack':
		attack(visual_cell)
		
# Moves a unit along a path of Vector2i tiles using Tweens
func tween_along_path(unit: Node2D, path: Array, speed: float, distance_cap: int, overlap: float = -0.5):
	if path.size() == 0:
		return

	var tween := create_tween()
	tween.set_parallel(false)

	for i in range(path.size()):
		if distance_cap != -1 and distance_cap < i:
			break
		
		var cell = Utils.tilemap_cell_to_grid_cell(tilemap_node, path[i])
		var destination = Utils.cell_to_local(cell)
		
		# Move unit to next tile
		tween.tween_property(unit, "position", destination, speed)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)

		# If overlap > 0, slightly reduce pause before next tween
		if overlap > 0 and i < path.size() - 1:
			tween.tween_interval(overlap)
			
func attack(attack_tile: Vector2i):
	var attacker_cell = current_unit.get_cell()

	if Utils.grid_distance(attacker_cell, attack_tile) > current_unit.data.base_attack_range:
		print("Attacking out of range, attack action preserved")
		return

	if not has_line_of_sight(attacker_cell, attack_tile):
		print("No line of sight to target, attack action preserved")
		return

	var attack_tile_unit = get_unit_at_cell(attack_tile)
	if attack_tile_unit == null:
		print("Attacking an empty tile, attack action preserved")
		return

	if current_unit.data.player_unit == attack_tile_unit.data.player_unit:
		print("Cannot attack unit on the same side, attack action preserved")
		return

	attack_tile_unit.process_damage(current_unit.data.base_attack_damage, current_unit)
	$AttackButton.set_pressed(false)
	current_unit.has_attacked = true

func _on_end_turn_pressed() -> void:
	current_unit.end_turn()

func _on_move_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		unpress_ability_buttons()
		$AttackButton.set_pressed(false)
		action = 'movement'
		hover_grid.overlay_distance = current_unit.current_moves
	else:
		action = ''

func _on_attack_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		unpress_ability_buttons()
		$MoveButton.set_pressed(false)
		action = 'attack'
		hover_grid.overlay_distance = current_unit.data.base_attack_range
	else:
		action = ''


# Tooltip Signals

func _on_attack_button_mouse_entered() -> void:
	TooltipManager.show_tooltip(
		"Iron Sword",
		"Damage: " + str(current_unit.data.base_attack_damage) 
			+ "\nRange: " + str(current_unit.data.base_attack_range) 
	)

func _on_attack_button_mouse_exited() -> void:
	TooltipManager.hide_tooltip()

func _on_move_button_mouse_entered() -> void:
	TooltipManager.show_tooltip(
		"Move",
		str(current_unit.current_moves) + " Tiles" 
	)

func _on_move_button_mouse_exited() -> void:
	TooltipManager.hide_tooltip()
