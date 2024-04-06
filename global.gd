extends Node

const board = {
	"rows": [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
	"columns": [0,1,2,3,4,5,6,7,8]
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
		"name": "blue_block", 
		"is_crystal": false,
		"atlas": Vector2i(5,0),
		"source_id": 1
	},
	{
		"name": "green_block", 
		"is_crystal": false,
		"atlas": Vector2i(4,0),
		"source_id": 1
	},
	{
		"name": "crystal_block", 
		"is_crystal": true,
		"atlas": Vector2i(6,0),
		"source_id": 1
	},
	{
		"name": "crystal_brick",
		"is_crystal": true,
		"atlas": Vector2i(6,0),
		"source_id": 1
	},
	{
		"name": "bomb", 
		"is_crystal": false,
		"atlas": Vector2i(7,0),
		"source_id": 1
	}
]

var active_piece = {
	"initial_pos": Vector2i(4, 0),
	"index": null,
	"type": null,
	"pos": null,
	"rotated": false,
	"source_id": null,
	"atlas": null,
	"name": null
}

var score = 0
var progress_bar_value = 0
var bombs_in_storage = 0
var check_reposition_of_pieces = false
var bomb_in_next_turn = false

# TODO improve this
var bomb_index = 4
