class_name CharacterCardsComponent
extends Control

@export var character: CharacterStats

@onready var character_name: Label = %CharacterName
@onready var character_portrait: TextureRect = %CharacterPortrait
@onready var cards: GridContainer = %Cards
