extends TileMap

var number_of_vertical_bricks_on_board = 0

var max_number_of_vertical_bricks_on_board = 1

# this is an object used to remove a vertical crystal piece when colors match
var vertical_crystal_matches = {
	"top": false,
	"middle": false,
	"bottom": false
}

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
	set_next_piece()
	
# TODO improve this	
# with source id this might not be necessary
func get_piece_data():
	return {
		"crystal": global.pieces[2],
		"crystal_brick": global.pieces[3],
		"bomb": global.pieces[4]
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
	handle_cell_setters(global.layer.active.id)
	
func handle_user_input():
	
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
			global.progress_bar_value += 1
			update_progress_bar()
		
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
			global.progress_bar_value += 1
			update_progress_bar()
	
	if Input.is_action_pressed("space") && global.bombs_in_storage > 0:
		global.bomb_in_next_turn = true
	
func brick_can_rotate(pos: Vector2i):
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
	
func handle_active_piece_falling_movement():
	
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

func handle_cell_setters(layer_id):	
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
	
	
func handle_frame_count():
	for f in [global.frames.down, global.frames.right, global.frames.left, global.frames.rotate]:
		if f.count < f.required_for_move: f.count += 1
		elif !f.isMovable: f.isMovable = true 

enum Dir {
	RIGHT,
	LEFT,
	BELOW
}

func can_move(pos: Vector2i, direction: Dir):
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
		
func is_tile_empty(pos: Vector2i):
	return (get_cell_source_id(global.layer.board.id, pos) == -1 && is_on_board(pos))

func is_on_board(pos: Vector2i):
	var col = pos.x
	var row = pos.y
	
	if col in global.board.columns && row in global.board.rows:return true
	else: return false
	
func set_next_piece():
	var index
	
	if global.bomb_in_next_turn: 
		index = global.bomb_index
		global.bombs_in_storage -= 1
		update_bombs_label()
		global.bomb_in_next_turn = false
		
	# TODO improve this - hard coded for now
	# the crystal_brick index is 3
	
	# NOTE don't create crystal_brick pieces if the number of vertical bricks on board
	# is not the max allowed.
	elif number_of_vertical_bricks_on_board < max_number_of_vertical_bricks_on_board: 
		index = randi() % 4	
	
	else: index = randi() % 3
	
	global.active_piece.index = index
	global.active_piece.name = global.pieces[index].name
	global.active_piece.source_id = global.pieces[index].source_id
	global.active_piece.atlas = global.pieces[index].atlas
	global.active_piece.horizontal = false
	
func get_board_piece_name(pos: Vector2i):
	var atlas = get_cell_atlas_coords(global.layer.board.id, pos)
	var name 
	
	for piece in global.pieces:
		if atlas != piece.atlas:
			continue
		else: 
			name = piece.name
			break
	
	return name
	
func handle_land():
	# TODO 
	# - the crystals shouldn't get destroyed by the bomb
	# - the pieces should re-arrange once the bomb explodes (pieces on top should fall if there are spaces below)
	#
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
					if !has_crystal(global.layer.board.id, Vector2i(col, row)):
						erase_cell(global.layer.board.id, Vector2i(col, row))
	
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
				
				number_of_vertical_bricks_on_board += 1
		
		else:	
			erase_cell(global.layer.active.id, global.active_piece.pos)
		
		handle_cell_setters(global.layer.board.id)
	
	global.active_piece.pos = global.active_piece.initial_pos
	
	set_next_piece()

func has_crystal_block(layer_id, pos: Vector2i):
	if get_cell_atlas_coords(layer_id, pos) == get_piece_data().crystal.atlas: return true
	else: return false

func has_crystal(layer_id, pos: Vector2i):
	if get_cell_atlas_coords(layer_id, pos) == get_piece_data().crystal.atlas:
		return true
	
	for atlas_1 in get_piece_data().crystal_brick.atlas.horizontal:
		if get_cell_atlas_coords(layer_id, pos) == atlas_1:
			return true
	
	for atlas_2 in get_piece_data().crystal_brick.atlas.vertical:
		if get_cell_atlas_coords(layer_id, pos) == atlas_2:
			return true
	
	return false

func get_atlas_to_match(row: int):
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
	

"""
TODO
** separate concerns (simple chunks)

build handlers:
	- one for checking rows that contain only blocks
	- one for checking rows that contain horizontal bricks
	- one for checking rows that contain vertical bricks

there should also be a f() that handles which handler to use

"""

func top_element_of_vertical_brick_detected_in_row(row):
	
	for col in global.board.columns:
		
		# NOTE crystal bricks have source id of 2
		if get_cell_source_id(global.layer.board.id, Vector2i(col,row)) == 2: 
				
			var cell_atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
			var vertical_crystal_brick_top_element_atlas = get_piece_data().crystal_brick.atlas.vertical[2]
			
			if cell_atlas == vertical_crystal_brick_top_element_atlas:
				return true
	
	# if the loop finishes and no vertical crystal brick 
	# has been found in the row, then return false.	
	return false

func handle_rows_removal():
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

# WORK IN PROGRESS
func handle_row_removal_for_rows_with_vertical_bricks(row):
	
	# loop through the current row and the next two below
	for r in [row, row + 1, row + 2]:
		
		if get_row_match_count(r) == len(global.board.columns):
			if r == row: vertical_crystal_matches.top = true
			elif r == row + 1: vertical_crystal_matches.middle = true
			elif r == row + 2: vertical_crystal_matches.bottom = true
		
		else: 
			if r == row: vertical_crystal_matches.top = false
			elif r == row + 1: vertical_crystal_matches.middle = false
			elif r == row + 2: vertical_crystal_matches.bottom = false
	
	
	if(vertical_crystal_matches.top && vertical_crystal_matches.middle && vertical_crystal_matches.bottom):
		for r in [row, row + 1, row + 2]:
			for col in global.board.columns: 
				erase_cell(global.layer.board.id, Vector2i(col,r))		
		
		vertical_crystal_matches.top = false
		vertical_crystal_matches.middle = false
		vertical_crystal_matches.bottom = false
		number_of_vertical_bricks_on_board -= 1
		global.check_reposition_of_pieces = true

func get_row_match_count(row: int) -> int:
	var row_data = []
	row_data.resize(len(global.board.columns))
	
	var atlas_to_match = get_atlas_to_match(row)
	
	# NOTE loop through all the cells in this row
	for col in global.board.columns:
		
		# is it a block ?
		if get_cell_source_id(global.layer.board.id, Vector2i(col,row)) == 1:
			row_data[col] = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
	
		# is it a brick ?
		elif get_cell_source_id(global.layer.board.id, Vector2i(col,row)) == 2:
			# print("---- yes, it is a brick")
			
			var cell_atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
			
			# is it in the horizontal orientation ?
			if get_piece_data().crystal_brick.atlas.horizontal.has(cell_atlas): 
				row_data[col] = "HCBE"
				
			# is it in the vertical orientation ?
			if get_piece_data().crystal_brick.atlas.vertical.has(cell_atlas): 
				row_data[col] = "VCBE"
		
	print(row_data)
	print("atlas to match: " + str(atlas_to_match))
	#print("crystals: " + str(row_data.count(get_piece_data().crystal.atlas)))
	#print("blocks that match: " + str(row_data.count(atlas_to_match)))
	
	
	var crystal_blocks_in_row = row_data.count(get_piece_data().crystal.atlas)
	var HCB_elements = row_data.count("HCBE") # HCB stands for horizontal crystal brick
	var VCB_elements = row_data.count("VCBE") # VCB stands for vertical crystal brick
	var matching_color_blocks_in_row = row_data.count(atlas_to_match)
	
	print(HCB_elements)
	
	var matches = crystal_blocks_in_row + matching_color_blocks_in_row + HCB_elements + VCB_elements
	
	return matches

func handle_row_removal_for_blocks_and_horizontal_bricks(row):
	if get_row_match_count(row) == len(global.board.columns):
		remove_pieces_in_row(row)
		reposition_pieces_if_needed()
		add_points(50)

func remove_pieces_in_row(row):
	for col in global.board.columns: erase_cell(global.layer.board.id, Vector2i(col,row))


func add_points(points: int):
	global.score += points
	update_score_label()
	
		#print("atlas to match: " + str(atlas_to_match))
##
# NOTE 
# the following f() loops through all the cells of the grid,
# and checks wether some rows need to be removed. If so,
# the score should be updated accordingly.
#
# BUG when there is a vertical brick in play the matching colors mechanism
# for removing the rows is not working properly. The rows  get removed without
# matching the colors.
#
##
"""
func old_check_all_rows():
	# NOTE
	# loop through all rows
	#
	for row in global.board.rows:
		handle_row_removal(row)
		
		var row_matches = 0
		var atlas_to_match_in_row
		var vertical_brick_atlas_found_in_row = false
		var cell_atlas: Vector2i
		
		# NOTE 
		# loop through all cells of the row
		#
		for col in global.board.columns: 
			
			# NOTE 
			# crystal bricks have source id of 2
			#
			if get_cell_source_id(global.layer.board.id, Vector2i(col,row)) == 2:
				cell_atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
		
		# NOTE 
		# if the cell been inspected is part of a vertical crystal brick
		# then access the special treatment.
		#
		if cell_atlas in get_piece_data().crystal_brick.atlas.vertical:
			var pos
			
			# NOTE 
			# discover if its the TOP, MIDDLE or BOTTOM atlas of the vertical crystal brick.
			#
			if cell_atlas == get_piece_data().crystal_brick.atlas.vertical[2]: pos = "TOP"
			elif cell_atlas == get_piece_data().crystal_brick.atlas.vertical[1]: pos = "MIDDLE"
			elif cell_atlas == get_piece_data().crystal_brick.atlas.vertical[0]: pos = "BOTTOM"
			
			match pos:
				"TOP": 					
					# NOTE
					# loop through all cells within this row.
					#
					for col in global.board.columns: 
						# NOTE 
						# this_atlas is the atlas coordinates of this cell.
						#
						var this_atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
						
						# NOTE
						# add matches: they can be crystals or matching colors.
						#
						if has_crystal(global.layer.board.id, Vector2i(col,row)) || this_atlas == find_atlas_to_match(row):
							row_matches += 1	
								
					# NOTE
					# if the matches count equal the required (number of columns)
					# proceed.
					#		
					if row_matches == len(global.board.columns):
						vertical_crystal_matches.top = true
						#for col in global.board.columns: erase_cell(global.layer.board.id, Vector2i(col,row))		
				"MIDDLE":
					for col in global.board.columns: 
						var this_atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
						
						if has_crystal(global.layer.board.id, Vector2i(col,row)) || this_atlas == find_atlas_to_match(row):
							row_matches += 1	
								
					if row_matches == len(global.board.columns):
						vertical_crystal_matches.middle = true
						#for col in global.board.columns: erase_cell(global.layer.board.id, Vector2i(col,row))			
				"BOTTOM":		
					for col in global.board.columns: 
						var this_atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
						
						if has_crystal(global.layer.board.id, Vector2i(col,row)) || this_atlas == find_atlas_to_match(row):
							row_matches += 1	
								
					if row_matches == len(global.board.columns):
						vertical_crystal_matches.bottom = true
						#for col in global.board.columns: erase_cell(global.layer.board.id, Vector2i(col,row))
		
			if(vertical_crystal_matches.top && vertical_crystal_matches.middle && vertical_crystal_matches.bottom):
				
				match pos:
					"TOP": 
						for r in [row, row + 1, row + 2]:
							for col in global.board.columns: 
								erase_cell(global.layer.board.id, Vector2i(col,r))		
					"MIDDLE":
						for r in [row, row + 1, row - 1]:	
							for col in global.board.columns: 
								erase_cell(global.layer.board.id, Vector2i(col,r))			
					"BOTTOM":		
						for r in [row, row - 1, row - 2]:
							for col in global.board.columns: 
								erase_cell(global.layer.board.id, Vector2i(col,r))
		
				vertical_crystal_matches.top = false
				vertical_crystal_matches.middle = false
				vertical_crystal_matches.bottom = false
				number_of_vertical_bricks_on_board -= 1
				global.check_reposition_of_pieces = true
		
		else:
			atlas_to_match_in_row = find_atlas_to_match(row)
			
			for col in global.board.columns: 
				var this_atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col,row))
				
				if has_crystal(global.layer.board.id, Vector2i(col,row)) || this_atlas == atlas_to_match_in_row:
					row_matches += 1	
					
			if row_matches == len(global.board.columns):
				for col in global.board.columns: erase_cell(global.layer.board.id, Vector2i(col,row))
		
				global.score += 50
				global.check_reposition_of_pieces = true
				update_score_label()
""" 


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
			if !is_tile_empty(Vector2i(col, row)):
				# is the tile beneath empty ?
				if can_move(Vector2i(col, row), Dir.BELOW):
					# move the piece to the tile beneath
					var atlas = get_cell_atlas_coords(global.layer.board.id, Vector2i(col, row))
					var source_id = get_cell_source_id(global.layer.board.id, Vector2i(col, row))
					erase_cell(global.layer.board.id, Vector2i(col, row))
					set_cell(global.layer.board.id,  Vector2i(col, row + 1), source_id, atlas)
					
					number_of_repositions += 1
								
	if number_of_repositions > 0: global.check_reposition_of_pieces = true
	else: global.check_reposition_of_pieces = false				
					
					
					
					
	
