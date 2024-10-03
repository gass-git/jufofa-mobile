class_name Brick extends Piece

# "vertical" or "horizontal"
var orientation: String
var source_id: int = 2
var vertical_atlas: Array[Vector2i] = [Vector2i(2,0), Vector2i(1,0), Vector2i(0,0)]
var horizontal_atlas: Array[Vector2i] = [Vector2i(3,0), Vector2i(4,0), Vector2i(5,0)]
var shattered: bool = false

func _init(initial_orientation):
	orientation = initial_orientation

func shatter(): shattered = true
