class_name GameArea

extends Node2D

const gravity_timer_slow: float = 0.30
const gravity_timer_medium: float = 0.25
const gravity_timer_fast: float = 0.20
const gravity_timer_faster: float = 0.15

const area_width: int = 7
const area_height: int = 14
const start_pos: int = 2
const bomb_type: int = 6

var player_blob: PlayerBlob
var blob_list: Array

var blobs_spawned: int
var spawn_timer: float

var next_head: int
var next_tail: int
var next_head_spr: Sprite
var next_tail_spr: Sprite

var random: RandomNumberGenerator

var score: int
var add_to_score: int

var game_over = false
var broke_blob = true


signal next_blob_changed

func _init():
	score = 0
	add_to_score = 0

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
	next_head_spr.z_index = start_pos
	next_tail_spr.z_index = start_pos

	random = RandomNumberGenerator.new()
	random.seed = get_parent().seed_num

	$GravityTimer.connect("timeout", self, "_gravity")
	self.connect("next_blob_changed", self, "_next_blob_changed")
	_get_next_blobs()
	_spawn_blob()


func _process(delta):
	if not game_over:
		_update_score()

		get_node("/root/GameScene/Border/Score").text = "%005d" % score

		if player_blob is PlayerBlob and player_blob.hit_bottom:
			_start_break_phase()
		if blobs_spawned < 10:
			$GravityTimer.wait_time = gravity_timer_slow
		elif blobs_spawned < 25:
			$GravityTimer.wait_time = gravity_timer_medium
		elif blobs_spawned < 50:
			$GravityTimer.wait_time = gravity_timer_fast
		else:
			$GravityTimer.wait_time = gravity_timer_faster

	if blob_list[(3 * area_width) + 3] != null:
		start_game_over()

func _input(event):
	if event is InputEventKey or event is InputEventJoypadButton:
		if event.pressed and game_over:
			get_tree().change_scene("res://scenes/MenuScene.tscn")

func _update_score():
	if add_to_score > 0:
		var amount = min(9 + (randi() % 2), add_to_score)
		add_to_score -= amount
		score += amount

func _next_blob_changed():
	next_tail_spr.texture = load("res://assets/blob%d.png" % next_tail)
	next_head_spr.texture = load("res://assets/blob%d.png" % next_head)


func _get_next_blobs():
	next_head = random.randi_range(1, 5)
	next_tail = random.randi_range(1, 5)

	var add_bomb = random.randi_range(1, 100)
	if add_bomb <= 5:
		next_head = bomb_type
	elif add_bomb <= 10:
		next_head = bomb_type

	emit_signal("next_blob_changed")


func start_game_over():
	game_over = true

	for blob in blob_list:
		if blob is Blob:
			blob.break_blob()
	
	get_node("/root/GameScene/GameOverBackground").visible = true
			
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

# this function is gross and i should fix it sometime
func _start_break_phase():
	_remove_player()

	broke_blob = true
	while(broke_blob):
		yield(get_tree().create_timer(0.5), "timeout")

		broke_blob = false
		for blob in blob_list:
			if not game_over and blob is Blob and blob.should_break:
				add_to_score += 100
				blob.break_blob()
				broke_blob = true

		if broke_blob:
			$GameCamera.add_trauma(1.0)

	if not game_over:
		_spawn_blob()