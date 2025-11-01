class_name Passive
extends Resource

enum Type {START_OF_TURN, START_OF_COMBAT, END_OF_TURN, END_OF_COMBAT, EVENT_BASED}

@export var passive_name: String
@export var id: String
@export var type: Type
@export var icon: Texture
@export_multiline var tooltip: String


func initialize_passive(_owner: PassiveUI) -> void:
	pass

func activate_passive(_owner: PassiveUI) -> void:
	pass

func deactivate_passive(_owner: PassiveUI) -> void: # Only used by passives that get removed upon activation, IE Store Coupon
	pass

func get_tooltip() -> String:
	return tooltip
