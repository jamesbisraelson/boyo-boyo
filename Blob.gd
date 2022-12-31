class_name Blob

extends Sprite

const blob_size = 8

var x_pos: int
var y_pos: int
var type: int

var should_break: bool
var explosion: Particles2D

var player: AudioStreamPlayer
var sound_explode = preload("res://explosion.wav")

func _init(type: int, x_pos: int, y_pos: int, starting_pos: Vector2):
	explosion = load("res://Explosion.tscn").instance()
	self.type = type
	self.x_pos = x_pos
	self.y_pos = y_pos
	self.should_break = false

	self.position = starting_pos

	texture = load("res://blob%d.png" % type)
	explosion.texture = load("res://blob%d.png" % type)
	centered = false

	player = AudioStreamPlayer.new()
	player.volume_db = -5

	add_child(player)

func _process(delta):
	position = position.linear_interpolate(Vector2(x_pos, y_pos) * blob_size, 20.0 * delta)
	_gravity()
	_break_phase()


func num_connected(x: int, y: int, group_type: int, visited: Array):
	var w = get_parent().area_width
	var h = get_parent().area_height
	var blob_list = get_parent().blob_list

	var down: Blob = null
	var up: Blob = null
	var right: Blob = null
	var left: Blob = null

	if y_pos + 1 <= h - 1:
		down = blob_list[(w * (y_pos + 1)) + x_pos]
	if y_pos - 1 >= 0:
		up = blob_list[(w * (y_pos - 1)) + x_pos]
	if x_pos + 1 <= w - 1:
		right = blob_list[(w * y_pos) + x_pos + 1]
	if x_pos - 1 >= 0:
		left = blob_list[(w * y_pos) + x_pos - 1]

	var total = 0

	if visited[(y * w) + x] == true:
		return 0
	elif group_type != self.type:
		visited[(y * w) + x] = true
		return 0
	else:
		visited[(y * w) + x] = true

		if down != null:
			total += down.num_connected(x_pos, y_pos + 1, group_type, visited)
		if up != null:
			total += up.num_connected(x_pos, y_pos - 1, group_type, visited)
		if right != null:
			total += right.num_connected(x_pos + 1, y_pos, group_type, visited)
		if left != null:
			total += left.num_connected(x_pos - 1, y_pos, group_type, visited)
		return total + 1


func _break_phase():
	var visited = []
	visited.resize(get_parent().area_width * get_parent().area_height)
	visited.fill(false)

	if num_connected(x_pos, y_pos, self.type, visited) >= 4:
		should_break = true


func break_blob():
	get_node("/root/GameScene/ExplosionPlayer").play()
	get_parent().add_child(explosion)
	explosion.global_position = self.global_position
	explosion.emitting = true

	var w = get_parent().area_width
	var blob_list = get_parent().blob_list

	blob_list[(w * y_pos) + x_pos] = null
	queue_free()


func _gravity():
	var blob_list = get_parent().blob_list
	var w = get_parent().area_width
	var h = get_parent().area_height
	var below = (w * (y_pos + 1)) + x_pos

	if y_pos + 1 <= h - 1 and blob_list[below] == null:
		blob_list[below] = self
		blob_list[(w * y_pos) + x_pos] = null
		y_pos += 1