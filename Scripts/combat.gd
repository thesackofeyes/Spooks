extends Node2D
@onready var tilemap_node := $Grid
@onready var hover_grid : HoverGrid = $HoverGrid
@onready var obstacles_tilemap := $"Grid/Obstacles"
@onready var abilities_container := $Abilities

const UNIT_SCENE := preload("res://Scenes/unit.tscn")
const MOVE_ABILITY := preload("res://Abilities/move.tres")
const ATTACK_ABILITY := preload("res://Abilities/iron_sword.tres")

const WALK_STEP_DURATION := 0.4

var all_units: Array = []
var player_units: Array = []
var enemy_units: Array = []

var current_unit

# Move, Attack and ability buttons share this group so only one is ever pressed;
# pressing another unpresses (and fires toggled(false) on) the previous one first
var action_button_group := ButtonGroup.new()

# The selected action (Move, Attack or an ability) and the button that selected it
var active_effect: AbilityEffect = null
var active_button: GameButton = null

var hovered_unit = null # Living unit under the mouse, for its info tooltip

func _ready() -> void:
	action_button_group.allow_unpress = true
	$MoveButton.button_group = action_button_group
	$AttackButton.button_group = action_button_group
	$MoveButton.ability = MOVE_ABILITY
	$AttackButton.ability = ATTACK_ABILITY
	abilities_container.button_group = action_button_group
	abilities_container.ability_toggled.connect(_on_ability_toggled)

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

		place_unit(new_unit, start_square - new_unit.data.start_position)

	TurnManager.turn_started.connect(_on_turn_started)
	TurnManager.start_battle(all_units)
	hover_grid.clicked.connect(_on_grid_clicked)

# Fires for every turn, including a unit acting twice in a row across rounds.
# The unit has already reset its own AP/moves/attack in Unit.start_turn
func _on_turn_started(unit) -> void:
	current_unit = unit
	clear_selected_action()
	$MoveButton.unit = current_unit
	$AttackButton.unit = current_unit
	abilities_container.update_abilities(current_unit)
	refresh_ui()

func _on_unit_stats_changed(unit) -> void:
	if unit == current_unit:
		refresh_ui()
	if unit == hovered_unit:
		show_unit_info(unit)

func _on_unit_defeated(_unit, _attacker) -> void:
	check_combat_end_conditions()

# Syncs buttons and portrait with the current unit. Called when the turn
# starts or the current unit's stats change, rather than every frame
func refresh_ui() -> void:
	if current_unit == null:
		return

	if current_unit.data.player_unit == false:
		# Disable Movement/Attack buttons during enemy turns
		$MoveButton.set_visual_state(GameButton.VisualState.UNAVAILABLE)
		$AttackButton.set_visual_state(GameButton.VisualState.UNAVAILABLE)
		# Uncomment after debug/enemy AI added:
		#$EndTurn.visible = false
		#$CharacterPortrait.visible = false
	else:
		$EndTurn.visible = true
		#$CharacterPortrait.visible = true
		$MoveButton.set_visual_state(GameButton.VisualState.USED if current_unit.current_moves <= 0 else GameButton.VisualState.AVAILABLE)
		$AttackButton.set_visual_state(GameButton.VisualState.USED if current_unit.has_attacked else GameButton.VisualState.AVAILABLE)

	abilities_container.refresh_affordability(current_unit)
	$CharacterPortrait.update_portrait(current_unit)

func _process(_delta: float) -> void:
	# Both follow the mouse, so these do need to run every frame
	update_hover_preview()
	update_hovered_unit()

# Shows a tooltip for the living unit under the mouse (groundwork for enemy info)
func update_hovered_unit() -> void:
	# While over UI, buttons own the tooltip
	if get_viewport().gui_get_hovered_control() != null:
		hovered_unit = null
		return

	var unit = get_unit_at_cell(hover_grid.hover_cell)
	if unit == hovered_unit:
		return

	hovered_unit = unit
	if unit != null:
		show_unit_info(unit)
	else:
		TooltipManager.hide_tooltip()

func show_unit_info(unit) -> void:
	var unit_body = "HP: %d/%d\n%s" % [unit.current_hp, unit.data.base_hp, unit.data.flavour_text]
	TooltipManager.show_tooltip(unit.get_display_name(), unit_body)

# Colours the hover tile and preview from the selected action:
# its own colour when the hovered target is valid, red when it isn't
func update_hover_preview() -> void:
	var cell = hover_grid.hover_cell
	if active_effect == null or cell == Vector2i(-1, -1):
		hover_grid.hover_colour = HoverGrid.DEFAULT_HOVER_COLOUR
		hover_grid.destination_cell = AbilityEffect.NO_CELL
		hover_grid.set_overlay_path([])
		return

	if active_effect.validate_target(cell) != "":
		hover_grid.hover_colour = AbilityEffect.INVALID_COLOUR
		hover_grid.overlay_colour = AbilityEffect.INVALID_COLOUR
		hover_grid.destination_cell = AbilityEffect.NO_CELL
	else:
		hover_grid.hover_colour = active_effect.colour
		hover_grid.overlay_colour = active_effect.colour
		hover_grid.destination_cell = active_effect.get_destination(cell)
	hover_grid.set_overlay_path(active_effect.get_preview_cells(cell))

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

# Walking path from a unit to a cell, as grid cells starting with the unit's own.
# Unreachable cells give the path to the closest reachable one
func find_walk_path(unit, cell: Vector2i) -> Array:
	var path = Pathfinding.astar_find_path(tilemap_node, obstacles_tilemap, unit.position, cell, get_living_units())
	return path.map(func(tilemap_cell): return Utils.tilemap_cell_to_grid_cell(tilemap_node, tilemap_cell))

# Instantly puts a unit on a cell (spawning, teleporting)
func place_unit(unit, cell: Vector2i) -> void:
	unit.position = tilemap_node.position + Utils.cell_to_local(cell)

# Walks a unit towards a cell, up to max_tiles. Returns the number of tiles moved
func walk_unit(unit, cell: Vector2i, max_tiles: int) -> int:
	var path = find_walk_path(unit, cell)
	tween_along_path(unit, path, WALK_STEP_DURATION, max_tiles)
	return clampi(path.size() - 1, 0, max_tiles)

# Unpresses whichever Move/Attack/ability button is active, if any
func clear_selected_action():
	var pressed_button = action_button_group.get_pressed_button()
	if pressed_button != null:
		pressed_button.set_pressed(false)

func _on_grid_clicked(visual_cell: Vector2i):
	if visual_cell == Vector2i(-1, -1) or active_effect == null:
		return

	var error = active_effect.validate_target(visual_cell)
	if error != "":
		print(error, ", action preserved")
		return

	# Keep a reference, as clearing the selection below drops active_effect
	var effect = active_effect
	effect.execute(visual_cell)
	current_unit.update_ap(-effect.get_cost())
	clear_selected_action()

# Moves a unit along a path of grid cells using Tweens
func tween_along_path(unit: Node2D, path: Array, speed: float, distance_cap: int, overlap: float = -0.5):
	if path.size() == 0:
		return

	var tween := create_tween()
	tween.set_parallel(false)

	for i in range(path.size()):
		if distance_cap != -1 and distance_cap < i:
			break

		var destination = Utils.cell_to_local(path[i])

		# Move unit to next tile
		tween.tween_property(unit, "position", destination, speed)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)

		# If overlap > 0, slightly reduce pause before next tween
		if overlap > 0 and i < path.size() - 1:
			tween.tween_interval(overlap)

func _on_end_turn_pressed() -> void:
	current_unit.end_turn()

func _on_move_button_toggled(toggled_on: bool) -> void:
	_on_action_toggled($MoveButton, toggled_on)

func _on_attack_button_toggled(toggled_on: bool) -> void:
	_on_action_toggled($AttackButton, toggled_on)

func _on_ability_toggled(ability_button: AbilityButton, toggled_on: bool) -> void:
	_on_action_toggled(ability_button, toggled_on)

# Every action button (Move, Attack, abilities) selects its effect the same way.
# Abilities without a script (e.g. Widdershins Strike for now) give no effect
func _on_action_toggled(button: GameButton, toggled_on: bool) -> void:
	if toggled_on:
		active_button = button
		active_effect = AbilityEffect.create(button.ability, current_unit, self)
	elif button == active_button:
		active_button = null
		active_effect = null
