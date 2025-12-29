# meta-name: Card Logic
# meta-description: What happens when a card is played.
extends Card

# Get statuses
const EXPOSED_STATUS = preload("res://statuses/exposed.tres")

# Card values
var base_damage := 6
var base_heal := 4
var base_block := 5
var exposed_duration := 1

func get_default_tooltip() -> String:
	return tooltip_text % [base_damage, base_block]

func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	
	if enemy_modifiers:
		modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	
	return tooltip_text % [modified_dmg, base_block]


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	# Damage effect
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
	# Heal effect
	var heal_effect := HealEffect.new()
	heal_effect.amount = modifiers.get_modified_value(base_heal, Modifier.Type.HEALING_RECEIVED)
	heal_effect.execute(targets)
	
	# Shield effect
	var block_effect := BlockEffect.new()
	block_effect.amount = base_block
	block_effect.sound = sound
	block_effect.execute(targets)
	
	# Status effect
	var status_effect := StatusEffect.new()
	var exposed := EXPOSED_STATUS.duplicate()
	exposed.duration = exposed_duration
	status_effect.status = exposed
	status_effect.execute(targets)
	
	# Non-targeted player effects
	var tree := targets[0].get_tree()
	var player_target = tree.get_nodes_in_group("player")
	var self_damage_effect := DamageEffect.new()
	self_damage_effect.amount = modifiers.get_modified_value(2, Modifier.Type.DMG_TAKEN)
	self_damage_effect.execute(player_target)
