extends Node

var instance: RandomNumberGenerator

func _ready() -> void:
	initialize()

func initialize() -> void:
	instance = RandomNumberGenerator.new()
	instance.randomize()

func random_int_range(from: int, to: int) -> int:
	return instance.randi_range(from, to)

func random_float_range(from: float, to: float) -> float:
	return instance.randf_range(from, to)

func set_from_save_data(which_seed: int, state: int) -> void:
	instance = RandomNumberGenerator.new()
	instance.seed = which_seed
	instance.state = state

func array_pick_random(array: Array) -> Variant:
	return array[instance.randi() % array.size()]

func array_shuffle(array: Array) -> void:
	if array.size() < 2:
		return
	
	for i in range(array.size()-1, 0, -1):
		var j := instance.randi() % (i + 1)
		var tmp = array[j]
		array[j] = array[i]
		array[i] = tmp
