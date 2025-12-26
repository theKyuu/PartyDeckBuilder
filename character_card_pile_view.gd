class_name CharacterCardPileView
extends Control

const CHARACTER_CARDS_COMPONENT = preload("res://Scenes/UI/character_cards_component.tscn")
enum Type {DISPLAY, UPGRADE, REMOVE, COPY, REPLACE}

@export var team: TeamStats
@export var type: Type = Type.DISPLAY
@export var show_hero: bool = true
@export var title_text: String: set = set_title

@onready var card_pile_title: Label = %CardPileTitle
@onready var character_cards_container: VBoxContainer = %CharacterCardsContainer
@onready var back_button: Button = %BackButton
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopup
@onready var card_upgrade_popup: CardUpgradePopup = %CardUpgradePopup
@onready var card_removal_popup: CardRemovalPopup = %CardRemovalPopup
@onready var card_copy_popup: CardCopyPopup = %CardCopyPopup

var hero_character: CharacterStats

func _ready() -> void:
	back_button.pressed.connect(_hide_view)
	Events.card_edit_completed.connect(_hide_view)
	Events.card_copy_initiated.connect(_on_card_copy_initiated)

	card_tooltip_popup.hide_tooltip()
	card_upgrade_popup.hide_tooltip()
	card_removal_popup.hide_tooltip()
	card_copy_popup.hide_tooltip()

	for character_cards_component: Control in character_cards_container.get_children():
		character_cards_component.queue_free()
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if card_tooltip_popup.visible:
			card_tooltip_popup.hide_tooltip()
		elif card_upgrade_popup.visible:
			card_upgrade_popup.hide_tooltip()
		elif card_removal_popup.visible:
			card_removal_popup.hide_tooltip()
		elif card_copy_popup.visible:
			card_copy_popup.hide_tooltip()
		else:
			_hide_view()

func set_title(new_title: String) -> void:
	title_text = new_title
	card_pile_title.text = new_title

func set_upgrade_view_type(type: CardUpgradePopup.Type, cost: int) -> void:
	card_upgrade_popup.type = type
	if cost > 0:
		card_upgrade_popup.upgrade_cost = cost

func set_removal_view_type(type: CardRemovalPopup.Type, cost: int) -> void:
	card_removal_popup.type = type
	if cost > 0:
		card_removal_popup.removal_cost = cost

func set_copy_view_type(type: CardCopyPopup.Type, cost: int) -> void:
	card_copy_popup.type = type
	if cost > 0:
		card_copy_popup.copy_cost = cost


func list_cards() -> void:
	for character: CharacterStats in team.team:
		if character.rarity == CharacterStats.Rarity.PLAYER_CHARACTER:
			hero_character = character
		if show_hero or character.rarity != CharacterStats.Rarity.PLAYER_CHARACTER:
			list_single_characters_cards(character, false)
	
	show()

func list_single_characters_cards(character: CharacterStats, show_immediately: bool = true) -> void:
	var character_cards_component := CHARACTER_CARDS_COMPONENT.instantiate() as CharacterCardsComponent
	character_cards_component.character = character
	character_cards_component.hero_deck = hero_character.deck
	character_cards_component.card_tooltip_popup = card_tooltip_popup
	character_cards_component.card_upgrade_popup = card_upgrade_popup
	character_cards_component.card_removal_popup = card_removal_popup
	character_cards_component.card_copy_popup = card_copy_popup
	character_cards_container.add_child(character_cards_component)
	character_cards_component.list_cards(type)
	
	if show_immediately:
		show()

func _on_card_copy_initiated(card: Card) -> void:
	_hide_view()
	if hero_character:
		type = Type.REPLACE
		card_copy_popup.prepare_replace(card)
		list_single_characters_cards(hero_character)

func _hide_view() -> void:
	card_copy_popup.view_state = CardCopyPopup.ViewState.COPY
	for character_cards_component: Node in character_cards_container.get_children():
			character_cards_component.queue_free()
	hide()
