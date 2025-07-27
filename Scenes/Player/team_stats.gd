class_name TeamStats
extends Stats

@export var team: Array[CharacterStats]
var cards_per_turn := 0
var max_mana := 0
var mana: int : set = set_mana
var deck: CardPile
var discard: CardPile
var draw_pile: CardPile

func set_mana(value : int) -> void:
	mana = value
	stats_changed.emit()

func reset_mana() -> void:
	self.mana = max_mana

func take_damage(damage: int) -> void:
	var initial_health := health
	super.take_damage(damage)
	if initial_health > health:
		Events.player_hit.emit()

func can_play_card(card: Card) -> bool:
	return mana >= card.cost

func create_instance() -> Resource:
	var instance: TeamStats = self.duplicate()
	var total_health := 0
	var total_mana := 0
	var total_cards_per_turn := 0
	var combined_deck = CardPile.new()
	for character in team:
		total_health += character.max_health
		total_mana += character.max_mana
		total_cards_per_turn += character.cards_per_turn
		for card in character.starting_deck.cards:
			combined_deck.add_card(card)
	instance.max_health = total_health
	instance.health = total_health
	instance.block = 0
	instance.cards_per_turn = total_cards_per_turn
	instance.max_mana = total_mana
	instance.reset_mana()
	instance.deck = combined_deck.duplicate()
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	return instance
