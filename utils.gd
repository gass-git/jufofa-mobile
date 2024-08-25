extends Node
	
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
