extends RigidBody2D

var fall_speed = 200
var horizontal_speed = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += fall_speed * delta

	if Input.is_action_pressed("move_right"):
		position.x += horizontal_speed
	if Input.is_action_pressed("move_left"):
		position.x -= horizontal_speed



