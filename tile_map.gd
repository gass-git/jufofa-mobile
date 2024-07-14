extends TileMap

# NOTE called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.create_first_piece($HUD)
	utils.build_board_matrix()

# NOTE
# -> called every frame.
# -> delta is the elapsed time since the previous frame.
func _process(_delta) -> void:
	handle_movements()
	handle_frame_count()
	handle_check_reposition_of_pieces()
	gui.handle_progress_bar_completion($HUD)
	
func handle_check_reposition_of_pieces() -> void:
	if global.check_reposition_of_pieces && global.frames.reposition.count > global.frames.reposition.required: 
		reposition_pieces_if_needed()
		global.frames.reposition.count = 0
		
	global.frames.reposition.count += 1
	
func handle_movements() -> void:
	handle_active_piece_falling_movement()
	handle_user_input()
	handle_cell_setters(global.layer.active.id)
	
func handle_user_input() -> void:
	if global.active_piece.name == "crystal_brick":
		if Input.is_action_pressed("move_right") && global.frames.right.isMovable && can_move(global.active_piece.pos, Dir.RIGHT):
			if global.active_piece.horizontal:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(-1, 0))
				
			else:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, 1))
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, -1))
				
			erase_cell(global.layer.active.id, global.active_piece.pos)
			global.active_piece.pos.x += 1
			global.frames.right.count = 0
			global.frames.right.isMovable = false
		
		if Input.is_action_pressed("move_left") && global.frames.left.isMovable && can_move(global.active_piece.pos, Dir.LEFT):
			if global.active_piece.horizontal:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(1, 0))
			
			else:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, 1))
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, -1))
			
			erase_cell(global.layer.active.id, global.active_piece.pos)
			global.active_piece.pos.x -= 1
			global.frames.left.count = 0
			global.frames.left.isMovable = false
		
		if Input.is_action_pressed("up") && global.frames.rotate.isMovable && brick_can_rotate(global.active_piece.pos):
			if !global.active_piece.horizontal:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0,1))
				erase_cell(global.layer.active.id, global.active_piece.pos)	
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0,-1))	
			
			else: 
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(1,0))	
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(-1,0))	
				
			global.active_piece.horizontal = !global.active_piece.horizontal	
			
			global.frames.rotate.count = 0
			global.frames.rotate.isMovable = false
		
		if Input.is_action_pressed("move_down"):
			global.frames.down.count += 5
			global.progress_bar_value += 2
			gui.update_progress_bar($HUD)
		
	else:
		if Input.is_action_pressed("move_right") && global.frames.right.isMovable && can_move(global.active_piece.pos, Dir.RIGHT):
			erase_cell(global.layer.active.id, global.active_piece.pos)
			global.active_piece.pos.x += 1
			global.frames.right.count = 0
			global.frames.right.isMovable = false
		
		if Input.is_action_pressed("move_left") && global.frames.left.isMovable && can_move(global.active_piece.pos, Dir.LEFT):
			erase_cell(global.layer.active.id, global.active_piece.pos)
			global.active_piece.pos.x -= 1
			global.frames.left.count = 0
			global.frames.left.isMovable = false
		
		if Input.is_action_pressed("move_down"):
			global.frames.down.count += 5
			global.progress_bar_value += 2
			gui.update_progress_bar($HUD)
	
	if Input.is_action_pressed("space") && global.bombs_in_storage > 0:
		global.bomb_in_next_turn = true
	
func brick_can_rotate(pos: Vector2i) -> bool:
	## NOTE
	# c: center piece position
	# x: positions that must be available to rotate
	#
	#    x x x
	#    x c x
	#    x x x
	#
	####
	var deltas = [
		Vector2i(1,0), Vector2i(1,1), Vector2i(1,-1), 
		Vector2i(-1,0), Vector2i(-1,-1), Vector2i(-1, 1),
		Vector2i(1,1), Vector2i(0,1), Vector2i(-1,1)
	]
	
	for d in deltas:
		var empty = get_cell_source_id(global.layer.board.id, pos + d) == -1
			
		if empty && is_on_board(pos + d): continue
		else: return false
				
	return true
	
func handle_active_piece_falling_movement() -> void:
	
	if global.active_piece.name == "crystal_brick":
		if global.frames.down.isMovable && can_move(global.active_piece.pos, Dir.BELOW):
			
			if global.active_piece.horizontal:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(1,0))
				erase_cell(global.layer.active.id, global.active_piece.pos)	
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(-1,0))	
			
			else: erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, -1))	
			
			global.active_piece.pos.y += 1
			global.frames.down.count = 0
			global.frames.down.isMovable = false 
		
		elif !can_move(global.active_piece.pos, Dir.BELOW): 
			handle_land()
			handle_rows_removal()
		
	else:	
		if global.frames.down.isMovable && can_move(global.active_piece.pos, Dir.BELOW):
			erase_cell(global.layer.active.id, global.active_piece.pos)	
			global.active_piece.pos.y += 1
			global.frames.down.count = 0
			global.frames.down.isMovable = false 
			
		elif !can_move(global.active_piece.pos, Dir.BELOW): 
			handle_land()
			handle_rows_removal()

func handle_cell_setters(layer_id: int) -> void:	
	if global.active_piece.name == "crystal_brick":
		var col = global.active_piece.pos.x
		var row = global.active_piece.pos.y
		var positions_to_set
		var atlases_to_set
		
		if global.active_piece.horizontal: 
			positions_to_set = [Vector2i(col - 1, row), Vector2i(col, row), Vector2i(col + 1, row)]
			atlases_to_set = global.active_piece.atlas.horizontal
			
		else: 
			positions_to_set = [Vector2i(col, row + 1), Vector2i(col, row), Vector2i(col, row - 1)]
			atlases_to_set = global.active_piece.atlas.vertical
		
		for i in [0,1,2]:
			set_cell(
				layer_id, 
				positions_to_set[i], 
				global.active_piece.source_id, 
				atlases_to_set[i]
			)	
		
	else:
		set_cell(
			layer_id, 
			global.active_piece.pos, 
			global.active_piece.source_id, 
			global.active_piece.atlas
		)	
	
	
func handle_frame_count() -> void:
	for f in [global.frames.down, global.frames.right, global.frames.left, global.frames.rotate]:
		if f.count < f.required_for_move: f.count += 1
		elif !f.isMovable: f.isMovable = true 

enum Dir {
	RIGHT,
	LEFT,
	BELOW
}

func can_move(pos: Vector2i, direction: Dir) -> bool:
	var data = {"right":[], "left":[], "below":[]}
	var empty	
	
	if global.active_piece.name == "crystal_brick":
		if global.active_piece.horizontal:
			data.right = [pos + Vector2i(2,0)]
			data.left = [pos + Vector2i(-2,0)]
			data.below = [pos + Vector2i(1,1), pos + Vector2i(0,1), pos + Vector2i(-1,1)]
		else:
			data.right = [pos + Vector2i(1,0), pos + Vector2i(1,1), pos + Vector2i(1,-1)]
			data.left = [pos + Vector2i(-1,0), pos + Vector2i(-1,1), pos + Vector2i(-1,-1)]
			data.below = [pos + Vector2i(0,2)]
			
	else:
		data.right = [pos + Vector2i(1,0)]		
		data.left = [pos + Vector2i(-1,0)]
		data.below = [pos + Vector2i(0,1)]
	
	match direction:
		Dir.RIGHT:
			for coord in data.right:
				empty = get_cell_source_id(global.layer.board.id, coord) == -1
				
				if empty && is_on_board(coord): continue
				else: return false
			
		Dir.LEFT:
			for coord in data.left:
				empty = get_cell_source_id(global.layer.board.id, coord) == -1
				
				if empty && is_on_board(coord): continue
				else: return false
			
		Dir.BELOW:
			for coord in data.below:
				empty = get_cell_source_id(global.layer.board.id, coord) == -1
				
				if empty && is_on_board(coord): continue
				else: return false
				
	return true
		
func is_tile_empty(pos: Vector2i) -> bool:
	return (get_cell_source_id(global.layer.board.id, pos) == -1 && is_on_board(pos))

func is_on_board(pos: Vector2i) -> bool:
	var col = pos.x
	var row = pos.y
	
	if col in global.board.columns && row in global.board.rows:return true
	else: return false
	
func handle_land() -> void:
	if global.active_piece.name == "bomb":
		# NOTE 
		# area of destruction:
		#
		#     X X X
		#     X B X 
		#     X X X
 		#
		var bomb = { "col": global.active_piece.pos.x, "row":global.active_piece.pos.y }
		
		# 1. remove the bomb from the active layer
		erase_cell(global.layer.active.id, global.active_piece.pos)
		
		# 2. destroy the non crystal pieces
		for col in [bomb.col - 1, bomb.col, bomb.col + 1]:
			for row in [bomb.row - 1, bomb.row, bomb.row + 1]:
				#print("col: " + str(col))
				#print("row: " + str(row))
				#print("has crystal: " + str(has_crystal(global.layer.board.id, Vector2i(col,row))))
				#print("to potentially erase in row: " + str(row))
				#print("is tile empty: " + str(is_tile_empty(Vector2i(col,row))))
				
				if has_crystal(global.layer.board.id, Vector2i(col,row)):	
					handle_crystal_shatter_destruction(Vector2i(col,row))
					handle_crystal_shatter(Vector2i(col,row))
					
				else: erase_cell(global.layer.board.id, Vector2i(col,row))
						
		global.check_reposition_of_pieces = true
		
	else:
		if global.active_piece.name == "crystal_brick":
			if global.active_piece.horizontal:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(1, 0))
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(-1, 0))
				erase_cell(global.layer.active.id, global.active_piece.pos)
			else:
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, 1))
				erase_cell(global.layer.active.id, global.active_piece.pos + Vector2i(0, -1))
				erase_cell(global.layer.active.id, global.active_piece.pos)
				
				global.number_of_vertical_bricks_on_board += 1
		
		else:	
			erase_cell(global.layer.active.id, global.active_piece.pos)
		
		handle_cell_setters(global.layer.board.id)
	
	global.active_piece.pos = global.active_piece.initial_pos
	
	global.set_next_piece($HUD)

# TODO: add mechanisms to destroy shattered VERTICAL BRICKS
func handle_crystal_shatter_destruction(pos: Vector2i) -> void:
	# if it is a shattered BLOCK go ahead and destroy it
	if get_cell_source_id(global.layer.board.id, pos) == 3:
		erase_cell(global.layer.board.id, pos)
		
	# these tiles are a part of some shattered BRICK
	if get_cell_source_id(global.layer.board.id, pos) == 4:
		
		var C = [
			get_cell_atlas_coords(global.layer.board.id, pos) == Vector2i(3,0),
			get_cell_atlas_coords(global.layer.board.id, pos) == Vector2i(4,0),
			get_cell_atlas_coords(global.layer.board.id, pos) == Vector2i(5,0)
		]
		
		# is it in a horizontal brick ?
		if C[0] || C[1] || C[2]:
			
			# is it the left tile ?
			if C[0]: 
				# check if all tiles to the right of the BRICK are shattered
				# if not, shatter the one that is not shattered (maybe this should go in: handle_crystal_shatter())
				var condition = [
					get_cell_atlas_coords(global.layer.board.id, pos + Vector2i(1,0)) == Vector2i(4,0),
					get_cell_atlas_coords(global.layer.board.id, pos + Vector2i(2,0)) == Vector2i(5,0)
				]
				
				if condition[0] && condition[1]: 
					# destroy horizontal shattered crystal brick
					erase_cell(global.layer.board.id, pos)
					erase_cell(global.layer.board.id, pos + Vector2i(1,0))
					erase_cell(global.layer.board.id, pos + Vector2i(2,0))
					
			
			# is it the middle tile ?
			if C[1]:
				# check if tiles to the right and left of the BRICK are shattered
				# if not, shatter the one that is not shattered (maybe this should go in: handle_crystal_shatter())
				var condition = [
					get_cell_atlas_coords(global.layer.board.id, pos - Vector2i(1,0)) == Vector2i(3,0),
					get_cell_atlas_coords(global.layer.board.id, pos + Vector2i(1,0)) == Vector2i(5,0)
				]
				
				if condition[0] && condition[1]: 
					# destroy horizontal shattered crystal brick
					erase_cell(global.layer.board.id, pos)
					erase_cell(global.layer.board.id, pos - Vector2i(1,0))
					erase_cell(global.layer.board.id, pos + Vector2i(1,0))
				
			# is it the right tile ?
			if C[2]:
				# check if all tiles to the left of the BRICK are shattered
				# if not, shatter the one that is not shattered (maybe this should go in: handle_crystal_shatter())
				var condition = [
					get_cell_atlas_coords(global.layer.board.id, pos - Vector2i(1,0)) == Vector2i(4,0),
					get_cell_atlas_coords(global.layer.board.id, pos - Vector2i(2,0)) == Vector2i(3,0)
				]
				
				if condition[0] && condition[1]: 
					# destroy horizontal shattered crystal brick
					erase_cell(global.layer.board.id, pos)
					erase_cell(global.layer.board.id, pos - Vector2i(1,0))
					erase_cell(global.layer.board.id, pos - Vector2i(2,0))

# NOTE
# for the moment this function ONLY works for crystal BLOCKS
# PENDING - TODO: add functionality for crystal bricks
func handle_crystal_shatter(pos: Vector2i) -> void: 
	# returns a pseudo-random float between 0.0 and 1.0 (inclusive).
	var random_number = randf()
	var shatter_crystal_block = random_number <= global.probability.crystal_block_shatter
	var shatter_crystal_brick = random_number <= global.probability.crystal_brick_shatter
	var is_crystal_block = get_cell_atlas_coords(global.layer.board.id, pos) == utils.get_piece_data(global.Pieces.CRYSTAL_BLOCK_ID).atlas && get_cell_source_id(global.layer.board.id, pos) == utils.get_piece_data(global.Pieces.CRYSTAL_BLOCK_ID).source_id
	var is_crystal_brick = get_cell_source_id(global.layer.board.id, pos) == utils.get_piece_data(global.Pieces.CRYSTAL_BRICK_ID).source_id	
	
	#print("random number: " + str(random_number))
	#print("shatter ? " + str(shatter_crystal_block))
	
	if has_crystal(global.layer.board.id, pos):
		if is_crystal_block:
			if shatter_crystal_block: shatter("crystal_block", pos)
			
		# if its not a crystal BLOCK, it is a crystal BRICK
		else: 
			if shatter_crystal_brick: shatter("crystal_brick", pos)
						
func shatter(crystal_type: String, pos: Vector2i) -> void:
	if crystal_type == "crystal_block":
		erase_cell(global.layer.board.id, pos)	
		set_cell(
			global.layer.board.id, 
			pos, 
			utils.get_piece_data(global.Pieces.SHATTERED_CRYSTAL_BLOCK_ID).source_id, 
			utils.get_piece_data(global.Pieces.SHATTERED_CRYSTAL_BLOCK_ID).atlas
		)
	
	# NOTE: some values below will be hard coded for now
	elif crystal_type == "crystal_brick":
		if get_cell_atlas_coords(global.layer.board.id, pos) == Vector2i(3,0):
			erase_cell(global.layer.board.id, pos)
			set_cell(global.layer.board.id, pos, 4, Vector2i(3,0))

		if get_cell_atlas_coords(global.layer.board.id, pos) == Vector2i(4,0):
			erase_cell(global.layer.board.id, pos)	
			set_cell(global.layer.board.id, pos, 4, Vector2i(4,0))
			
		if get_cell_atlas_coords(global.layer.board.id, pos) == Vector2i(5,0):
			erase_cell(global.layer.board.id, pos)	
			set_cell(global.layer.board.id, pos, 4, Vector2i(5,0))
			
		if get_cell_atlas_coords(global.layer.board.id, pos) == Vector2i(0,0):
			erase_cell(global.layer.board.id, pos)
			set_cell(global.layer.board.id, pos, 4, Vector2i(0,0))

		if get_cell_atlas_coords(global.layer.board.id, pos) == Vector2i(1,0):
			erase_cell(global.layer.board.id, pos)	
			set_cell(global.layer.board.id, pos, 4, Vector2i(1,0))
			
		if get_cell_atlas_coords(global.layer.board.id, pos) == Vector2i(2,0):
			erase_cell(global.layer.board.id, pos)	
			set_cell(global.layer.board.id, pos, 4, Vector2i(2,0))
		

func has_crystal_block(layer_id: int, pos: Vector2i) -> bool:
	if get_cell_atlas_coords(layer_id, pos) == utils.get_piece_data(global.Pieces.CRYSTAL_BLOCK_ID).atlas: return true
	else: return false

func has_crystal(layer_id: int, pos: Vector2i) -> bool:
	# NOTE 
	# it is crucial to check the source id for the brick pieces since they
	# have atlas coordinates that repeat in the block pieces.
	var C = [
		get_cell_atlas_coords(layer_id, pos) == utils.get_piece_data(global.Pieces.CRYSTAL_BLOCK_ID).atlas,
		get_cell_source_id(layer_id, pos) == 3,
		get_cell_source_id(layer_id, pos) == 2 && utils.get_piece_data(global.Pieces.CRYSTAL_BRICK_ID).atlas.horizontal.has(get_cell_atlas_coords(layer_id, pos)),
		get_cell_source_id(layer_id, pos) == 2 && utils.get_piece_data(global.Pieces.CRYSTAL_BRICK_ID).atlas.vertical.has(get_cell_atlas_coords(layer_id, pos)),
		get_cell_source_id(layer_id, pos) == 4,
	]
	
	if C[0] || C[1] || C[2] || C[3] || C[4]: return true
	else: return false

func get_atlas_to_match(row: int) -> Variant:
	## NOTE
	# - if the tile is empty OR the piece is crystal, continue looking for the color piece on the row.
	# - it is important to check if the tile is empty because it can also return a value for atlas_coords.
	###
	for col in global.board.columns:
		var conditions = [
			is_tile_empty(Vector2i(col, row)),
			has_crystal_block(global.layer.board.id, Vector2i(col,row)),
			get_cell_source_id(global.layer.board.id, Vector2i(col,row)) == 2 
		]
		
		if conditions[0] || conditions[1] || conditions[2]: continue
		else: return get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
			
	return "empty"

func top_element_of_vertical_brick_detected_in_row(row: int) -> bool:
	
	for col in global.board.columns:
		
		# NOTE crystal bricks have source id of 2
		if get_cell_source_id(global.layer.board.id, Vector2i(col,row)) == 2: 
				
			var cell_atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
			var vertical_crystal_brick_top_element_atlas = utils.get_piece_data(global.Pieces.CRYSTAL_BRICK_ID).atlas.vertical[2]
			
			if cell_atlas == vertical_crystal_brick_top_element_atlas:
				return true
	
	# if the loop finishes and no vertical crystal brick 
	# has been found in the row, then return false.	
	return false

func handle_rows_removal() -> void:
	var row = 0
	
	while row < global.board.rows.size():
		if top_element_of_vertical_brick_detected_in_row(row): 
			# NOTE the following method checks current row and two below,
			# that is why we need to skip three rows in this loop.
			handle_row_removal_for_rows_with_vertical_bricks(row)
			row += 3 
		else: 
			handle_row_removal_for_blocks_and_horizontal_bricks(row)
			row += 1	

func handle_row_removal_for_rows_with_vertical_bricks(row: int) -> void:
	
	# loop through the current row and the next two below
	for r in [row, row + 1, row + 2]:
		
		if get_row_match_count(r) == len(global.board.columns):
			if r == row: global.vertical_crystal_matches.top = true
			elif r == row + 1: global.vertical_crystal_matches.middle = true
			elif r == row + 2: global.vertical_crystal_matches.bottom = true
		
		else: 
			if r == row: global.vertical_crystal_matches.top = false
			elif r == row + 1: global.vertical_crystal_matches.middle = false
			elif r == row + 2: global.vertical_crystal_matches.bottom = false
	
	
	if(global.vertical_crystal_matches.top && global.vertical_crystal_matches.middle && global.vertical_crystal_matches.bottom):
		for r in [row, row + 1, row + 2]:
			for col in global.board.columns: 
				erase_cell(global.layer.board.id, Vector2i(col,r))		
		
		global.vertical_crystal_matches.top = false
		global.vertical_crystal_matches.middle = false
		global.vertical_crystal_matches.bottom = false
		global.number_of_vertical_bricks_on_board -= 1
		add_points(150)
		reposition_pieces_if_needed()

func update_board_matrix():
	for row in global.board.rows:
		for col in global.board.columns:
			
			# is it a block ?
			if get_cell_source_id(global.layer.board.id, Vector2i(col,row)) == 1:
				global.board_matrix[row][col] = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
	
			# is it a brick ?
			elif get_cell_source_id(global.layer.board.id, Vector2i(col,row)) == 2:
			
				var cell_atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
				
				# is it in the horizontal orientation ?
				if utils.get_piece_data(global.Pieces.CRYSTAL_BRICK_ID).atlas.horizontal.has(cell_atlas): 
					global.board_matrix[row][col] = "HCBE"
					
				# is it in the vertical orientation ?
				if utils.get_piece_data(global.Pieces.CRYSTAL_BRICK_ID).atlas.vertical.has(cell_atlas): 
					global.board_matrix[row][col] = "VCBE"

func get_row_match_count(row: int) -> int:
	var atlas_to_match = get_atlas_to_match(row)
	update_board_matrix()
	var row_data = global.board_matrix[row]
	
	#NOTE useful for debugging
	#-----
	# utils.print_board_matrix()
	#print("atlas to match: " + str(atlas_to_match))
	#print("crystal blocks: " + str(row_data.count(utils.get_piece_data(global.Pieces.CRYSTAL_BLOCK_ID).atlas)))
	#print("blocks that match: " + str(row_data.count(atlas_to_match)))
	#-----
	
	var crystal_blocks_in_row = row_data.count(utils.get_piece_data(global.Pieces.CRYSTAL_BLOCK_ID).atlas)
	var HCB_elements = row_data.count("HCBE") # HCB stands for horizontal crystal brick
	var VCB_elements = row_data.count("VCBE") # VCB stands for vertical crystal brick
	var matching_color_blocks_in_row = row_data.count(atlas_to_match)
	
	var matches = crystal_blocks_in_row + matching_color_blocks_in_row + HCB_elements + VCB_elements
	
	return matches

func handle_row_removal_for_blocks_and_horizontal_bricks(row: int) -> void:
	if get_row_match_count(row) == len(global.board.columns):
		remove_pieces_in_row(row)
		add_points(50)
		reposition_pieces_if_needed()

func remove_pieces_in_row(row: int) -> void:
	for col in global.board.columns: erase_cell(global.layer.board.id, Vector2i(col,row))


func add_points(points: int) -> void:
	global.score += points
	gui.update_score_label($HUD)

#NOTE
#If there is a reposition of one or more pieces then the the function should be
#called again, until there are no repositions.
#
func reposition_pieces_if_needed() -> void:
	var number_of_repositions = 0
	var row = len(global.board.rows) - 1
	
	#loop from the bottom up
	while row > 0:
		
		var col = 0
		while col < len(global.board.columns):
			
			# is there a piece in this tile ?
			if !is_tile_empty(Vector2i(col, row)):
				
				# is it a horizontal brick ?
				var conditions = [
					get_cell_source_id(global.layer.board.id, Vector2i(col, row)) == 2,
					utils.get_piece_data(global.Pieces.CRYSTAL_BRICK_ID).atlas.horizontal.has(get_cell_atlas_coords(global.layer.board.id, Vector2i(col, row)))
				]
				
				var is_horizontal_brick = conditions[0] && conditions[1]	
				
				if is_horizontal_brick:
					
					# the three tiles below should be empty for it to move
					var arr = []
					for c in [col, col+1, col+2]:
						arr.append(is_tile_empty(Vector2i(c, row + 1)))
					
					if arr.count(true) == 3: 
						var atlas = [
							get_cell_atlas_coords(global.layer.board.id, Vector2i(col, row)),
							get_cell_atlas_coords(global.layer.board.id, Vector2i(col+1, row)),
							get_cell_atlas_coords(global.layer.board.id, Vector2i(col+2, row))
						]

						var source_id = get_cell_source_id(global.layer.board.id, Vector2i(col, row))
						
						erase_cell(global.layer.board.id, Vector2i(col,row))
						erase_cell(global.layer.board.id, Vector2i(col+1,row))
						erase_cell(global.layer.board.id, Vector2i(col+2,row))
						
						set_cell(global.layer.board.id,  Vector2i(col, row+1), source_id, atlas[0])
						set_cell(global.layer.board.id,  Vector2i(col+1, row+1), source_id, atlas[1])
						set_cell(global.layer.board.id,  Vector2i(col+2, row+1), source_id, atlas[2])
					
						# NOTE if an non-active piece has been moved, then this is counted
						# in the variable below, and if that number is bigger than 0 the global variable:
						# global.check_reposition_of_piece will be true, to check the
						# reposition of pieces since the pieces on the board have been re-arranged.
						number_of_repositions += 1
					
					# skip the next two cells to the right.
					col += 2
					
				# NOTE the elif below is important to make sure the horizontal bricks are not treated
				# as blocks or vertical bricks.	
				
				# is the tile beneath empty ?
				elif is_tile_empty(Vector2i(col, row + 1)) :
					# move the piece to the tile beneath
					var atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col, row))
					var source_id = get_cell_source_id(global.layer.board.id, Vector2i(col, row))
					erase_cell(global.layer.board.id, Vector2i(col,row))
					set_cell(global.layer.board.id,  Vector2i(col, row + 1), source_id, atlas)
					
					# NOTE if an non-active piece has been moved, then this is counted
					# in the variable below, and if that number is bigger than 0 the global variable:
					# global.check_reposition_of_piece will be true, to check the
					# reposition of pieces since the pieces on the board have been re-arranged.
					number_of_repositions += 1
		
			col += 1
		row -= 1
				
	# TODO once the inactive pieces have landed on the board, handle_row_removal()
	# has to be called inmidiately. 			
					
	if number_of_repositions > 0: 
		global.check_reposition_of_pieces = true
		
	else: 
		global.check_reposition_of_pieces = false				
		handle_rows_removal()
					
					
					
	
