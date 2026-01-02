class_name RunStats
extends Resource

signal gold_changed

const STARTING_GOLD := 50

@export var gold := STARTING_GOLD : set = set_gold
@export var times_bought_upgrades : int = 0
@export var times_bought_removal : int = 0
@export var times_bought_copy : int = 0

func set_gold(new_amount: int) -> void:
	gold = new_amount
	gold_changed.emit()
