class_name PoweringUpStatus
extends Status

const POWER_STATUS = preload("res://statuses/power.tres")

var stacks_per_turn := 2

func apply_status(target: Node) -> void:
	var status_effect := StatusEffect.new()
	var power := POWER_STATUS.duplicate()
	power.stacks = stacks_per_turn
	status_effect.status = power
	status_effect.execute([target])
	
	status_applied.emit(self)
