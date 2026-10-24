extends Control

func update_portrait(hp, ap, moves, image_frames: Vector2i):
	update_hp(hp)
	update_ap(ap)
	update_moves(moves)
	update_hero_image(image_frames)

func update_hp(hp):
	$HP/Label.text = str(hp)

func update_ap(ap):
	$AP/Label.text = str(ap)

func update_moves(moves):
	$Moves/Label.text = str(moves)

func update_hero_image(image_frames: Vector2i):
	$Portrait.frame_coords = image_frames
