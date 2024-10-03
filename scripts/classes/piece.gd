extends Node

var pos: Vector2i

func process_gravity():
	global.frames.gravity.count += 1
	
	if global.frames.gravity.count ==  global.frames.gravity.required_for_move:
		pos.y += 1
		global.frames.gravity.count = 0
