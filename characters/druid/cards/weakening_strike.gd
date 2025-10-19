extends Card

const EXPOSED_STATUS = preload("res://statuses/exposed.tres")

var base_damage := 6
var exposed_duration := 1

func apply_effects(targets: Array[Node], modifier: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifier.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
	var status_effect := StatusEffect.new()
	var exposed := EXPOSED_STATUS.duplicate()
	exposed.duration = exposed_duration
	status_effect.status = exposed
	status_effect.execute(targets)
