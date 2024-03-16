extends TileMap

# NOTE
# there are two layers for the tile map:
# ACTIVE and BOARD
# 
# TODO write a concise explanation for both

var speed = 1
var tile_set_id = 1
var tile_id = 1
var board_layer_id = 0
var active_layer_id = 1
var piece_atlas: Vector2

var pos = {
	"init": Vector2i(10, 1),
	"current": null
}

var frames = {
	"down": {"count":0, "required_for_move": 40, "isMovable": false},
	"right": {"count": 0, "required_for_move": 10, "isMovable": false},
	"left": {"count": 0, "required_for_move": 10, "isMovable": false}
}

# called when the node enters the scene tree for the first time.
func _ready():
	pos.current = pos.init


# NOTE
# -> called every frame.
# -> delta is the elapsed time since the previous frame.
func _process(delta):
	handle_movement()


func handle_movement():
	if Input.is_action_pressed("move_right") && frames.right.isMovable:
		erase_cell(active_layer_id, pos.current)
		pos.current.x += 1
		frames.right.count = 0
		frames.right.isMovable = false
	
	if Input.is_action_pressed("move_left") && frames.left.isMovable:
		erase_cell(active_layer_id, pos.current)
		pos.current.x -= 1
		frames.left.count = 0
		frames.left.isMovable = false
	
	if Input.is_action_pressed("move_down"):
		frames.down.count += 10
	
	if frames.down.isMovable:
		erase_cell(active_layer_id, pos.current)	
		
		if no_obstacle(): pos.current.y += speed
		else: handle_land()
			
		frames.down.count = 0
		frames.down.isMovable = false
	
	set_cell(active_layer_id, pos.current, tile_set_id, Vector2i(2,0))
	handle_frame_count()	
	
func handle_frame_count():
	for f in [frames.down, frames.right, frames.left]:
		if f.count < f.required_for_move: f.count += 1
		elif !f.isMovable: f.isMovable = true 


func no_obstacle():
	return get_cell_source_id(board_layer_id, pos.current + Vector2i(0,1)) == -1	

func handle_land():
	erase_cell(active_layer_id, pos.current)
	set_cell(board_layer_id, pos.current, tile_set_id, Vector2i(2,0))
	
	# NOTE updates the current position to the initial position.
	pos.current = pos.init
