extends Node

const SAVE_PATH := "res://Assets/savegame.tres"

var data: GameData
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	load_game()

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		data = ResourceLoader.load(SAVE_PATH)
	else:
		data = GameData.new()
		_init_default_data()

func save_game():
	var err = ResourceSaver.save(data, SAVE_PATH)
	print("Saving game:", err, " path:", SAVE_PATH)

func _init_default_data():
	create_unit("Spook", "Apprentice")
	save_game()

func create_unit(unit_class: String, unit_subclass: String = "") -> UnitData:
	var template := UnitData.new()
	template.unit_class = unit_class
	template.unit_subclass = unit_subclass

	var unit := template.duplicate()
	unit.id = _generate_unit_id()
	
	data.units.append(unit)
	return unit

func _generate_unit_id() -> String:
	return "unit_" + str(rng.randi()) + "_" + str(rng.randi())
