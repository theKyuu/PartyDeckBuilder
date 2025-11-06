extends Control

const STARTER_CHAR_PICKER := preload("res://Scenes/UI/starter_character_picker.tscn")

@onready var continue_button: Button = %Continue

func _ready() -> void:
	get_tree().paused = false

func _on_continue_pressed() -> void:
	print("Continue Run")


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(STARTER_CHAR_PICKER)


func _on_exit_pressed() -> void:
	get_tree().quit()
