extends GameButton
class_name AbilityButton

# Bubbled up through the abilities container to Combat, which runs the ability
signal ability_toggled(ability_button, toggled_on)

func setup(p_ability: Ability, p_unit: Unit) -> void:
	ability = p_ability
	unit = p_unit
	$Label.text = ability.name
	$ButtonIcon.frame_coords = Vector2i(ability.icon_x, ability.icon_y)

func _on_toggled(toggled_on: bool) -> void:
	ability_toggled.emit(self, toggled_on)
