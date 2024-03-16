extends TileMap

# NOTE
# there are two layers for the tile map:
# ACTIVE and BOARD
# 
# TODO write a concise explanation for both


const starting_position = Vector2i(10, 1)

var tile_set_id = 1
var tile_id = 1
var board_layer_id = 0
var active_layer_id = 1
var piece_atlas: Vector2
var pos = starting_position
var frames_per_down_move = 50
var frames_per_side_move = 15

# TODO transform these variables into an object
var frames_counted_for_downward_movement = 0
var frames_counted_for_right_movement = 0
var frames_counted_for_left_movement = 0

var count_frames_for_right_movement = false
var count_frames_for_left_movement = false

var speed = 1

# called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_movement()
		
	# TODO what is the second argument for ? 
	draw_piece(pos, Vector2i(2,0))

func handle_movement():
	if Input.is_action_pressed("move_down"):
		frames_counted_for_downward_movement += 10
	
	if Input.is_action_pressed("move_right") && !count_frames_for_right_movement:
		erase_cell(active_layer_id, pos)
		pos.x += 1
		count_frames_for_right_movement = true
	
	elif Input.is_action_pressed("move_right") && frames_counted_for_right_movement >= frames_per_side_move:
		erase_cell(active_layer_id, pos)
		pos.x += 1
		frames_counted_for_right_movement = 0
		
	if Input.is_action_pressed("move_left") && !count_frames_for_left_movement:
		erase_cell(active_layer_id, pos)
		pos.x -= 1
		count_frames_for_left_movement = true
	
	elif Input.is_action_pressed("move_left") && frames_counted_for_left_movement >= frames_per_side_move:
		erase_cell(active_layer_id, pos)
		pos.x -= 1
		frames_counted_for_left_movement = 0
	
	if count_frames_for_right_movement:
		frames_counted_for_right_movement += 1
	
	if count_frames_for_left_movement:
		frames_counted_for_left_movement += 1
	
	if frames_counted_for_downward_movement >= frames_per_down_move:
		erase_cell(active_layer_id, pos)
		
		#if Input.is_action_pressed("move_right"):
		#	pos.x += 1
		
		#if Input.is_action_pressed("move_left"):
		#	pos.x -= 1
		
		if no_obstacle():
			pos.y += speed
		else:	
			handle_land()
			create_piece()
			
		# reset frames counted for downward movement
		frames_counted_for_downward_movement = 0
		
	else:
		frames_counted_for_downward_movement += 1


func no_obstacle():
	# write a note of how the following works.
	return get_cell_source_id(board_layer_id, pos + Vector2i(0,1)) == -1

func draw_piece(pos, atlas_coordinate):
	# NOTE updates the ACTIVE tile map.
	# what is the atlas coordinate ?
	set_cell(active_layer_id, pos, tile_set_id, atlas_coordinate)

# create a piece ? ... this is just assigning the starting position to 
# the pos variable. Not instantiating.
func create_piece():
	pos = starting_position

func handle_key_inputs():
	pass

func handle_land():
	# NOTE erases the piece from the ACTIVE layer
	erase_cell(active_layer_id, pos)
	
	# NOTE sets the piece to the board layer
	set_cell(board_layer_id, pos, tile_set_id, Vector2i(2,0))
