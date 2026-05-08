extends Node

func execute(ability, ability_button, combat_scene):
    if ability_button.button_pressed:
        combat_scene.action = 'movement'
        combat_scene.movement_speed = 0
        combat_scene.current_movement_ap_cost = ability.cost
        combat_scene.hover_grid.overlay_distance = 100
    else:
        combat_scene.action = ''
        combat_scene.movement_speed = combat_scene.walk_speed
        combat_scene.hover_grid.overlay_distance = 0
        combat_scene.current_movement_ap_cost = combat_scene.default_movement_ap_cost

