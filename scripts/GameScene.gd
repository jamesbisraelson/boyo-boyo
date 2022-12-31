extends Node2D

var seed_num: int

func _init():
	randomize()
	seed_num = randi()