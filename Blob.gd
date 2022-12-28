class_name Blob

extends Sprite

const blob_size = 16

var x_pos: int
var y_pos: int
var type: int

func _init(type: int, x_pos: int, y_pos: int):
	self.type = type
	self.x_pos = x_pos
	self.y_pos = y_pos

	position = Vector2(x_pos, y_pos) * blob_size

	texture = load("res://blob%d.png" % type)
	centered = false

func _process(delta):
	position = position.linear_interpolate(Vector2(x_pos, y_pos) * blob_size, 20.0 * delta)