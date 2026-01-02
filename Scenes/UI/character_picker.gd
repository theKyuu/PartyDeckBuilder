class_name CharacterPicker
extends Control

@export var character_pool: CharacterPool
@export var team: TeamStats

@onready var title: Label = %Title
@onready var description: Label = %Description
@onready var character_portrait: TextureRect = %CharacterPortrait
@onready var char_icon_1: TextureRect = %CharIcon1
@onready var char_icon_2: TextureRect = %CharIcon2

var available_characters: Array[CharacterStats]
var current_character: CharacterStats : set = set_current_character


func _ready() -> void:
	character_pool.setup_rng_weights()

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
	
	char_icon_1.texture = available_characters[0].art
	char_icon_2.texture = available_characters[1].art
	
	set_current_character(available_characters[0])
	
	
func set_current_character(new_character: CharacterStats) -> void:
	current_character = new_character
	title.text = current_character.character_name
	description.text = current_character.description
	character_portrait.texture = current_character.portrait

func _on_select_button_pressed() -> void:
	Events.character_added.emit(current_character)
	Events.event_node_exited.emit()


func _on_char_button_1_pressed() -> void:
	set_current_character(available_characters[0])


func _on_char_button_2_pressed() -> void:
	set_current_character(available_characters[1])
