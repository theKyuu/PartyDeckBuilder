# Player turn order:
# 1. START_OF_TURN Passives
# 2. START_OF_TURN Statuses
# 3. Draw Hand
# 4. End Turn
# 5. END_OF_TURN Passives
# 6. END_OF_TURN Statuses
# 7. Discard Hand
class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.1
const HAND_DISCARD_INTERVAL := 0.1

@export var passives: PassiveHandler
@export var player: Player
@export var hand: Hand

var team: TeamStats

func _ready() -> void:
	Events.card_played.connect(_on_card_played)

func start_battle(char_stats: TeamStats) -> void:
	team = char_stats
	team.draw_pile = team.deck.duplicate_cardpile()
	team.draw_pile.shuffle()
	team.discard = CardPile.new()
	passives.passives_activated.connect(_on_passives_activated)
	player.status_handler.statuses_applied.connect(_on_statuses_applied)
	start_turn()

func start_turn() -> void:
	team.block = 0
	team.reset_mana()
	passives.activate_passives_by_type(Passive.Type.START_OF_TURN)

func end_turn() -> void:
	hand.disable_hand()
	passives.activate_passives_by_type(Passive.Type.END_OF_TURN)

func draw_card() -> void:
	reshuffle_deck_from_discard()
	hand.add_card(team.draw_pile.draw_card())
	reshuffle_deck_from_discard()

func draw_cards(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): Events.player_hand_drawn.emit()
	)

func discard_cards() -> void:
	var remaining_cards := hand.get_children()
	if remaining_cards.is_empty():
		Events.player_hand_discarded.emit()
		return
	
	var tween := create_tween()
	
	for card_ui in hand.get_children():
		tween.tween_callback(team.discard.add_card.bind(card_ui.card))
		tween.tween_callback(hand.discard_card.bind(card_ui))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
	
	tween.finished.connect(
		func(): Events.player_hand_discarded.emit()
	)

func reshuffle_deck_from_discard() -> void:
	if not team.draw_pile.empty():
		return
	while not team.discard.empty():
		team.draw_pile.add_card(team.discard.draw_card())
	
	team.draw_pile.shuffle()

func _on_card_played(card: Card) -> void:
	if card.exhausts or card.type == Card.Type.POWER:
		return
	
	team.discard.add_card(card)

func _on_passives_activated(type: Passive.Type) -> void:
	match type:
		Passive.Type.START_OF_TURN:
			player.status_handler.apply_statuses_by_type(Status.Type.START_OF_TURN)
		Passive.Type.END_OF_TURN:
			player.status_handler.apply_statuses_by_type(Status.Type.END_OF_TURN)

func _on_statuses_applied(type: Status.Type) -> void:
	match type:
		Status.Type.START_OF_TURN:
			draw_cards(team.cards_per_turn)
		Status.Type.END_OF_TURN:
			discard_cards()
