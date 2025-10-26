# meta-name: EnemyAction
# meta-description: An action which can be performed by an enemy during its turn.
extends EnemyAction

# Can be damage or block depending on action
@export var damage := 6

# The actual action script
func perform_action() -> void:
	if not enemy or not target:
		return
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 32
	
	SFXPlayer.play(sound)
	
	Events.enemy_action_completed.emit(enemy)

# Determine how to dynamically set the intent text for the specific behavior 
func update_intent_text() -> void:
	var player := target as Player
	if not player:
		return
	
	var modified_dmg := player.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_TAKEN)
	intent.current_text = intent.base_text % modified_dmg
