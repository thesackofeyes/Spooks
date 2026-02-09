extends Node

const SAVE_PATH := "res://Assets/savegame.tres"

var data: GameData

func _ready():
	var unit_scene = load("res://Scenes/unit.tscn")
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
	create_unit("Witch", "Malevolant")
	create_unit("Ghost", "Small")
	
	data.current_unit = data.units[0]
	save_game()

func create_unit(unit_class: String, unit_subclass: String = ""):
	var unit_data := UnitLibrary.create_unit(unit_class, unit_subclass)
	
	data.units.append(unit_data)
