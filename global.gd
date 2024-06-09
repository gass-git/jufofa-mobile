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
		"name": "pink_block", 
		"is_crystal": false,
		"atlas": Vector2i(2,0),
		"source_id": 1
	},
	{
		"name": "red_block", 
		"is_crystal": false,
		"atlas": Vector2i(3,0),
		"source_id": 1
	},
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
		"atlas": {
			"vertical": [Vector2i(2,0), Vector2i(1,0), Vector2i(0,0)],
			"horizontal": [Vector2i(3,0), Vector2i(4,0), Vector2i(5,0)],
		},
		"source_id": 2
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

var score = 0
var progress_bar_value = 0
var bombs_in_storage = 0
var check_reposition_of_pieces = false
var bomb_in_next_turn = false
var number_of_vertical_bricks_on_board = 0
var max_number_of_vertical_bricks_on_board = 1

# TODO improve this hardcoded value
var bomb_index = 6
