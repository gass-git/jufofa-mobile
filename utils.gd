extends Node
	
func get_piece_data(piece_id: global.Pieces) -> Dictionary:
	for piece in global.pieces:
		if piece.id == piece_id: return piece

	return {}

func build_board_matrix():
	for row in global.board.rows:
		global.board_matrix.append([])
		
	for row in global.board.rows:
		for col in global.board.columns:
			global.board_matrix[row].append({})
