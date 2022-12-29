class_name GameArea

extends Node2D

const gravity_timer_slow: float = 0.25
const gravity_timer_medium: float = 0.15
const gravity_timer_fast: float = 0.10
const gravity_timer_faster: float = 0.05

const area_width: int = 6
const area_height: int = 15

var player_blob: PlayerBlob
var blob_list: Array

var blobs_spawned: int
var spawn_timer: float

func _init():
	blobs_spawned = 0
	blob_list.resize(area_width * area_height)
	blob_list.fill(null)

func _ready():
	randomize()
	$Timer.connect("timeout", self, "_gravity")
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


func _remove_player():
	if player_blob != null:		
		player_blob.player_to_blob()
		player_blob.queue_free()
		player_blob = null

func _spawn_blob():
	blobs_spawned += 1
	var blob = PlayerBlob.new((randi() % 5) + 1, (randi() % 5) + 1, 2, 0)
	player_blob = blob
	add_child(blob)


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