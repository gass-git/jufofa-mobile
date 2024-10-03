class_name Block extends Node

var color: String
var atlas: Vector2i
var source_id: int
var material: String # "solid" or "crystal" 

func _init(new_color, new_material = "solid"):
	color = new_color
	material = new_material

# TODO the atlas and source_id is set automatically 
# within the constructor.
