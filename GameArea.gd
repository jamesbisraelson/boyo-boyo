class_name GameArea

extends Node2D

const area_width: int = 6
const area_height: int = 15

var player_blob: PlayerBlob
var blob_list: Array

func _init():
	blob_list.resize(area_width * area_height)
	blob_list.fill(0)

func _ready():
	$Timer.connect("timeout", self, "_gravity")
	_spawn_blob()

func _spawn_blob():
	if player_blob != null:
		player_blob.queue_free()
	var blob = PlayerBlob.new(1, 2, 2, 0)
	player_blob = blob
	add_child(blob)


func _gravity():
	player_blob.move_down()