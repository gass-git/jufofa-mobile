extends TileMap

# called when the node enters the scene tree for the first time.
func _ready():
	create_first_piece()

# NOTE
# -> called every frame.
# -> delta is the elapsed time since the previous frame.
func _process(_delta):
	handle_movements()
	handle_frame_count()
	
	if global.check_reposition_of_pieces && global.frames.reposition.count > global.frames.reposition.required: 
		reposition_pieces_if_needed()
		global.frames.reposition.count = 0
	else: global.frames.reposition.count += 1
	
	# when the progress bar reaches its max value reset to 0 and add a bomb to the storage
	if global.progress_bar_value == $HUD.get_node("ProgressBar").max_value: 
		global.progress_bar_value = 0
		update_progress_bar()
		global.bombs_in_storage += 1
		update_bombs_label()
	
func create_first_piece():
	global.active_piece.pos = global.active_piece.initial_pos
	new_active_random_piece()
	
# TODO improve this	
# with source id this might not be necessary
func get_piece_data():
	return {
		"crystal": global.pieces[6],
		"crystal_rectangle": global.pieces[7],
		"bomb": global.pieces[8]
	}	
	
func update_score_label():
	$HUD.get_node("ScoreLabel").text = str(global.score)
	
func update_progress_bar():
	$HUD.get_node("ProgressBar").value = global.progress_bar_value	
	
func update_bombs_label():
	$HUD.get_node("BombsInStorage").text = "BOMBS:" + str(global.bombs_in_storage)	
	
func handle_movements():
	handle_active_piece_falling_movement()
	handle_user_input()
	handle_active_layer_cell_setters()
	
func handle_user_input():
	
	if global.active_piece.type == "crystal_rectangle":
		if Input.is_action_pressed("move_right") && global.frames.right.isMovable && is_tile_available(global.active_piece.pos).right:
			if global.active_piece.rotated:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(-1, 0))
				
			else:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, 1))
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, -1))
				
			erase_cell(global.layer.active.id, global.active_piece.pos)
			global.active_piece.pos.x += 1
			global.frames.right.count = 0
			global.frames.right.isMovable = false
		
		if Input.is_action_pressed("move_left") && global.frames.left.isMovable && is_tile_available(global.active_piece.pos).left:
			if global.active_piece.rotated:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(1, 0))
			
			else:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, 1))
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, -1))
			
			erase_cell(global.layer.active.id, global.active_piece.pos)
			global.active_piece.pos.x -= 1
			global.frames.left.count = 0
			global.frames.left.isMovable = false
		
		if Input.is_action_pressed("up") && global.frames.rotate.isMovable:
			if !global.active_piece.rotated:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0,1))
				erase_cell(global.layer.active.id, global.active_piece.pos)	
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0,-1))	
			
			else: 
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(1,0))	
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(-1,0))	
				
			global.active_piece.rotated = !global.active_piece.rotated	
			
			global.frames.rotate.count = 0
			global.frames.rotate.isMovable = false
		
		if Input.is_action_pressed("move_down"):
			global.frames.down.count += 5
			global.progress_bar_value += 1
			update_progress_bar()
		
	else:
		if Input.is_action_pressed("move_right") && global.frames.right.isMovable && is_tile_available(global.active_piece.pos).right:
			erase_cell(global.layer.active.id, global.active_piece.pos)
			global.active_piece.pos.x += 1
			global.frames.right.count = 0
			global.frames.right.isMovable = false
		
		if Input.is_action_pressed("move_left") && global.frames.left.isMovable && is_tile_available(global.active_piece.pos).left:
			erase_cell(global.layer.active.id, global.active_piece.pos)
			global.active_piece.pos.x -= 1
			global.frames.left.count = 0
			global.frames.left.isMovable = false
		
		if Input.is_action_pressed("move_down"):
			global.frames.down.count += 5
			global.progress_bar_value += 1
			update_progress_bar()
	
	if Input.is_action_pressed("space") && global.bombs_in_storage > 0:
		global.bomb_in_next_turn = true
	
func handle_active_piece_falling_movement():
	
	if global.active_piece.type == "crystal_rectangle":
		if global.frames.down.isMovable && is_tile_available(global.active_piece.pos).below:
			
			if global.active_piece.rotated:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(1,0))
				erase_cell(global.layer.active.id, global.active_piece.pos)	
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(-1,0))	
			
			else: erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, -1))	
			
			global.active_piece.pos.y += 1
			global.frames.down.count = 0
			global.frames.down.isMovable = false 
		
		elif !is_tile_available(global.active_piece.pos).below: 
			handle_land()
			check_all_rows()
		
	else:	
		if global.frames.down.isMovable && is_tile_available(global.active_piece.pos).below:
			erase_cell(global.layer.active.id, global.active_piece.pos)	
			global.active_piece.pos.y += 1
			global.frames.down.count = 0
			global.frames.down.isMovable = false 
			
		elif !is_tile_available(global.active_piece.pos).below: 
			handle_land()
			check_all_rows()

func handle_active_layer_cell_setters():	
	if global.active_piece.type == "crystal_rectangle":
		var col = global.active_piece.pos.x
		var row = global.active_piece.pos.y
		var set_positions
		
		if global.active_piece.rotated: 
			set_positions = [Vector2i(col - 1, row), Vector2i(col, row), Vector2i(col + 1, row)]
		else: 
			set_positions = [Vector2i(col, row + 1), Vector2i(col, row), Vector2i(col, row - 1)]
		
		for pos in set_positions:
			set_cell(
				global.layer.active.id, 
				pos, 
				global.source_id.block, 
				global.pieces[global.active_piece.index].atlas
			)	
		
	else:
		set_cell(
			global.layer.active.id, 
			global.active_piece.pos, 
			global.source_id.block, 
			global.pieces[global.active_piece.index].atlas
		)	
	
	
func handle_frame_count():
	for f in [global.frames.down, global.frames.right, global.frames.left, global.frames.rotate]:
		if f.count < f.required_for_move: f.count += 1
		elif !f.isMovable: f.isMovable = true 

func is_tile_available(pos: Vector2i):
	
	if global.active_piece.type == "crystal_rectangle":
		if global.active_piece.rotated:
			return {
					"on_pos": get_cell_source_id(global.layer.board.id, pos) == -1 && is_on_board(pos),
					"below": get_cell_source_id(global.layer.board.id, pos + Vector2i(1,1)) == -1 &&
							 get_cell_source_id(global.layer.board.id, pos + Vector2i(0,1)) == -1 &&
							 get_cell_source_id(global.layer.board.id, pos + Vector2i(-1,1)) == -1 &&
							 is_on_board(pos + Vector2i(0,1)),
					"left": get_cell_source_id(global.layer.board.id, pos + Vector2i(-2,0)) == -1 && 
							is_on_board(pos + Vector2i(-2,0)),
					"right":get_cell_source_id(global.layer.board.id, pos + Vector2i(2,0)) == -1 && 
							is_on_board(pos + Vector2i(2,0))
			}
		else:
			return {
				"on_pos": get_cell_source_id(global.layer.board.id, pos) == -1 && is_on_board(pos),
				"below": get_cell_source_id(global.layer.board.id, pos + Vector2i(0,2)) == -1 && is_on_board(pos + Vector2i(0,2)),
				"left": get_cell_source_id(global.layer.board.id, pos + Vector2i(-1,0)) == -1 && 
						get_cell_source_id(global.layer.board.id, pos + Vector2i(-1,1)) == -1 && 
						get_cell_source_id(global.layer.board.id, pos + Vector2i(-1,-1)) == -1 && 
						is_on_board(pos + Vector2i(-1,0)),
				"right":get_cell_source_id(global.layer.board.id, pos + Vector2i(1,0)) == -1 && 
						get_cell_source_id(global.layer.board.id, pos + Vector2i(1,1)) == -1 && 
						get_cell_source_id(global.layer.board.id, pos + Vector2i(1,-1)) == -1 && 
						is_on_board(pos + Vector2i(1,0))
			}
	else:
		return {
			"on_pos": get_cell_source_id(global.layer.board.id, pos) == -1 && is_on_board(pos),
			"below": get_cell_source_id(global.layer.board.id, pos + Vector2i(0,1)) == -1 && is_on_board(pos + Vector2i(0,1)),
			"left": get_cell_source_id(global.layer.board.id, pos + Vector2i(-1,0)) == -1 && is_on_board(pos + Vector2i(-1,0)),
			"right": get_cell_source_id(global.layer.board.id, pos + Vector2i(1,0)) == -1 && is_on_board(pos + Vector2i(1,0))
		}

func is_on_board(pos: Vector2i):
	var col = pos.x
	var row = pos.y
	
	if col in global.board.columns && row in global.board.rows:return true
	else: return false
	
func new_active_random_piece():
	var rand_index = randi() % 8
	# var test_index = 7
	
	global.active_piece.index = rand_index
	global.active_piece.type = global.pieces[rand_index].type
	
func handle_land():
	# is it a bomb ?
	# TODO 
	# - the crystals shouldn't get destroyed by the bomb
	# - the pieces should re-arrange once the bomb explodes (pieces on top should fall if there are spaces below)
	#
	if global.pieces[global.active_piece.index].atlas == get_piece_data().bomb.atlas:
		# NOTE 
		# area of explosion:
		#
		#     X X X
		#     X B X 
		#     X X X
 		#
		
		# get the bomb column
		var bomb_col = global.active_piece.pos.x
		
		# get the bomb row
		var bomb_row = global.active_piece.pos.y
		
		# 1. remove the bomb from the active layer
		erase_cell(global.layer.active.id, global.active_piece.pos)
		
		# 2. destroy the non crystal pieces, on the board layer, sorrounding the bomb.
		for col in [bomb_col - 1, bomb_col, bomb_col + 1]:
			for row in [bomb_row - 1, bomb_row, bomb_row + 1]:
				if get_cell_atlas_coords(global.layer.board.id, Vector2i(col, row)) != get_piece_data().crystal.atlas:
					erase_cell(global.layer.board.id, Vector2i(col, row))
	
		global.check_reposition_of_pieces = true
		
	else:
		if global.active_piece.type == "crystal_rectangle":
			if global.active_piece.rotated:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(1, 0))
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(-1, 0))
				erase_cell(global.layer.active.id, global.active_piece.pos)
				set_cell(global.layer.board.id, global.active_piece.pos + Vector2i(1, 0), 1, global.pieces[global.active_piece.index].atlas)
				set_cell(global.layer.board.id, global.active_piece.pos + Vector2i(-1, 0), 1, global.pieces[global.active_piece.index].atlas)
				set_cell(global.layer.board.id, global.active_piece.pos, 1, global.pieces[global.active_piece.index].atlas)
			else:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, 1))
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, -1))
				erase_cell(global.layer.active.id, global.active_piece.pos)
				set_cell(global.layer.board.id, global.active_piece.pos + Vector2i(0, 1), 1, global.pieces[global.active_piece.index].atlas)
				set_cell(global.layer.board.id, global.active_piece.pos + Vector2i(0, -1), 1, global.pieces[global.active_piece.index].atlas)
				set_cell(global.layer.board.id, global.active_piece.pos, 1, global.pieces[global.active_piece.index].atlas)
		else:	
			erase_cell(global.layer.active.id, global.active_piece.pos)
			set_cell(global.layer.board.id, global.active_piece.pos, 1, global.pieces[global.active_piece.index].atlas)
	
	
	global.active_piece.pos = global.active_piece.initial_pos
	
	if global.bomb_in_next_turn:
		global.active_piece.index = global.bomb_index	
		global.bombs_in_storage -= 1
		update_bombs_label()
		global.bomb_in_next_turn = false
	else:	
		new_active_random_piece()

func has_crystal(layer_id, pos: Vector2i):
	return get_cell_atlas_coords(layer_id, pos) == get_piece_data().crystal.atlas

# source id might improve the function below
func check_all_rows():
	for row in global.board.rows:
		var sum = 0
		var atlas
		
		## NOTE
		# - if the tile is empty OR the piece is crystal, continue looking for the color piece on the row.
		# - it is important to check if the tile is empty because it can also return a value for atlas_coords.
		###
		for col in global.board.columns:
			if is_tile_available(Vector2i(col, row)).on_pos || has_crystal(global.layer.board.id, Vector2i(col,row)):
				continue
				
			else: 
				atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
				break
		
		for col in global.board.columns: 
			if (get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row)) == get_piece_data().crystal.atlas ||
			 get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row)) == atlas): sum += 1
				
		if sum == len(global.board.columns):
			for col in global.board.columns: erase_cell(global.layer.board.id, Vector2i(col,row))
			
			# add points to the score
			global.score += 50
			update_score_label()
			
			global.check_reposition_of_pieces = true

 
## NOTE 
# If there is a reposition of one or more pieces then the the function should be
# called again, until there are no repositions.
####
func reposition_pieces_if_needed():
	var rows_to_loop: Array = global.board.rows.slice(0,len(global.board.rows) - 1)
	var number_of_repositions = 0
	
	rows_to_loop.reverse()
	
	for row in rows_to_loop:
		for col in global.board.columns:
			
			# is there a piece in this tile ?
			if !is_tile_available(Vector2i(col, row)).on_pos:
				# is the tile beneath empty ?
				if is_tile_available(Vector2i(col, row)).below:
					# move the piece to the tile beneath
					var atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col, row))
					erase_cell(global.layer.board.id, Vector2i(col, row))
					set_cell(global.layer.board.id,  Vector2i(col, row + 1), 1, atlas)
					
					number_of_repositions += 1
								
	if number_of_repositions > 0: global.check_reposition_of_pieces = true
	else: global.check_reposition_of_pieces = false				
					
					
					
					
	
