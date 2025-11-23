class_name Training
extends Control

@export var price_increase_steps: int = 25
@export var team: TeamStats
@export var stats: RunStats

@onready var back_button: Button = %GoBackButton
@onready var upgrade_card_button: Button = %UpgradeCardButton
@onready var character_card_view: CharacterCardPileView = %CharacterCardView

var upgradable_cards: CardPile
var upgrade_cost: int

func _ready() -> void:
	back_button.pressed.connect(_on_go_back_pressed)
	Events.card_upgrade_completed.connect(_on_card_upgrade_completed)

func setup_training_options() -> void:
	if not team:
		return
	
	upgradable_cards = CardPile.new()
	for card: Card in team.deck.cards:
		if card.upgrades_into:
			upgradable_cards.add_card(card)
	
	if upgradable_cards.cards.size() > 0:
		_setup_card_upgrade_button()
	else:
		upgrade_card_button.hide()

func _setup_card_upgrade_button() -> void:
	upgrade_cost = price_increase_steps + price_increase_steps * stats.times_bought_upgrades
	upgrade_card_button.text = "Upgrade Card - %sG" % upgrade_cost
	if upgrade_cost > stats.gold:
		upgrade_card_button.disabled = true
	else:
		upgrade_card_button.disabled = false
	upgrade_card_button.show()

func _on_go_back_pressed() -> void:
	Events.event_node_exited.emit()

func _on_card_upgrade_completed() -> void:
	setup_training_options()


func _on_upgrade_card_button_pressed() -> void:
	character_card_view.team = team
	character_card_view.show_hero = false
	character_card_view.type = CharacterCardPileView.Type.UPGRADE
	character_card_view.set_upgrade_view_type(CardUpgradePopup.Type.PAID, upgrade_cost)
	character_card_view.list_cards()
