class_name Training
extends Control

@export var upgrade_price_increase_steps: int = 25
@export var removal_price_increase_steps: int = 30
@export var team: TeamStats
@export var stats: RunStats

@onready var back_button: Button = %GoBackButton
@onready var upgrade_card_button: Button = %UpgradeCardButton
@onready var remove_card_button: Button = %RemoveCardButton
@onready var character_card_view: CharacterCardPileView = %CharacterCardView

var upgradable_cards: CardPile
var removable_cards: CardPile
var upgrade_cost: int
var removal_cost: int

func _ready() -> void:
	back_button.pressed.connect(_on_go_back_pressed)
	Events.card_upgrade_completed.connect(_on_card_edit_completed)
	Events.card_removal_completed.connect(_on_card_edit_completed)

func setup_training_options() -> void:
	if not team:
		return
	
	upgradable_cards = CardPile.new()
	removable_cards = CardPile.new()
	for character: CharacterStats in team.team:
		for card: Card in character.deck.cards:
			if character.character_name != "Hero":
				removable_cards.add_card(card)
			if card.upgrades_into:
				upgradable_cards.add_card(card)
	
	if upgradable_cards.cards.size() > 0:
		_setup_card_upgrade_button()
	else:
		upgrade_card_button.hide()
	
	if removable_cards.cards.size() > 0:
		_setup_card_removal_button()
	else:
		remove_card_button.hide()

func _setup_card_upgrade_button() -> void:
	upgrade_cost = upgrade_price_increase_steps + upgrade_price_increase_steps * stats.times_bought_upgrades
	upgrade_card_button.text = "Upgrade Card - %sG" % upgrade_cost
	if upgrade_cost > stats.gold:
		upgrade_card_button.disabled = true
	else:
		upgrade_card_button.disabled = false
	upgrade_card_button.show()

func _setup_card_removal_button() -> void:
	removal_cost = removal_price_increase_steps + removal_price_increase_steps * stats.times_bought_removal
	remove_card_button.text = "Remove Card - %sG" % removal_cost
	if removal_cost > stats.gold:
		remove_card_button.disabled = true
	else:
		remove_card_button.disabled = false
	remove_card_button.show()


func _on_go_back_pressed() -> void:
	Events.event_node_exited.emit()

func _on_card_edit_completed() -> void:
	setup_training_options()


func _on_upgrade_card_button_pressed() -> void:
	character_card_view.team = team
	character_card_view.show_hero = false
	character_card_view.type = CharacterCardPileView.Type.UPGRADE
	character_card_view.set_upgrade_view_type(CardUpgradePopup.Type.PAID, upgrade_cost)
	character_card_view.title_text = "Select a card to upgrade:"
	character_card_view.list_cards()


func _on_remove_card_button_pressed() -> void:
	character_card_view.team = team
	character_card_view.show_hero = false
	character_card_view.type = CharacterCardPileView.Type.REMOVE
	character_card_view.set_removal_view_type(CardRemovalPopup.Type.PAID, removal_cost)
	character_card_view.title_text = "Select a card to remove:"
	character_card_view.list_cards()


func _on_copy_card_pressed() -> void:
	character_card_view.team = team
	character_card_view.show_hero = false
	character_card_view.type = CharacterCardPileView.Type.COPY
	character_card_view.set_copy_view_type(CardCopyPopup.Type.EVENT, 0)
	character_card_view.title_text = "Select a card to copy:"
	character_card_view.list_cards()
