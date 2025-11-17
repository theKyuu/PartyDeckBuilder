class_name Training
extends Control

@export var team: TeamStats

@onready var back_button = %GoBackButton
@onready var upgrade_card_button = %UpgradeCardButton
@onready var upgrade_pile_view = %UpgradePileView

var upgradable_cards: CardPile

func _ready() -> void:
	back_button.pressed.connect(_on_go_back_pressed)

func setup_training_options() -> void:
	if not team:
		return
	
	upgradable_cards = CardPile.new()
	for card: Card in team.deck.cards:
		if card.upgrades_into:
			upgradable_cards.add_card(card)
	
	if upgradable_cards.cards.size() > 0:
		upgrade_pile_view.card_pile = upgradable_cards
		upgrade_card_button.pressed.connect(upgrade_pile_view.show_current_view.bind("Upgrade Card"))
		upgrade_card_button.show()

func _on_go_back_pressed() -> void:
	Events.event_node_exited.emit()
