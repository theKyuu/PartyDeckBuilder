extends Passive

var mana_amount := 1

func activate_passive(owner: PassiveUI) -> void:
	Events.player_hand_drawn.connect(_add_mana.bind(owner), CONNECT_ONE_SHOT)

func _add_mana(owner: PassiveUI) -> void:
	owner.flash()
	var player := owner.get_tree().get_first_node_in_group("player") as Player
	if player:
		player.stats.mana += mana_amount
