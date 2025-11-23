class_name CharacterCardPileView
extends Control

const CHARACTER_CARDS_COMPONENT = preload("res://Scenes/UI/character_cards_component.tscn")
enum Type {DISPLAY, UPGRADE}

@export var team: TeamStats
@export var type: Type = Type.DISPLAY
@export var show_hero: bool = true

@onready var character_cards_container: VBoxContainer = %CharacterCardsContainer
@onready var back_button: Button = %BackButton
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopup
@onready var card_upgrade_popup: CardUpgradePopup = %CardUpgradePopup

func _ready() -> void:
	back_button.pressed.connect(hide)
	card_tooltip_popup.hide_tooltip()
	card_upgrade_popup.hide_tooltip()

	for character_cards_component: Control in character_cards_container.get_children():
		character_cards_component.queue_free()
	
	# Test func
	await get_tree().create_timer(1.0).timeout
	for character: CharacterStats in team.team:
		character.deck = character.starting_deck
		
	list_cards()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if card_tooltip_popup.visible:
			card_tooltip_popup.hide_tooltip()
		elif card_upgrade_popup.visible:
			card_upgrade_popup.hide_tooltip()
		else:
			hide()


func list_cards() -> void:
	for character: CharacterStats in team.team:
		if show_hero or character.character_name != "Hero":
			var character_cards_component := CHARACTER_CARDS_COMPONENT.instantiate() as CharacterCardsComponent
			character_cards_component.character = character
			character_cards_component.card_tooltip_popup = card_tooltip_popup
			character_cards_component.card_upgrade_popup = card_upgrade_popup
			character_cards_container.add_child(character_cards_component)
			character_cards_component.list_cards(type)
	
	show()
