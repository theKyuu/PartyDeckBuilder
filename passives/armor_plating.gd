extends Passive

@export var block := 3


func activate_passive(owner: PassiveUI) -> void:
	var player := owner.get_tree().get_nodes_in_group("player")
	var block_effect := BlockEffect.new()
	block_effect.amount = block
	block_effect.execute(player)
	
	owner.flash()
