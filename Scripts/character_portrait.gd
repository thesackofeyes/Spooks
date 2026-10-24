extends Control

# Shows any unit's stats, so the same portrait can be reused for enemy info later
func update_portrait(unit: Unit):
	update_hp(unit.current_hp)
	update_ap(unit.current_ap)
	update_moves(unit.current_moves)
	update_hero_image(Vector2i(unit.data.hero_sprite_x, unit.data.hero_sprite_y))

func update_hp(hp):
	$HP/Label.text = str(hp)

func update_ap(ap):
	$AP/Label.text = str(ap)

func update_moves(moves):
	$Moves/Label.text = str(moves)

func update_hero_image(image_frames: Vector2i):
	$Portrait.frame_coords = image_frames
