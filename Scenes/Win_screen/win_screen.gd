class_name WinScreen
extends Control

const MAIN_MENU_PATH = "res://Scenes/UI/main_menu.tscn"

@export var team_stats: TeamStats : set = set_team_stats

@onready var team_sprite_container: TeamSpriteContainer = %TeamSpriteContainer


func set_team_stats(team: TeamStats) -> void:
	team_stats = team
	for char: CharacterStats in team_stats.team:
		team_sprite_container.team_sprites.append(char.art)
	team_sprite_container.set_team_layout()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
