extends Control

const WARRIOR_STATS := preload("res://characters/warrior/warrior.tres")
const DRUID_STATS := preload("res://characters/druid/druid.tres")

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

func _on_select_button_pressed() -> void:
	Events.character_added.emit(current_character)
	Events.event_node_exited.emit()

func _on_warrior_button_pressed() -> void:
	current_character = WARRIOR_STATS

func _on_druid_button_pressed() -> void:
	current_character = DRUID_STATS
