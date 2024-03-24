extends TileMap

# NOTE
# there are two layers for the tile map:
# ACTIVE and BOARD
# 
# TODO write a concise explanation for both

const board = {
	"rows": [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
	"columns": [0,1,2,3,4,5,6,7,8]
}

const source_id = {
	"blocks": 1
}

var layer = {
	"board": {"id": 0},
	"active": {"id": 1}
}

var frames = {
	"down": {"count":0, "required_for_move": 60, "isMovable": false},
	"right": {"count": 0, "required_for_move": 10, "isMovable": false},
	"left": {"count": 0, "required_for_move": 10, "isMovable": false}
}

var pieces = [
	{
		"type": "block", 
		"color": "white",
		"atlas_coordinates": Vector2i(0,0)	
	},
	{
		"type": "block", 
		"color": "yellow",
		"atlas_coordinates": Vector2i(1,0)	
	},
	{
		"type": "block", 
		"color": "pink",
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
		"color": "blue",
		"atlas_coordinates": Vector2i(5,0)	
	},
	{
		"type": "special", 
		"color": "transparent",
		"atlas_coordinates": Vector2i(6,0)	
	},
	{
		"type": "super_power", 
		"color": "black",
		"atlas_coordinates": Vector2i(7,0)	
	}
]

var active_piece = {
	"initial_position": Vector2i(4, 0),
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
func _process(_delta):
	handle_movements()
	handle_frame_count()
	
func get_piece_data():
	return {
		"white_block": pieces[0],
		"yellow_block": pieces[1],
		"pink_block": pieces[2],
		"red_block": pieces[3],
		"green_block": pieces[4],
		"blue_block": pieces[5],
		"transparent_block": pieces[6],
		"bomb": pieces[7]
	}	
	
func handle_movements():
	handle_active_piece_falling_movement()
	handle_user_input()
	
	if active_piece.current.type == "block":
		set_cell(
			layer.active.id, 
			active_piece.current.pos, 
			source_id.blocks, 
			pieces[active_piece.current.index].atlas_coordinates
		)	
	
func handle_user_input():
	if Input.is_action_pressed("move_right") && frames.right.isMovable && is_tile_available(active_piece.current.pos).right:
		erase_cell(layer.active.id, active_piece.current.pos)
		active_piece.current.pos.x += 1
		frames.right.count = 0
		frames.right.isMovable = false
	
	if Input.is_action_pressed("move_left") && frames.left.isMovable && is_tile_available(active_piece.current.pos).left:
		erase_cell(layer.active.id, active_piece.current.pos)
		active_piece.current.pos.x -= 1
		frames.left.count = 0
		frames.left.isMovable = false
	
	if Input.is_action_pressed("move_down"):
		frames.down.count += 5
	
func handle_active_piece_falling_movement():
	if frames.down.isMovable && is_tile_available(active_piece.current.pos).below:
		erase_cell(layer.active.id, active_piece.current.pos)	
		active_piece.current.pos.y += 1
		frames.down.count = 0
		frames.down.isMovable = false 
		
	elif !is_tile_available(active_piece.current.pos).below: 
		handle_land()
		check_all_rows()
	
func handle_frame_count():
	for f in [frames.down, frames.right, frames.left]:
		if f.count < f.required_for_move: f.count += 1
		elif !f.isMovable: f.isMovable = true 

func is_tile_available(pos):
	return {
		"default": get_cell_source_id(layer.board.id, pos) == -1 && is_in_board(pos),
		"below": get_cell_source_id(layer.board.id, pos + Vector2i(0,1)) == -1 && is_in_board(pos + Vector2i(0,1)),
		"left": get_cell_source_id(layer.board.id, pos + Vector2i(-1,0)) == -1 && is_in_board(pos + Vector2i(-1,0)),
		"right": get_cell_source_id(layer.board.id, pos + Vector2i(1,0)) == -1 && is_in_board(pos + Vector2i(1,0))
	}

func is_in_board(pos: Vector2i):
	var col = pos.x
	var row = pos.y
	
	if col in board.columns && row in board.rows:return true
	else: return false
	
func get_random_piece():
	# TODO when there are more types of pieces the chosen_type can be other than "block"
	var chosen_type = "block"
	var non_super_power_pieces = pieces.filter(func(piece): return piece.type != "super_power")
	
	return {
		"index": randi() % len(non_super_power_pieces),
		"type": chosen_type
	}

func handle_land():
	erase_cell(layer.active.id, active_piece.current.pos)
	set_cell(layer.board.id, active_piece.current.pos, 1, pieces[active_piece.current.index].atlas_coordinates)
	
	# NOTE updates the current position to the initial position.
	active_piece.current.pos = active_piece.initial_position
	active_piece.current.index = get_random_piece().index

# WORK IN PROGRESS
func check_all_rows():
	for row in board.rows:
		var sum = 0
		var atlas_coords_to_match
		
		for col in board.columns:
			# if the piece is a transparent one, continue looking for the color piece.
			if (get_cell_atlas_coords(layer.board.id, Vector2i(col,row)) == 
			get_piece_data().transparent_block.atlas_coordinates):
				continue
				
			else: atlas_coords_to_match = get_cell_atlas_coords(layer.board.id, Vector2i(col,row))
		
		for col in board.columns: 
			var atlas_coords = get_cell_atlas_coords(layer.board.id, Vector2i(col,row))
			
			if ((atlas_coords == get_piece_data().transparent_block.atlas_coordinates ||
				 atlas_coords == atlas_coords_to_match) && is_tile_available(Vector2i(1,row))): sum += 1
				
		if sum == len(board.columns):
			for col in board.columns: erase_cell(layer.board.id, Vector2i(col,row))
			reposition_pieces_if_needed()

func reposition_pieces_if_needed():
	#check if there is an empty tile beneath each piece
	var rows_to_loop: Array = board.rows.slice(0,len(board.rows) - 1)
	
	rows_to_loop.reverse()
	
	for row in rows_to_loop:
		for col in board.columns:
			
			# is there a piece in this tile ?
			if get_cell_source_id(layer.board.id, Vector2i(col, row)) != -1:
				# is the tile beneath empty ?
				if get_cell_source_id(layer.board.id, Vector2i(col, row + 1)) == -1:
					# move the piece to the tile beneath
					var atlas_coords = get_cell_atlas_coords(layer.board.id, Vector2i(col, row))
					erase_cell(layer.board.id, Vector2i(col, row))
					set_cell(layer.board.id,  Vector2i(col, row + 1), 1, atlas_coords)
					
	
