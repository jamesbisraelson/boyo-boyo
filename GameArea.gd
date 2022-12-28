extends Node2D

var blobs: Array = []
const blobs_width: int = 6
const blobs_height: int = 12
const blob_size = 16

signal all_blobs_hit_bottom

func _ready():
	$Timer.connect("timeout", self, "_gravity")
	self.connect("all_blobs_hit_bottom", self, "_spawn_blob")
	_spawn_blob()

func _spawn_blob():
	var blob = Blob.new()
	add_child(blob)
	blobs.append(blob)
	
	blob.x_pos = 2
	blob.y_pos = -1
	blob.position = Vector2(blob.x_pos*blob_size, blob.y_pos*blob_size)


func _gravity():
	var any_moved = false
	for i in blobs.size():
		for j in blobs.size():
			if blobs[i].x_pos == blobs[j].x_pos:
				if blobs[i].y_pos == blobs[j].y_pos - 1:
					blobs[i].move_blob = false
		
		if blobs[i].y_pos >= blobs_height - 1:
			blobs[i].move_blob = false
		
		if blobs[i].move_blob:
			blobs[i].y_pos += 1
			any_moved = true
	
	if !any_moved:
		emit_signal("all_blobs_hit_bottom")

class Blob extends Sprite:
	var x_pos: int
	var y_pos: int
	var move_blob: bool
	
	func _init():
		centered = false
		texture = load('res://blob.png')
		move_blob = true

	func _process(delta):
		_update_position(delta)
	
	func _input(event):
		if(move_blob):
			if event.is_action_pressed("ui_left"):
				x_pos = max(0, x_pos - 1)
			if event.is_action_pressed("ui_right"):
				x_pos = min(blobs_width - 1, x_pos + 1)
	
	func _update_position(delta):
		position = position.linear_interpolate(Vector2(x_pos * blob_size, y_pos * blob_size), 20.0 * delta)

