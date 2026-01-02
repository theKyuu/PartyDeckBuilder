extends Card

var base_block := 8
var base_heal := 3

func apply_effects(targets: Array[Node], modifier: ModifierHandler) -> void:
	var block_effect := BlockEffect.new()
	var heal_effect := HealEffect.new()
	block_effect.amount = base_block
	block_effect.sound = sound
	heal_effect.amount = modifier.get_modified_value(base_heal, Modifier.Type.HEALING_RECEIVED)
	block_effect.execute(targets)
	heal_effect.execute(targets)
	
