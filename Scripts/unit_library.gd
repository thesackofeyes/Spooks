extends Node

const UNIT_LIBRARY := {
	"Spook:Apprentice": preload("res://Units/Allies/spook.tres"),
	"Witch:Malevolant": preload("res://Units/Allies/witch.tres"),
	"Ghost:Small": preload("res://Units/Enemies/ghost.tres")
}

func create_unit(unit_class: String, unit_subclass: String = "") -> UnitData:
	var key := unit_class if unit_subclass == "" else "%s:%s" % [unit_class, unit_subclass]
	if not UNIT_LIBRARY.has(key):
		push_error("Unknown unit type: " + key)
		return null

	return UNIT_LIBRARY[key].duplicate(true)
