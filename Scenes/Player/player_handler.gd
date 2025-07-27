class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.1
const HAND_DISCARD_INTERVAL := 0.1

@export var hand: Hand

var team: TeamStats

func _ready() -> void:
	Events.card_played.connect(_on_card_played)

func start_battle(char_stats: TeamStats) -> void:
	team = char_stats
	team.draw_pile = team.deck.duplicate(true)
	team.draw_pile.shuffle()
	team.discard = CardPile.new()
	start_turn()

func start_turn() -> void:
	team.block = 0
	team.reset_mana()
	draw_cards(team.cards_per_turn)

func end_turn() -> void:
	hand.disable_hand()
	discard_cards()

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
	team.discard.add_card(card)
