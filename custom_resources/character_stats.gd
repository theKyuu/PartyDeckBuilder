class_name CharacterStats
extends Stats

enum Rarity {STARTER, COMMON, UNCOMMON, SPECIAL, PLAYER_CHARACTER}

@export_group("Character Data")
@export var rarity: Rarity
# TODO: Figure out how event-locked character should work

@export_group("Visuals")
@export var character_name: String
@export_multiline var description: String
@export var portrait: Texture

@export_group("Gameplay Data")
@export var starting_deck: CardPile
@export var cards_per_turn: int
@export var max_mana: int
@export var passive: Passive

@export var deck: CardPile
