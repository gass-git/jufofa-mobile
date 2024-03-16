extends TileMap

# NOTE
# there are two layers for the tile map:
# ACTIVE and BOARD
# 
# TODO write a concise explanation for both

var pieces = [
	{
		"type": "tile", 
		"color": "aqua",
		"atlas_coordinates": Vector2i(0,0)	
	},
	{
		"type": "tile", 
		"color": "purple",
		"atlas_coordinates": Vector2i(1,0)	
	},
	{
		"type": "tile", 
		"color": "yellow",
		"atlas_coordinates": Vector2i(2,0)	
	},
	{
		"type": "tile", 
		"color": "red",
		"atlas_coordinates": Vector2i(3,0)	
	},
	{
		"type": "tile", 
		"color": "green",
		"atlas_coordinates": Vector2i(4,0)	
	},
	{
		"type": "tile", 
		"color": "brown",
		"atlas_coordinates": Vector2i(5,0)	
	},
	{
		"type": "tile", 
		"color": "blue",
		"atlas_coordinates": Vector2i(6,0)	
	},
	{
		"type": "tile", 
		"color": "grey",
		"atlas_coordinates": Vector2i(7,0)	
	}
]

var active_piece = {
	"initial_position": Vector2i(10, 1),
	"current": {
		"index": null,
		"pos": null
	}
}

var layer = {
	"board": {"id": 0},
	"active": {"id": 1}
}

var frames = {
	"down": {"count":0, "required_for_move": 40, "isMovable": false},
	"right": {"count": 0, "required_for_move": 10, "isMovable": false},
	"left": {"count": 0, "required_for_move": 10, "isMovable": false}
}

# called when the node enters the scene tree for the first time.
func _ready():
	active_piece.current.pos = active_piece.initial_position
	active_piece.current.index = get_random_piece_index()

# NOTE
# -> called every frame.
# -> delta is the elapsed time since the previous frame.
func _process(delta):
	handle_movement()

func get_random_piece_index():
	return randi() % len(pieces)

func handle_movement():
	if Input.is_action_pressed("move_right") && frames.right.isMovable:
		erase_cell(layer.active.id, active_piece.current.pos)
		active_piece.current.pos.x += 1
		frames.right.count = 0
		frames.right.isMovable = false
	
	if Input.is_action_pressed("move_left") && frames.left.isMovable:
		erase_cell(layer.active.id, active_piece.current.pos)
		active_piece.current.pos.x -= 1
		frames.left.count = 0
		frames.left.isMovable = false
	
	if Input.is_action_pressed("move_down"):
		frames.down.count += 10
	
	if frames.down.isMovable:
		erase_cell(layer.active.id, active_piece.current.pos)	
		
		if no_obstacle(): active_piece.current.pos.y += 1
		else: handle_land()
			
		frames.down.count = 0
		frames.down.isMovable = false
	
	set_cell(layer.active.id, active_piece.current.pos, 1, pieces[active_piece.current.index].atlas_coordinates)
	handle_frame_count()	
	
func handle_frame_count():
	for f in [frames.down, frames.right, frames.left]:
		if f.count < f.required_for_move: f.count += 1
		elif !f.isMovable: f.isMovable = true 

func no_obstacle():
	return get_cell_source_id(layer.board.id, active_piece.current.pos + Vector2i(0,1)) == -1	

func handle_land():
	erase_cell(layer.active.id, active_piece.current.pos)
	set_cell(layer.board.id, active_piece.current.pos, 1, pieces[active_piece.current.index].atlas_coordinates)
	
	# NOTE updates the current position to the initial position.
	active_piece.current.pos = active_piece.initial_position
	active_piece.current.index = get_random_piece_index()
