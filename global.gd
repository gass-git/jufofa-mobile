extends Node

var board_matrix: Array 
var score: int = 0
var progress_bar_value: int = 0
var bombs_in_storage: int = 0
var check_reposition_of_pieces: bool = false
var bomb_in_next_turn: bool = false
var number_of_vertical_bricks_on_board: int = 0
var max_number_of_vertical_bricks_on_board: int = 1
var reposition_multiplier: float = 1	
var pixels_per_cell: int = 80

# NOTE 
# Speed of the active piece when the user presses the down key.
var boost_speed = {
	"frames": 10,
	"progress_bar_increment": 3
}

var probability = {
	"crystal_block_shatter": 1,
	"crystal_brick_shatter": 1
}

const board = {
	"rows": [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
	"columns": [0,1,2,3,4,5,6,7,8]
}

var layer = {
	"board": {"id": 0},
	"active": {"id": 1},
	"foreground": {"id": 2}
}

var frames = {
	"down": {"count":0, "required_for_move": 50, "isMovable": false},
	"right": {"count": 0, "required_for_move": 15, "isMovable": false},
	"left": {"count": 0, "required_for_move": 15, "isMovable": false},
	"rotate": {"count": 0, "required_for_move": 30, "isMovable": false},
	"reposition": {"count": 0, "required": 30},
}

enum Pieces {
	YELLOW_BLOCK_ID = 101,
	PINK_BLOCK_ID = 102,
	BLUE_BLOCK_ID = 103,
	GREEN_BLOCK_ID = 104,
	CRYSTAL_BLOCK_ID = 105,
	CRYSTAL_BRICK_ID = 106,
	BOMB_ID = 107,
	SHATTERED_CRYSTAL_BLOCK_ID = 108,
}

# NOTE
# Since enums in GDscript don't support strings, the integer "id" 
# will be used so that an enum with integer identifiers can be used to facilitate
# the developer experience and reduce possible bugs.
var pieces = [
	{
		"id": 101,
		"name": "yellow_block", 
		"is_crystal": false,
		"atlas": Vector2i(1,0),
		"source_id": 1
	},
	{
		"id": 102,
		"name": "pink_block", 
		"is_crystal": false,
		"atlas": Vector2i(2,0),
		"source_id": 1
	},
	{
		"id": 103,
		"name": "blue_block", 
		"is_crystal": false,
		"atlas": Vector2i(4,0),
		"source_id": 1
	},
	{
		"id": 104,
		"name": "green_block", 
		"is_crystal": false,
		"atlas": Vector2i(3,0),
		"source_id": 1
	},
	{
		"id": 105,
		"name": "crystal_block", 
		"is_crystal": true,
		"atlas": Vector2i(5,0),
		"source_id": 1
	},
	{
		"id": 106,
		"name": "crystal_brick",
		"is_crystal": true,
		"atlas": {
			"vertical": [Vector2i(2,0), Vector2i(1,0), Vector2i(0,0)],
			"horizontal": [Vector2i(3,0), Vector2i(4,0), Vector2i(5,0)],
		},
		"source_id": 2
	},
	{
		"id": 107,
		"name": "bomb", 
		"is_crystal": false,
		"atlas": Vector2i(6,0),
		"source_id": 1
	},
	{
		"id": 108,
		"name": "shattered_crystal_block",
		"is_crytsal": true,
		"atlas": Vector2i(0,0),
		"source_id": 3
	}
]

var active_piece = {
	"initial_pos": Vector2i(4, 0),
	"index": null,
	"type": null,
	"pos": null,
	"horizontal": false,
	"source_id": null,
	"atlas": null,
	"name": null
}

# NOTE this is an object used to remove a vertical crystal piece when colors match
var vertical_crystal_matches = {
	"top": false,
	"middle": false,
	"bottom": false
}

func create_first_piece(HUD) -> void:
	active_piece.pos = active_piece.initial_pos
	set_next_piece(HUD)

func set_next_piece(HUD) -> void:
	var index
	
	if bomb_in_next_turn: 
		index = utils.get_piece_index(Pieces.BOMB_ID)
		bombs_in_storage -= 1
		gui.update_bombs_label(HUD)
		bomb_in_next_turn = false
	
	elif number_of_vertical_bricks_on_board < max_number_of_vertical_bricks_on_board: 
		index = randi() % utils.get_piece_index(Pieces.CRYSTAL_BRICK_ID) + 1
	
	else: index = randi() % utils.get_piece_index(Pieces.CRYSTAL_BLOCK_ID) + 1
	
	active_piece.index = index
	active_piece.name = pieces[index].name
	active_piece.source_id = pieces[index].source_id
	active_piece.atlas = pieces[index].atlas
	active_piece.horizontal = false
