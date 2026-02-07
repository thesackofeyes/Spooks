extends Control

func _ready() -> void:
	update_stats()

func update_stats():
	pass
	#update_hp(10)
	#update_ap(3)
	#update_moves(1)

func update_hp(hp):
	# Update HP Count (Currently static, implement with attacking)
	$HP/Label.text = str(hp)
	
func update_ap(ap):
	# Update AP Count (Currently static, implement with attacking)
	$AP/Label.text = str(ap)
	
func update_moves(moves):
	$Moves/Label.text = str(moves)
