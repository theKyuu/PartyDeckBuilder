extends Card

var base_damage := 12
var self_damage := 2

func get_default_tooltip() -> String:
	return tooltip_text % [base_damage, self_damage]

func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	var modified_self_dmg := player_modifiers.get_modified_value(self_damage, Modifier.Type.DMG_TAKEN)
	
	if enemy_modifiers:
		modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	
	return tooltip_text % [modified_dmg, modified_self_dmg]

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)
	#Find player target and deal damage
	var tree := targets[0].get_tree()
	var player_target = tree.get_nodes_in_group("player")
	var self_damage_effect := DamageEffect.new()
	self_damage_effect.amount = modifiers.get_modified_value(self_damage, Modifier.Type.DMG_TAKEN)
	self_damage_effect.execute(player_target)
	
