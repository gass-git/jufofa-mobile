extends Node

signal check_reposition()

func get_piece_data(piece_id: global.Pieces) -> Dictionary:
	for piece in global.pieces:
		if piece.id == piece_id: return piece

	return {}

func build_board_matrix():
	for row in global.board.rows:
		global.board_matrix.append([])
		for col in global.board.columns:
			global.board_matrix[row].append(0)
			
func print_board_matrix():
	for row in global.board.rows:
		print(global.board_matrix[row])

func handle_frame_count() -> void:
	for f in [global.frames.down, global.frames.right, global.frames.left, global.frames.rotate]:
		if f.count < f.required_for_move: f.count += 1
		elif !f.isMovable: f.isMovable = true 

func is_on_board(pos: Vector2i) -> bool:
	var col = pos.x
	var row = pos.y
	
	if col in global.board.columns && row in global.board.rows:return true
	else: return false
	
# NOTE it returns the pixels of the center of the cell
func to_pixels(axis_coord: int):
	return axis_coord * global.pixels_per_cell + global.pixels_per_cell/2
	
func get_piece_index(id: global.Pieces):
	for i in range(global.pieces.size()):
		if global.pieces[i]["id"] == id: return i
		
	return -1
	
func get_bottom_row() -> int:
	return global.board.rows[len(global.board.rows) - 1]

func get_last_col() -> int:
	return global.board.columns[len(global.board.columns) - 1]

func handle_check_reposition_of_pieces() -> void:
	if global.check_reposition_of_pieces: 
		# if it is the first row removed, make the drop movement slower
		# NOTE if a row has not been removed for a while, the frames reposition count will be pretty big
		if global.frames.reposition.count > \
		global.frames.reposition.required * global.reposition_multiplier + 2:
			global.reposition_multiplier = 1.2
			global.frames.reposition.count = 0
			
		if global.frames.reposition.count > \
		global.frames.reposition.required * global.reposition_multiplier:
			global.reposition_multiplier = 1
			check_reposition.emit()
			global.frames.reposition.count = 0
		
	global.frames.reposition.count += 1
