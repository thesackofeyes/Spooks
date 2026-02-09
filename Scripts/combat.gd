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

var has_attacked = false
var unit_nodes

var action = ''

func _ready() -> void:
	# For multiple units, use unit position (0/1,0/1 stored on unit stats storage)
	var start_square = Vector2i(GameConfig.grid_width - 1, GameConfig.grid_height - 1)
	var units = SaveManager.data.units
	
	for unit in units:
		var new_unit := unit_scene.instantiate() as Unit
		new_unit.data = unit
		
		player_units.append(new_unit)
		$Units.add_child(new_unit)
		
		var new_unit_start = start_square - new_unit.data.start_position
		move_to(new_unit, new_unit_start, 0)
	
	unit_nodes = $Units.get_children()

	current_unit = player_units[0]
	TurnManager.start_battle(player_units)
	hover_grid.clicked.connect(_on_grid_clicked)

func _process(delta: float) -> void:
	unit_nodes = $Units.get_children()
	
	if current_unit != previous_unit:
		# Reset button states:
		$MoveButton.set_pressed(false)
		$AttackButton.set_pressed(false)
		# Reset unit stats at start of turn
		current_unit.current_ap = current_unit.data.stamina
		current_unit.current_moves = current_unit.data.speed
		previous_unit = current_unit

		abilities_container.update_abilites(current_unit.data.abilities)
		has_attacked = false

		print("current unit: ", current_unit.current_hp)
		
		# TODO: Differentiate player/enemy turns with UI and behavior
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
		
		if current_unit.current_moves > 0:
			$MoveButton.disabled = false
		else:
			$MoveButton.disabled = true
		
		if has_attacked == true:
			$AttackButton.disabled = true
		else:
			$AttackButton.disabled = false
	
	current_unit = TurnManager.current_unit
	draw_traversable_path(current_unit)
	$CharacterPortrait.update_portrait(current_unit.current_hp, current_unit.current_ap, current_unit.current_moves, Vector2i(current_unit.data.hero_sprite_x, current_unit.data.hero_sprite_y))
	

	
	

func draw_traversable_path(unit):
	if action == 'movement':
		hover_grid.set_overlay_path(Pathfinding.astar_find_path(tilemap_node, obstacles_tilemap, unit.position, hover_grid.hover_cell, unit_nodes))
		hover_grid.overlay_distance = current_unit.current_moves
	elif action == 'attack':
		# Update to display from attack range
		hover_grid.set_overlay_path(Pathfinding.astar_find_path(tilemap_node, obstacles_tilemap, unit.position, hover_grid.hover_cell, unit_nodes))
		hover_grid.overlay_distance = current_unit.data.base_attack_range
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
		var path = Pathfinding.astar_find_path(tilemap_node, obstacles_tilemap, unit.position, destination, unit_nodes)
		var number_of_tiles_moved = path.size() - 1
		if distance_cap < number_of_tiles_moved:
			number_of_tiles_moved = distance_cap
		current_unit.current_moves -= number_of_tiles_moved
		tween_along_path(unit, path, 0.4, distance_cap)

func _on_grid_clicked(visual_cell: Vector2i):
	for unit_node in unit_nodes:
		var unit_cell = Utils.local_to_cell(unit_node.position)
		
	if visual_cell == Vector2i(-1, -1):
		return
	if action == 'movement':
		move_to(current_unit, visual_cell, 1.1, current_unit.current_moves)

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
		
		var cell = Utils.local_to_cell(Utils.tilemap_cell_to_local(tilemap_node, path[i]))
		var destination = Utils.cell_to_local(cell)
		
		# Move unit to next tile
		tween.tween_property(unit, "position", destination, speed)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)

		# If overlap > 0, slightly reduce pause before next tween
		if overlap > 0 and i < path.size() - 1:
			tween.tween_interval(overlap)
			
func attack(attack_tile: Vector2i):
		var attack_path = Pathfinding.astar_find_path(tilemap_node, obstacles_tilemap, current_unit.position, attack_tile, unit_nodes)
		var attack_tile_distance = attack_path.size() - 1
		
		if attack_tile_distance <= current_unit.data.base_attack_range:
			current_unit.current_hp -= 1
			$AttackButton.set_pressed(false)
			has_attacked = true
			
			var attack_tile_unit = null
			var units = $Units.get_children()
			for unit in units:
				var unit_cell = Utils.local_to_cell(unit.position)
				if unit_cell == attack_tile:
					attack_tile_unit = unit
			
			if attack_tile_unit != null:
				var updated_hp = attack_tile_unit.current_hp - current_unit.data.base_attack_damage
				attack_tile_unit.current_hp = max(updated_hp, 0)
				print("Dealing ", current_unit.data.base_attack_damage, " damage to ", attack_tile_unit.data.unit_class, " on tile: ", attack_tile, " Updated HP: ", updated_hp)
			else:
				print("Attacking an empty tile")
		else:
			print("Attacking out of range")


func _on_end_turn_pressed() -> void:
	TurnManager.end_turn()

func _on_move_button_toggled(toggled_on: bool, source: BaseButton) -> void:
	if toggled_on == true:
		action = 'movement'
	else:
		action = ''

func _on_attack_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		action = 'attack'
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
