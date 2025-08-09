extends Control

const RUN_SCENE := preload("res://Scenes/Run/run.tscn")

@onready var continue_button: Button = %Continue

func _ready() -> void:
	get_tree().paused = false

func _on_continue_pressed() -> void:
	print("Continue Run")


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(RUN_SCENE)


func _on_exit_pressed() -> void:
	get_tree().quit()
