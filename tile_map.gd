extends TileMap

# NOTE
# there are two layers for the tile map:
# ACTIVE and BOARD
# 
# TODO write a concise explanation for both

const source_id = {
	"blocks": 1
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

var blocks = [
	{
		"type": "block", 
		"color": "aqua",
		"atlas_coordinates": Vector2i(0,0)	
	},
	{
		"type": "block", 
		"color": "purple",
		"atlas_coordinates": Vector2i(1,0)	
	},
	{
		"type": "block", 
		"color": "yellow",
		"atlas_coordinates": Vector2i(2,0)	
	},
	{
		"type": "block", 
		"color": "red",
		"atlas_coordinates": Vector2i(3,0)	
	},
	{
		"type": "block", 
		"color": "green",
		"atlas_coordinates": Vector2i(4,0)	
	},
	{
		"type": "block", 
		"color": "brown",
		"atlas_coordinates": Vector2i(5,0)	
	},
	{
		"type": "block", 
		"color": "blue",
		"atlas_coordinates": Vector2i(6,0)	
	}
]

var active_piece = {
	"initial_position": Vector2i(5, 1),
	"current": {
		"index": null,
		"type": null,
		"pos": null
	}
}

# called when the node enters the scene tree for the first time.
func _ready():
	active_piece.current.pos = active_piece.initial_position
	active_piece.current.index = get_random_piece().index
	active_piece.current.type = get_random_piece().type

# NOTE
# -> called every frame.
# -> delta is the elapsed time since the previous frame.
func _process(delta):
	handle_movements()
	handle_frame_count()
	check_rows()

func handle_movements():
	handle_active_piece_falling_movement()
	handle_user_input()
	
	if active_piece.current.type == "block":
		set_cell(
			layer.active.id, 
			active_piece.current.pos, 
			source_id.blocks, 
			blocks[active_piece.current.index].atlas_coordinates
		)	
	
func handle_user_input():
	if Input.is_action_pressed("move_right") && frames.right.isMovable && no_obstacle().right:
		erase_cell(layer.active.id, active_piece.current.pos)
		active_piece.current.pos.x += 1
		frames.right.count = 0
		frames.right.isMovable = false
	
	if Input.is_action_pressed("move_left") && frames.left.isMovable && no_obstacle().left:
		erase_cell(layer.active.id, active_piece.current.pos)
		active_piece.current.pos.x -= 1
		frames.left.count = 0
		frames.left.isMovable = false
	
	if Input.is_action_pressed("move_down"):
		frames.down.count += 10
	
func handle_active_piece_falling_movement():
	if frames.down.isMovable && no_obstacle().below:
		erase_cell(layer.active.id, active_piece.current.pos)	
		active_piece.current.pos.y += 1
		frames.down.count = 0
		frames.down.isMovable = false 
		
	elif !no_obstacle().below: handle_land()
	
func handle_frame_count():
	for f in [frames.down, frames.right, frames.left]:
		if f.count < f.required_for_move: f.count += 1
		elif !f.isMovable: f.isMovable = true 

func no_obstacle():
	return {
		"below": get_cell_source_id(layer.board.id, active_piece.current.pos + Vector2i(0,1)) == -1,
		"left": get_cell_source_id(layer.board.id, active_piece.current.pos + Vector2i(-1,0)) == -1,
		"right": get_cell_source_id(layer.board.id, active_piece.current.pos + Vector2i(1,0)) == -1	
	}

func get_random_piece():
	# TODO when there are more types of pieces the chosen_type can be other then "block"
	var chosen_type = "block"
	
	return {
		"index": randi() % len(chosen_type),
		"type": chosen_type
	}

func handle_land():
	erase_cell(layer.active.id, active_piece.current.pos)
	set_cell(layer.board.id, active_piece.current.pos, 1, blocks[active_piece.current.index].atlas_coordinates)
	
	# NOTE updates the current position to the initial position.
	active_piece.current.pos = active_piece.initial_position
	active_piece.current.index = get_random_piece().index

# WORK IN PROGRESS
func check_rows():
	var sum = 0
	var columns = [1,2,3,4,5,6,7]
	
	for col in columns:
		if get_cell_source_id(layer.board.id, Vector2i(col,14)) != -1:
			sum += 1
	
	if sum == len(columns):
		for col in columns:
			erase_cell(layer.board.id, Vector2i(col,14))
