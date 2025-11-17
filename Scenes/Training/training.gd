class_name Training
extends Control

@export var price_increase_steps: int = 25
@export var team: TeamStats
@export var stats: RunStats

@onready var back_button = %GoBackButton
@onready var upgrade_card_button = %UpgradeCardButton
@onready var upgrade_pile_view = %UpgradePileView

var upgradable_cards: CardPile

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
		_setup_card_upgrade()
	else:
		upgrade_card_button.hide()

func _setup_card_upgrade() -> void:
	upgrade_card_button.pressed.connect(upgrade_pile_view.show_current_view.bind("Upgrade Card"))
	var upgrade_cost: int = price_increase_steps + price_increase_steps * stats.times_bought_upgrades
	upgrade_pile_view.card_pile = upgradable_cards
	upgrade_pile_view.set_upgrade_view_type(CardUpgradePopup.Type.PAID, upgrade_cost)
	var button_text: String = "Upgrade Card - %sG" % upgrade_cost
	upgrade_card_button.text = button_text
	if upgrade_cost > stats.gold:
		upgrade_card_button.disabled = true
	else:
		upgrade_card_button.disabled = false
	upgrade_card_button.show()

func _on_go_back_pressed() -> void:
	Events.event_node_exited.emit()

func _on_card_upgrade_completed() -> void:
	setup_training_options()
