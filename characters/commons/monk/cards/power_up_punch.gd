extends Card

# Get statuses
const POWER_STATUS = preload("res://statuses/power.tres")

# Card values
var base_damage := 2

func get_default_tooltip() -> String:
	return tooltip_text % [base_damage]

func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	
	if enemy_modifiers:
		modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	
	return tooltip_text % [modified_dmg]


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	# Damage effect
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
	# Non-targeted player effects
	var tree := targets[0].get_tree()
	var player_target = tree.get_nodes_in_group("player")

	# Status effect
	var status_effect := StatusEffect.new()
	var power := POWER_STATUS.duplicate()
	status_effect.status = power
	status_effect.execute(player_target)
	
