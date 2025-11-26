class_name CharacterCardsComponent
extends Control

const CARD_MENU_UI_SCENE := preload("res://Scenes/UI/card_menu_ui.tscn")

@export var character: CharacterStats
@export var card_tooltip_popup: CardTooltipPopup
@export var card_upgrade_popup: CardUpgradePopup
@export var card_removal_popup: CardRemovalPopup

@onready var character_name: Label = %CharacterName
@onready var character_portrait: TextureRect = %CharacterPortrait
@onready var cards_container: GridContainer = %Cards


func list_cards(type: CharacterCardPileView.Type) -> void:
	for card: Node in cards_container.get_children():
		card.queue_free()
	
	if not character:
		return
	
	character_name.text = character.character_name
	character_portrait.texture = character.portrait
	_update_view.call_deferred(type)

func _update_view(type: CharacterCardPileView.Type) -> void:
	if not character or not character.deck:
		return
	
	var all_character_cards := character.deck.cards.duplicate()
	
	for card: Card in all_character_cards:
		if type != CharacterCardPileView.Type.UPGRADE or card.upgrades_into:
			var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
			cards_container.add_child(new_card)
			new_card.card_owner = character
			new_card.card = card
			if type == CharacterCardPileView.Type.DISPLAY:
				new_card.tooltip_requested.connect(card_tooltip_popup.show_tooltip)
			elif type == CharacterCardPileView.Type.UPGRADE:
				new_card.tooltip_requested.connect(card_upgrade_popup.show_tooltip)
			elif type == CharacterCardPileView.Type.REMOVE:
				new_card.tooltip_requested.connect(card_removal_popup.show_tooltip)
	
	if cards_container.get_child_count() < 1:
		hide()
