extends TileMap

const board = {
	"rows": [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
	"columns": [0,1,2,3,4,5,6,7,8]
}

# TODO
# - check and fix source ids across the code.
# - a good use of the source id might improve the code in a significant way.
const source_id = {
	"block": 1, 
	"crystal": 2
}

var layer = {
	"board": {"id": 0},
	"active": {"id": 1}
}

var frames = {
	"down": {"count":0, "required_for_move": 50, "isMovable": false},
	"right": {"count": 0, "required_for_move": 15, "isMovable": false},
	"left": {"count": 0, "required_for_move": 15, "isMovable": false},
	"rotate": {"count": 0, "required_for_move": 30, "isMovable": false},
	"reposition": {"count": 0, "required": 20},
}

var pieces = [
	{
		"type": "block", 
		"atlas": Vector2i(0,0)	
	},
	{
		"type": "block", 
		"atlas": Vector2i(1,0)	
	},
	{
		"type": "block", 
		"atlas": Vector2i(2,0)	
	},
	{
		"type": "block", 
		"atlas": Vector2i(3,0)	
	},
	{
		"type": "block", 
		"atlas": Vector2i(4,0)	
	},
	{
		"type": "block", 
		"atlas": Vector2i(5,0)	
	},
	{
		"type": "crystal", 
		"atlas": Vector2i(6,0)	
	},
	{
		"type": "crystal_rectangle",
		"atlas": Vector2i(6,0)
	},
	{
		"type": "bomb", 
		"atlas": Vector2i(7,0)	
	}
]

var active_piece = {
	"initial_pos": Vector2i(4, 0),
	"index": null,
	"type": null,
	"pos": null,
	"rotated": false
}

var score = 0
var progress_bar_value = 0
var bombs_in_storage = 0
var check_reposition_of_pieces = false
var bomb_in_next_turn = false

# TODO improve this
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
	active_piece.pos = active_piece.initial_pos
	new_active_random_piece()
	
# TODO improve this	
# with source id this might not be necessary
func get_piece_data():
	return {
		"crystal": pieces[6],
		"crystal_rectangle": pieces[7],
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
	
	if active_piece.type == "crystal_rectangle":
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
	
	if active_piece.type == "crystal_rectangle":
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
	if active_piece.type == "crystal_rectangle":
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
				source_id.block, 
				pieces[active_piece.index].atlas
			)	
		
	else:
		set_cell(
			layer.active.id, 
			active_piece.pos, 
			source_id.block, 
			pieces[active_piece.index].atlas
		)	
	
	
func handle_frame_count():
	for f in [frames.down, frames.right, frames.left, frames.rotate]:
		if f.count < f.required_for_move: f.count += 1
		elif !f.isMovable: f.isMovable = true 

func is_tile_available(pos: Vector2i):
	
	if active_piece.type == "crystal_rectangle":
		if active_piece.rotated:
			return {
					"on_pos": get_cell_source_id(layer.board.id, pos) == -1 && is_on_board(pos),
					"below": get_cell_source_id(layer.board.id, pos + Vector2i(1,1)) == -1 &&
							 get_cell_source_id(layer.board.id, pos + Vector2i(0,1)) == -1 &&
							 get_cell_source_id(layer.board.id, pos + Vector2i(-1,1)) == -1 &&
							 is_on_board(pos + Vector2i(0,1)),
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
	
func new_active_random_piece():
	var rand_index = randi() % 8
	# var test_index = 7
	
	active_piece.index = rand_index
	active_piece.type = pieces[rand_index].type
	
func handle_land():
	# is it a bomb ?
	# TODO 
	# - the crystals shouldn't get destroyed by the bomb
	# - the pieces should re-arrange once the bomb explodes (pieces on top should fall if there are spaces below)
	#
	if pieces[active_piece.index].atlas == get_piece_data().bomb.atlas:
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
		
		# 2. destroy the non crystal pieces, on the board layer, sorrounding the bomb.
		for col in [bomb_col - 1, bomb_col, bomb_col + 1]:
			for row in [bomb_row - 1, bomb_row, bomb_row + 1]:
				if get_cell_atlas_coords(layer.board.id, Vector2i(col, row)) != get_piece_data().crystal.atlas:
					erase_cell(layer.board.id, Vector2i(col, row))
	
		check_reposition_of_pieces = true
		
	else:
		if active_piece.type == "crystal_rectangle":
			if active_piece.rotated:
				erase_cell(layer.active.id, active_piece.pos + Vector2i(1, 0))
				erase_cell(layer.active.id, active_piece.pos + Vector2i(-1, 0))
				erase_cell(layer.active.id, active_piece.pos)
				set_cell(layer.board.id, active_piece.pos + Vector2i(1, 0), 1, pieces[active_piece.index].atlas)
				set_cell(layer.board.id, active_piece.pos + Vector2i(-1, 0), 1, pieces[active_piece.index].atlas)
				set_cell(layer.board.id, active_piece.pos, 1, pieces[active_piece.index].atlas)
			else:
				erase_cell(layer.active.id, active_piece.pos + Vector2i(0, 1))
				erase_cell(layer.active.id, active_piece.pos + Vector2i(0, -1))
				erase_cell(layer.active.id, active_piece.pos)
				set_cell(layer.board.id, active_piece.pos + Vector2i(0, 1), 1, pieces[active_piece.index].atlas)
				set_cell(layer.board.id, active_piece.pos + Vector2i(0, -1), 1, pieces[active_piece.index].atlas)
				set_cell(layer.board.id, active_piece.pos, 1, pieces[active_piece.index].atlas)
		else:	
			erase_cell(layer.active.id, active_piece.pos)
			set_cell(layer.board.id, active_piece.pos, 1, pieces[active_piece.index].atlas)
	
	
	active_piece.pos = active_piece.initial_pos
	
	if bomb_in_next_turn:
		active_piece.index = bomb_index	
		bombs_in_storage -= 1
		update_bombs_label()
		bomb_in_next_turn = false
	else:	
		new_active_random_piece()

func has_crystal(layer_id, pos: Vector2i):
	return get_cell_atlas_coords(layer_id, pos) == get_piece_data().crystal.atlas

# source id might improve the function below
func check_all_rows():
	for row in board.rows:
		var sum = 0
		var atlas
		
		## NOTE
		# - if the tile is empty OR the piece is crystal, continue looking for the color piece on the row.
		# - it is important to check if the tile is empty because it can also return a value for atlas_coords.
		###
		for col in board.columns:
			if is_tile_available(Vector2i(col, row)).on_pos || has_crystal(layer.board.id, Vector2i(col,row)):
				continue
				
			else: 
				atlas = get_cell_atlas_coords(layer.board.id, Vector2i(col,row))
				break
		
		for col in board.columns: 
			if (get_cell_atlas_coords(layer.board.id, Vector2i(col,row)) == get_piece_data().crystal.atlas ||
			 get_cell_atlas_coords(layer.board.id, Vector2i(col,row)) == atlas): sum += 1
				
		if sum == len(board.columns):
			for col in board.columns: erase_cell(layer.board.id, Vector2i(col,row))
			
			# add points to the score
			score += 50
			update_score_label()
			
			check_reposition_of_pieces = true

 
## NOTE 
# If there is a reposition of one or more pieces then the the function should be
# called again, until there are no repositions.
####
func reposition_pieces_if_needed():
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
					var atlas = get_cell_atlas_coords(layer.board.id, Vector2i(col, row))
					erase_cell(layer.board.id, Vector2i(col, row))
					set_cell(layer.board.id,  Vector2i(col, row + 1), 1, atlas)
					
					number_of_repositions += 1
								
	if number_of_repositions > 0: check_reposition_of_pieces = true
	else: check_reposition_of_pieces = false				
					
					
					
					
	
