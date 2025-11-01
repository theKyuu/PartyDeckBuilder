class_name PassiveUI
extends Control

@export var passive: Passive : set = set_passive

@onready var icon: TextureRect = $Icon
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func set_passive(new_passive: Passive) -> void:
	if not is_node_ready():
		await ready
	
	passive = new_passive
	icon.texture = passive.icon

func flash() -> void:
	animation_player.play("flash")

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		queue_free()
