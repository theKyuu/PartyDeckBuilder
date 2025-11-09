extends EnemyAction

const POWER_STATUS := preload("res://statuses/power.tres")

@export var stacks_per_action := 2
@export var hp_treshold := 60

var usages := 0

func is_performable() -> bool:
	var hp_under_treshold := enemy.stats.health <= hp_treshold
	
	if usages == 0 or (usages == 1 and hp_under_treshold):
		usages += 1
		return true
	
	return false


func perform_action() -> void:
	if not enemy or not target:
		return
	
	var status_effect := StatusEffect.new()
	var power := POWER_STATUS.duplicate()
	power.stacks = stacks_per_action
	status_effect.status = power
	status_effect.execute([enemy])
	
	Events.enemy_action_completed.emit(enemy)
