# meta-name: Passive
# meta-description: Create a Passive ability that a character can possess
extends Passive

var member_var := 0

func initialize_passive(_owner: PassiveUI) -> void:
	print("What happence once this passive is obtained")

func activate_passive(_owner: PassiveUI) -> void:
	print("What happens at specific times based on the Passive.Type property")

func deactivate_passive(_owner: PassiveUI) -> void: # Only used by passives that get removed upon activation, IE Store Coupon
	print("What happens when this passive is deleted (PassiveUI leaving the SceneTree)")
	print("Remember to disconnect from the EventBus if you use this")

# Only use this if you need magic numbers in the tooltip text
func get_tooltip() -> String:
	return tooltip
