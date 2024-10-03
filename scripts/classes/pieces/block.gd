class_name Block extends Piece

var color: String
var atlas: Vector2i
var source_id: int = 1
var material: String # "solid" or "crystal" 

func _init(new_color, new_material = "solid", init_pos = Vector2i(4,0)):
	pos = init_pos
	color = new_color
	material = new_material
	
	if new_color == "yellow": 
		atlas = Vector2i(1,0)

func move(direction: String):
	match direction:
		"left": 
			if global.frames.left.count == global.frames.left.required_for_move:
				pos.x -= 1
				global.frames.left.count = 0
			else: 
				global.frames.left.count += 1
		"right":
			if global.frames.right.count == global.frames.right.required_for_move:
				pos.x += 1
				global.frames.right.count = 0
			else: 
				global.frames.right.count += 1

func down_boost():
	if global.frames.down_boost.count == global.frames.down_boost.required_for_move:
		pos.y += 1
		global.frames.down_boost.count = 0
	else: 
		global.frames.down_boost.count += 1
