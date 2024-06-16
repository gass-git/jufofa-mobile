extends Node
	
func get_piece_data(piece_id: global.Pieces) -> Dictionary:
	for piece in global.pieces:
		if piece.id == piece_id: return piece

	return {}
