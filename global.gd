extends Node

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
