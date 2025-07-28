extends Card

@export var optional_sound: AudioStream

func apply_effects(targets: Array[Node]) -> void:
	var heal_effect := HealEffect.new()
	heal_effect.amount = 4
	heal_effect.execute(targets)
