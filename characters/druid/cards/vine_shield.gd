extends Card

func apply_effects(targets: Array[Node]) -> void:
	var block_effect := BlockEffect.new()
	var heal_effect := HealEffect.new()
	block_effect.amount = 4
	block_effect.sound = sound
	heal_effect.amount = 2
	block_effect.execute(targets)
	heal_effect.execute(targets)
	
