extends Camera2D

export var decay = 3
export var max_offset = Vector2(10, 5)
export var max_roll = 0.1

var trauma = 0.0
var trauma_power = 2
var random: RandomNumberGenerator

func _ready():
	random = RandomNumberGenerator.new()
	random.randomize()

func add_trauma(amount):
    trauma = min(trauma + amount, 1.0)

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * random.randf_range(-1, 1)
	offset.x = max_offset.x * amount * random.randf_range(-1, 1)
	offset.y = max_offset.y * amount * random.randf_range(-1, 1)