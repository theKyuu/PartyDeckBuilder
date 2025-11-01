extends Passive

@export var damage := 2


func activate_passive(owner: PassiveUI) -> void:
	var enemies := owner.get_tree().get_nodes_in_group("enemies")
	var damage_effect := DamageEffect.new()
	damage_effect.amount = damage
	damage_effect.receiver_modifier_type = Modifier.Type.NO_MODIFIER # This damage ignores modifiers
	damage_effect.execute(enemies)
	
	owner.flash()
