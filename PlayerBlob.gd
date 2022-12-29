class_name PlayerBlob

extends Node2D

const area_width: int = 6
const area_height: int = 15
const blob_size = 16

var head: Sprite
var head_type: int

var tail: Sprite
var tail_type: int
var tail_pos: Vector2

var x_pos: int
var y_pos: int

var ground_time: float
var hit_bottom: float
var rotations_on_ground: int

func _init(head_type: int, tail_type: int, x_pos: int, y_pos: int):
	self.head_type = head_type
	self.tail_type = tail_type
	self.x_pos = x_pos
	self.y_pos = y_pos
	self.hit_bottom = false
	self.rotations_on_ground = 0

	position = Vector2(x_pos, y_pos) * blob_size
	tail_pos = Vector2.DOWN

	ground_time = 0.25

	head = Sprite.new()
	tail = Sprite.new()

	head.position = Vector2()
	tail.position = tail_pos * blob_size

	head.texture = load("res://blob%d.png" % head_type)
	tail.texture = load("res://blob%d.png" % tail_type)

	head.centered = false
	tail.centered = false

	add_child(head)
	add_child(tail)


func _input(event):
	if event.is_action_pressed("ui_left"):
		move_left()
	if event.is_action_pressed("ui_right"):
		move_right()
	if event.is_action_pressed("ui_up"):
		_rotate_clockwise()


func _process(delta):
	position = position.linear_interpolate(Vector2(x_pos, y_pos) * blob_size, 20.0 * delta)
	tail.position = tail.position.linear_interpolate(tail_pos * blob_size, 20.0 * delta)

	if not can_move(Vector2.DOWN):
		ground_time -= delta
	else:
		ground_time = 0.25

	if ground_time <= 0 and tail.position.is_equal_approx(tail_pos * blob_size):
		hit_bottom = true

func player_to_blob():
	var blob1 = Blob.new(head_type, x_pos, y_pos)
	var blob2 = Blob.new(tail_type, x_pos + tail_pos.x, y_pos + tail_pos.y)

	get_parent().add_child(blob1)
	get_parent().add_child(blob2)
	get_parent().blob_list[(area_width * blob1.y_pos) + blob1.x_pos] = blob1
	get_parent().blob_list[(area_width * blob2.y_pos) + blob2.x_pos] = blob2


func move_left():
	if can_move(Vector2.LEFT):
		x_pos -= 1

func move_right():
	if can_move(Vector2.RIGHT):
		x_pos += 1

func move_down():
	if can_move(Vector2.DOWN):
		y_pos += 1

func move_up():
	if can_move(Vector2.UP):
		y_pos -= 1


func add_ground_time():
	if ground_time < 0.25 and rotations_on_ground < 3:
		ground_time = 0.25
		rotations_on_ground += 1


func _rotate_clockwise():
	add_ground_time()

	if tail_pos.is_equal_approx(Vector2.UP) or tail_pos.is_equal_approx(Vector2.DOWN):
		if not can_move(Vector2.LEFT) and not can_move(Vector2.RIGHT):
			return
	if tail_pos.is_equal_approx(Vector2.LEFT) or tail_pos.is_equal_approx(Vector2.RIGHT):
		if not can_move(Vector2.UP) and not can_move(Vector2.DOWN):
			return

	tail_pos = tail_pos.rotated(PI / 2).round()
	
	if tail_pos.is_equal_approx(Vector2.UP) and not can_move(Vector2.UP):
		move_down()
	if tail_pos.is_equal_approx(Vector2.DOWN) and not can_move(Vector2.DOWN):
		move_up()
	if tail_pos.is_equal_approx(Vector2.LEFT) and not can_move(Vector2.LEFT):
		move_right()
	if tail_pos.is_equal_approx(Vector2.RIGHT) and not can_move(Vector2.RIGHT):
		move_left()


func can_move(direction: Vector2):
	var left: int = min(x_pos, x_pos + tail_pos.x)
	var right: int = max(x_pos, x_pos + tail_pos.x)
	var up: int = min(y_pos, y_pos + + tail_pos.y)
	var down: int = max(y_pos, y_pos + + tail_pos.y)

	if left + direction.x < 0 or right + direction.x > area_width - 1:
		return false
	if up + direction.y < 0 or down + direction.y > area_height - 1:
		return false
	if _collide_at(left + direction.x, down + direction.y) or _collide_at(right + direction.x, down + direction.y):
		return false
	if _collide_at(left + direction.x, up + direction.y) or _collide_at(right + direction.x, up + direction.y):
		return false
	return true


func _collide_at(x: int, y: int):
	if get_parent().blob_list[(area_width * y) + x]:
		return true
	return false