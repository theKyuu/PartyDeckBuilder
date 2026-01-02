extends Card

# Get statuses
const FORTIFIED_STATUS = preload("res://statuses/fortified.tres")

# Card values
var fortified_duration := 1

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:

	# Status effect
	var status_effect := StatusEffect.new()
	var fortified := FORTIFIED_STATUS.duplicate()
	fortified.duration = fortified_duration
	status_effect.status = fortified
	status_effect.execute(targets)
