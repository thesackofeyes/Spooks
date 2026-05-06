#when triggered by the teleport ability, this script should print out the name of the ability, and the name of the unit using it. This is a test to ensure that the ability script is properly linked and executed when the ability button is toggled on.
extends Node

func execute(unit):
	print("Teleport ability used by: " + unit.data.unit_class + unit.data.unit_subclass)
