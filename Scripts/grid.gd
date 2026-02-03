extends TileMapLayer

@export var source_id := 0
@export var atlas_coords := Vector2i(0, 0)

var hover_cell := Vector2i.ZERO

func _ready():
	clear()
	generate_grid()

func generate_grid():
	for x in range(GameConfig.grid_width):
		for y in range(GameConfig.grid_height):
			set_cell(Vector2i(x, y), source_id, atlas_coords)
	
