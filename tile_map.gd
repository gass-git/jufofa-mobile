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
	"down": {"count":0, "required_for_move": 40, "isMovable": false},
	"right": {"count": 0, "required_for_move": 5, "isMovable": false},
	"left": {"count": 0, "required_for_move": 5, "isMovable": false},
	"rotate": {"count": 0, "required_for_move": 30, "isMovable": false},
	"reposition": {"count": 0, "required": 20},
}

var pieces = [
	{
		"type": "block", 
		"color": "white",
		"atlas_coords": Vector2i(0,0)	
	},
	{
		"type": "block", 
		"color": "yellow",
		"atlas_coords": Vector2i(1,0)	
	},
	{
		"type": "block", 
		"color": "pink",
		"atlas_coords": Vector2i(2,0)	
	},
	{
		"type": "block", 
		"color": "red",
		"atlas_coords": Vector2i(3,0)	
	},
	{
		"type": "block", 
		"color": "green",
		"atlas_coords": Vector2i(4,0)	
	},
	{
		"type": "block", 
		"color": "blue",
		"atlas_coords": Vector2i(5,0)	
	},
	{
		"type": "special", 
		"color": "transparent",
		"atlas_coords": Vector2i(6,0)	
	},
	{
		"type": "three_in_line",
		"color": "transparent",
		"atlas_coords": Vector2i(6,0)
	},
	{
		"type": "super_power", 
		"color": "black",
		"atlas_coords": Vector2i(7,0)	
	}
]

var active_piece = {
	"initial_position": Vector2i(4, 0),
	"index": null,
	"type": null,
	"pos": null,
	"rotated": false
}

var check_reposition_of_pieces = false
var score = 0
var progress_bar_value = 0
var bombs_in_storage = 0
var bomb_in_next_turn = false

#TODO improve this
var bomb_index = 8

# called when the node enters the scene tree for the first time.
func _ready():
	create_first_piece()

# NOTE
# -> called every frame.
# -> delta is the elapsed time since the previous frame.
func _process(_delta):
	handle_movements()
	handle_frame_count()
	
	if check_reposition_of_pieces && frames.reposition.count > frames.reposition.required: 
		reposition_pieces_if_needed()
		frames.reposition.count = 0
	else: frames.reposition.count += 1
	
	# when the progress bar reaches its max value reset to 0 and add a bomb to the storage
	if progress_bar_value == $HUD.get_node("ProgressBar").max_value: 
		progress_bar_value = 0
		update_progress_bar()
		bombs_in_storage += 1
		update_bombs_label()
	
func create_first_piece():
	active_piece.pos = active_piece.initial_position
	active_piece.index = get_random_piece().index
	active_piece.type = get_random_piece().type
	
func get_piece_data():
	return {
		"white_block": pieces[0],
		"yellow_block": pieces[1],
		"pink_block": pieces[2],
		"red_block": pieces[3],
		"green_block": pieces[4],
		"blue_block": pieces[5],
		"transparent_block": pieces[6],
		"three_in_line": pieces[7],
		"bomb": pieces[8]
	}	
	
func update_score_label():
	$HUD.get_node("ScoreLabel").text = str(score)
	
func update_progress_bar():
	$HUD.get_node("ProgressBar").value = progress_bar_value	
	
func update_bombs_label():
	$HUD.get_node("BombsInStorage").text = "BOMBS:" + str(bombs_in_storage)	
	
func handle_movements():
	handle_active_piece_falling_movement()
	handle_user_input()
	handle_active_layer_cell_setters()
	
func handle_user_input():
	
	if active_piece.type == "three_in_line":
		if Input.is_action_pressed("move_right") && frames.right.isMovable && is_tile_available(active_piece.pos).right:
			if active_piece.rotated:
				erase_cell(layer.active.id, active_piece.pos + Vector2i(-1, 0))
				
			else:
				erase_cell(layer.active.id, active_piece.pos + Vector2i(0, 1))
				erase_cell(layer.active.id, active_piece.pos + Vector2i(0, -1))
				
			erase_cell(layer.active.id, active_piece.pos)
			active_piece.pos.x += 1
			frames.right.count = 0
			frames.right.isMovable = false
		
		if Input.is_action_pressed("move_left") && frames.left.isMovable && is_tile_available(active_piece.pos).left:
			if active_piece.rotated:
				erase_cell(layer.active.id, active_piece.pos + Vector2i(1, 0))
			
			else:
				erase_cell(layer.active.id, active_piece.pos + Vector2i(0, 1))
				erase_cell(layer.active.id, active_piece.pos + Vector2i(0, -1))
			
			erase_cell(layer.active.id, active_piece.pos)
			active_piece.pos.x -= 1
			frames.left.count = 0
			frames.left.isMovable = false
		
		if Input.is_action_pressed("up") && frames.rotate.isMovable:
			if !active_piece.rotated:
				erase_cell(layer.active.id, active_piece.pos + Vector2i(0,1))
				erase_cell(layer.active.id, active_piece.pos)	
				erase_cell(layer.active.id, active_piece.pos + Vector2i(0,-1))	
			
			else: 
				erase_cell(layer.active.id, active_piece.pos + Vector2i(1,0))	
				erase_cell(layer.active.id, active_piece.pos + Vector2i(-1,0))	
				
			active_piece.rotated = !active_piece.rotated	
			
			frames.rotate.count = 0
			frames.rotate.isMovable = false
		
		if Input.is_action_pressed("move_down"):
			frames.down.count += 5
			progress_bar_value += 1
			update_progress_bar()
		
	else:
		if Input.is_action_pressed("move_right") && frames.right.isMovable && is_tile_available(active_piece.pos).right:
			erase_cell(layer.active.id, active_piece.pos)
			active_piece.pos.x += 1
			frames.right.count = 0
			frames.right.isMovable = false
		
		if Input.is_action_pressed("move_left") && frames.left.isMovable && is_tile_available(active_piece.pos).left:
			erase_cell(layer.active.id, active_piece.pos)
			active_piece.pos.x -= 1
			frames.left.count = 0
			frames.left.isMovable = false
		
		if Input.is_action_pressed("move_down"):
			frames.down.count += 5
			progress_bar_value += 1
			update_progress_bar()
	
	if Input.is_action_pressed("space") && bombs_in_storage > 0:
		bomb_in_next_turn = true
	
func handle_active_piece_falling_movement():
	
	if active_piece.type == "three_in_line":
		if frames.down.isMovable && is_tile_available(active_piece.pos).below:
			
			if active_piece.rotated:
				erase_cell(layer.active.id, active_piece.pos + Vector2i(1,0))
				erase_cell(layer.active.id, active_piece.pos)	
				erase_cell(layer.active.id, active_piece.pos + Vector2i(-1,0))	
			
			else: erase_cell(layer.active.id, active_piece.pos + Vector2i(0, -1))	
			
			active_piece.pos.y += 1
			frames.down.count = 0
			frames.down.isMovable = false 
		
		elif !is_tile_available(active_piece.pos).below: 
			handle_land()
			check_all_rows()
		
	else:	
		if frames.down.isMovable && is_tile_available(active_piece.pos).below:
			erase_cell(layer.active.id, active_piece.pos)	
			active_piece.pos.y += 1
			frames.down.count = 0
			frames.down.isMovable = false 
			
		elif !is_tile_available(active_piece.pos).below: 
			handle_land()
			check_all_rows()

func handle_active_layer_cell_setters():	
	if active_piece.type == "three_in_line":
		var col = active_piece.pos.x
		var row = active_piece.pos.y
		
		var set_positions
		
		if active_piece.rotated: 
			set_positions = [Vector2i(col - 1, row), Vector2i(col, row), Vector2i(col + 1, row)]
		else: 
			set_positions = [Vector2i(col, row + 1), Vector2i(col, row), Vector2i(col, row - 1)]
		
		for pos in set_positions:
			set_cell(
				layer.active.id, 
				pos, 
				source_id.blocks, 
				pieces[active_piece.index].atlas_coords
			)	
		
	else:
		set_cell(
			layer.active.id, 
			active_piece.pos, 
			source_id.blocks, 
			pieces[active_piece.index].atlas_coords
		)	
	
	
func handle_frame_count():
	for f in [frames.down, frames.right, frames.left, frames.rotate]:
		if f.count < f.required_for_move: f.count += 1
		elif !f.isMovable: f.isMovable = true 

func is_tile_available(pos):
	
	if active_piece.type == "three_in_line":
		if active_piece.rotated:
			return {
					"on_pos": get_cell_source_id(layer.board.id, pos) == -1 && is_on_board(pos),
					"below": get_cell_source_id(layer.board.id, pos + Vector2i(0,1)) == -1 && is_on_board(pos + Vector2i(0,1)),
					"left": get_cell_source_id(layer.board.id, pos + Vector2i(-2,0)) == -1 && 
							is_on_board(pos + Vector2i(-2,0)),
					"right":get_cell_source_id(layer.board.id, pos + Vector2i(2,0)) == -1 && 
							is_on_board(pos + Vector2i(2,0))
			}
		else:
			return {
				"on_pos": get_cell_source_id(layer.board.id, pos) == -1 && is_on_board(pos),
				"below": get_cell_source_id(layer.board.id, pos + Vector2i(0,2)) == -1 && is_on_board(pos + Vector2i(0,2)),
				"left": get_cell_source_id(layer.board.id, pos + Vector2i(-1,0)) == -1 && 
						get_cell_source_id(layer.board.id, pos + Vector2i(-1,1)) == -1 && 
						get_cell_source_id(layer.board.id, pos + Vector2i(-1,-1)) == -1 && 
						is_on_board(pos + Vector2i(-1,0)),
				"right":get_cell_source_id(layer.board.id, pos + Vector2i(1,0)) == -1 && 
						get_cell_source_id(layer.board.id, pos + Vector2i(1,1)) == -1 && 
						get_cell_source_id(layer.board.id, pos + Vector2i(1,-1)) == -1 && 
						is_on_board(pos + Vector2i(1,0))
			}
	else:
		return {
			"on_pos": get_cell_source_id(layer.board.id, pos) == -1 && is_on_board(pos),
			"below": get_cell_source_id(layer.board.id, pos + Vector2i(0,1)) == -1 && is_on_board(pos + Vector2i(0,1)),
			"left": get_cell_source_id(layer.board.id, pos + Vector2i(-1,0)) == -1 && is_on_board(pos + Vector2i(-1,0)),
			"right": get_cell_source_id(layer.board.id, pos + Vector2i(1,0)) == -1 && is_on_board(pos + Vector2i(1,0))
		}

func is_on_board(pos: Vector2i):
	var col = pos.x
	var row = pos.y
	
	if col in board.columns && row in board.rows:return true
	else: return false
	
func get_random_piece():
	var rand_index = randi() % 7
	var test_index = 7
	
	return {
		"index": test_index,
		"type": pieces[test_index].type
	}
	

func handle_land():
	# is it a bomb ?
	# TODO 
	# - the crystals shouldn't get destroyed by the bomb
	# - the pieces should re-arrange once the bomb explodes (pieces on top should fall if there are spaces below)
	#
	if pieces[active_piece.index].atlas_coords == get_piece_data().bomb.atlas_coords:
		# NOTE 
		# area of explosion:
		#
		#     X X X
		#     X B X 
		#     X X X
 		#
		
		# get the bomb column
		var bomb_col = active_piece.pos.x
		
		# get the bomb row
		var bomb_row = active_piece.pos.y
		
		# 1. remove the bomb from the active layer
		erase_cell(layer.active.id, active_piece.pos)
		
		# 2. destroy the non transparent pieces, on the board layer, sorrounding the bomb.
		for col in [bomb_col - 1, bomb_col, bomb_col + 1]:
			for row in [bomb_row - 1, bomb_row, bomb_row + 1]:
				if get_cell_atlas_coords(layer.board.id, Vector2i(col, row)) != get_piece_data().transparent_block.atlas_coords:
					erase_cell(layer.board.id, Vector2i(col, row))
	
		check_reposition_of_pieces = true
		
	else:
		if active_piece.type == "three_in_line":
			if active_piece.rotated:
				erase_cell(layer.active.id, active_piece.pos + Vector2i(1, 0))
				erase_cell(layer.active.id, active_piece.pos + Vector2i(-1, 0))
				erase_cell(layer.active.id, active_piece.pos)
				set_cell(layer.board.id, active_piece.pos + Vector2i(1, 0), 1, pieces[active_piece.index].atlas_coords)
				set_cell(layer.board.id, active_piece.pos + Vector2i(-1, 0), 1, pieces[active_piece.index].atlas_coords)
				set_cell(layer.board.id, active_piece.pos, 1, pieces[active_piece.index].atlas_coords)
			else:
				erase_cell(layer.active.id, active_piece.pos + Vector2i(0, 1))
				erase_cell(layer.active.id, active_piece.pos + Vector2i(0, -1))
				erase_cell(layer.active.id, active_piece.pos)
				set_cell(layer.board.id, active_piece.pos + Vector2i(0, 1), 1, pieces[active_piece.index].atlas_coords)
				set_cell(layer.board.id, active_piece.pos + Vector2i(0, -1), 1, pieces[active_piece.index].atlas_coords)
				set_cell(layer.board.id, active_piece.pos, 1, pieces[active_piece.index].atlas_coords)
		else:	
			erase_cell(layer.active.id, active_piece.pos)
			set_cell(layer.board.id, active_piece.pos, 1, pieces[active_piece.index].atlas_coords)
	
	
	active_piece.pos = active_piece.initial_position
	
	if bomb_in_next_turn:
		active_piece.index = bomb_index	
		bombs_in_storage -= 1
		update_bombs_label()
		bomb_in_next_turn = false
	else:	
		active_piece.index = get_random_piece().index

# WORK IN PROGRESS
func check_all_rows():
	for row in board.rows:
		var sum = 0
		var atlas_coords_to_match
		
		for col in board.columns:
			# if the tile is empty OR the piece is transparent, continue looking for the color piece on the row.
			# NOTE it is important to check if the tile is empty because it can also return a value for atlas_coords.
			if (is_tile_available(Vector2i(col, row)).on_pos || 
			(get_cell_atlas_coords(layer.board.id, Vector2i(col,row)) == get_piece_data().transparent_block.atlas_coords)):
				continue
				
			else: 
				atlas_coords_to_match = get_cell_atlas_coords(layer.board.id, Vector2i(col,row))
				break
		
		for col in board.columns: 
			var atlas_coords_of_tile = get_cell_atlas_coords(layer.board.id, Vector2i(col,row))
			
			# if the piece in the current tile is transparent or the matching atlas_coords sum up.
			if (atlas_coords_of_tile == get_piece_data().transparent_block.atlas_coords ||
			 atlas_coords_of_tile == atlas_coords_to_match): sum += 1
				
		if sum == len(board.columns):
			for col in board.columns: erase_cell(layer.board.id, Vector2i(col,row))
			
			# add points to the score
			score += 50
			update_score_label()
			
			check_reposition_of_pieces = true

# NOTE
# if there is a reposition of one or more pieces then
# the the function should be called again, until
# there are no repositions.
func reposition_pieces_if_needed():
	#check if there is an empty tile beneath each piece
	var rows_to_loop: Array = board.rows.slice(0,len(board.rows) - 1)
	var number_of_repositions = 0
	
	rows_to_loop.reverse()
	
	for row in rows_to_loop:
		for col in board.columns:
			
			# is there a piece in this tile ?
			if !is_tile_available(Vector2i(col, row)).on_pos:
				# is the tile beneath empty ?
				if is_tile_available(Vector2i(col, row)).below:
					# move the piece to the tile beneath
					var atlas_coords = get_cell_atlas_coords(layer.board.id, Vector2i(col, row))
					erase_cell(layer.board.id, Vector2i(col, row))
					set_cell(layer.board.id,  Vector2i(col, row + 1), 1, atlas_coords)
					
					number_of_repositions += 1
					
	if number_of_repositions > 0: check_reposition_of_pieces = true
	else: check_reposition_of_pieces = false				
					
					
					
					
	
