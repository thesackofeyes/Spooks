extends Control

func _ready() -> void:
	pass

func update_portrait(hp, ap, moves, image_frames: Vector2i):
	update_hp(hp)
	update_ap(ap)
	update_moves(moves)
	update_hero_image(image_frames)

func update_hp(hp):
	# Update HP Count (Currently static, implement with attacking)
	$HP/Label.text = str(hp)
	
func update_ap(ap):
	# Update AP Count (Currently static, implement with attacking)
	$AP/Label.text = str(ap)
	
func update_moves(moves):
	$Moves/Label.text = str(moves)

func update_hero_image(image_frames: Vector2i):
	var hframes = $Portrait.hframes
	$Portrait.frame = image_frames.y * hframes + image_frames.x
	
