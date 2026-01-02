class_name CharacterPicker
extends Control

const WARRIOR_STATS := preload("res://characters/starters/warrior/warrior.tres")
const DRUID_STATS := preload("res://characters/starters/druid/druid.tres")

@export var character_pool: CharacterPool
@export var team: TeamStats

@onready var title: Label = %Title
@onready var description: Label = %Description
@onready var character_portrait: TextureRect = %CharacterPortrait


var available_characters: Array[CharacterStats]
var current_character: CharacterStats : set = set_current_character

func _ready() -> void:
	character_pool.setup_rng_weights()
	set_current_character(WARRIOR_STATS)

func setup_available_characters() -> void:
	while available_characters.size() < 2:
		var character: CharacterStats = character_pool.get_random_character()
		if not available_characters.has(character):
			var in_team: bool = false
			for player_char: CharacterStats in team.team:
				if player_char.character_name == character.character_name:
					in_team = true
			if not in_team:
				available_characters.append(character)
	
	for character: CharacterStats in available_characters:
		print(character.character_name)

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
	Events.character_added.emit(current_character)
	Events.event_node_exited.emit()
