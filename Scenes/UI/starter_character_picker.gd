extends Control

const RUN_SCENE := preload("res://Scenes/Run/run.tscn")
const WARRIOR_STATS := preload("res://characters/starters/warrior/warrior.tres")
const DRUID_STATS := preload("res://characters/starters/druid/druid.tres")

@export var run_startup: RunStartup

@onready var title: Label = %Title
@onready var description: Label = %Description
@onready var character_portrait: TextureRect = %CharacterPortrait

var current_character: CharacterStats : set = set_current_character

func _ready() -> void:
	set_current_character(WARRIOR_STATS)

func set_current_character(new_character: CharacterStats) -> void:
	current_character = new_character
	title.text = current_character.character_name
	description.text = current_character.description
	character_portrait.texture = current_character.portrait

func _on_warrior_button_pressed() -> void:
	current_character = WARRIOR_STATS

func _on_druid_button_pressed() -> void:
	current_character = DRUID_STATS

func _on_select_button_pressed() -> void:
	run_startup.type = RunStartup.Type.NEW_RUN
	run_startup.player_team.team.append(current_character.duplicate())
	run_startup.passive = current_character.passive
	get_tree().change_scene_to_packed(RUN_SCENE)
	
