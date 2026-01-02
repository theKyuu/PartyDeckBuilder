extends Card

@export var optional_sound: AudioStream

var base_heal := 6

func apply_effects(targets: Array[Node], modifier: ModifierHandler) -> void:
	var heal_effect := HealEffect.new()
	heal_effect.amount = modifier.get_modified_value(base_heal, Modifier.Type.HEALING_RECEIVED)
	heal_effect.execute(targets)
