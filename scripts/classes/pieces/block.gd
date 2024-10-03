class_name Block extends Piece

var color: String
var atlas: Vector2i
var source_id: int = 1
var material: String # "solid" or "crystal" 

var frames: Dictionary = {
	"down": {"count":0, "required_for_move": 50},
	"right": {"count": 0, "required_for_move": 15},
	"left": {"count": 0, "required_for_move": 15},
	"rotate": {"count": 0, "required_for_move": 30},
}

func _init(new_color, new_material = "solid"):
	color = new_color
	material = new_material
	
	if new_color == "yellow": 
		atlas = Vector2i(1,0)

func handle_movement():
	frames.down.count += 1
	
	if frames.down.count == frames.down.required_for_move:
		pos.y += 1
		frames.down.count = 0

# TODO the atlas and source_id is set automatically 
# within the constructor.
