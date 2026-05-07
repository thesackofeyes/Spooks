extends Node

func execute(ability, ability_button, combat_scene):
    if ability_button.pressed:
        combat_scene.action = 'movement'
        combat_scene.movement_speed = 0
        combat_scene.current_movement_ap_cost = ability.cost
        combat_scene.hover_grid.overlay_distance = 100

        #   Update to not draw path
        #   Update current tile indicator to be blue instead of red
        #   Unpress ability button after teleport action (Update all to unpressed if AP is changed?)
    else:
        combat_scene.action = ''
        combat_scene.movement_speed = combat_scene.walk_speed
        combat_scene.hover_grid.overlay_distance = 0
        combat_scene.current_movement_ap_cost = combat_scene.default_movement_ap_cost

