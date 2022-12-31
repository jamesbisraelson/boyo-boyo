class_name GameArea

extends Node2D

const gravity_timer_slow: float = 0.25
const gravity_timer_medium: float = 0.15
const gravity_timer_fast: float = 0.10
const gravity_timer_faster: float = 0.05

const area_width: int = 7
const area_height: int = 14

var player_blob: PlayerBlob
var blob_list: Array

var blobs_spawned: int
var spawn_timer: float

var next_head: int
var next_tail: int
var next_head_spr: Sprite
var next_tail_spr: Sprite

var random: RandomNumberGenerator

signal next_blob_changed

func _init():
	next_head_spr = Sprite.new()
	next_tail_spr = Sprite.new()
	add_child(next_head_spr)
	add_child(next_tail_spr)

	blobs_spawned = 0
	blob_list.resize(area_width * area_height)
	blob_list.fill(null)


func _ready():
	next_head_spr.global_position = Vector2(168, 40)
	next_tail_spr.global_position = Vector2(168, 48)
	next_head_spr.z_index = 2
	next_tail_spr.z_index = 2

	random = RandomNumberGenerator.new()
	random.seed = get_parent().seed_num

	$Timer.connect("timeout", self, "_gravity")
	self.connect("next_blob_changed", self, "_next_blob_changed")
	_get_next_blobs()
	_spawn_blob()


func _process(_delta):
	if player_blob is PlayerBlob and player_blob.hit_bottom:
		_start_break_phase()
	if blobs_spawned > 10:
		$Timer.wait_time = gravity_timer_medium
	if blobs_spawned > 20:
		$Timer.wait_time = gravity_timer_fast
	if blobs_spawned > 30:
		$Timer.wait_time = gravity_timer_faster

	if blob_list[(3 * area_width) + 3] != null:
		game_over()


func _next_blob_changed():
	next_tail_spr.texture = load("res://blob%d.png" % next_tail)
	next_head_spr.texture = load("res://blob%d.png" % next_head)


func _get_next_blobs():
	next_head = random.randi_range(1, 5)
	next_tail = random.randi_range(1, 5)
	emit_signal("next_blob_changed")


func game_over():
	get_tree().quit()


func _remove_player():
	if player_blob != null:		
		player_blob.player_to_blob()
		player_blob.queue_free()
		player_blob = null

func _spawn_blob():
	blobs_spawned += 1
	var blob = PlayerBlob.new(next_head, next_tail, 3, 0)
	player_blob = blob
	add_child(blob)
	_get_next_blobs()


func _gravity():
	if player_blob is PlayerBlob:
		player_blob.move_down()

func _start_break_phase():
	_remove_player()

	var broke_blob: bool = true
	while(broke_blob):
		yield(get_tree().create_timer(0.5), "timeout")
		broke_blob = false
		for blob in blob_list:
			if blob is Blob and blob.should_break:
				blob.break_blob()
				broke_blob = true

		if broke_blob:
			$GameCamera.add_trauma(1.0)
	_spawn_blob()