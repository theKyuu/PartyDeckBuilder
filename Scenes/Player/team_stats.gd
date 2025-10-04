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
	mana = max_mana

func take_damage(damage: int) -> void:
	var initial_health := health
	super.take_damage(damage)
	if initial_health > health:
		Events.player_hit.emit()

func can_play_card(card: Card) -> bool:
	return mana >= card.cost

func set_combined_stats() -> void:
	var total_health := 0
	var total_mana := 0
	var total_cards_per_turn := 0
	var combined_deck = CardPile.new()
	for character: CharacterStats in team:
		total_health += character.max_health
		total_mana += character.max_mana
		total_cards_per_turn += character.cards_per_turn
		if not character.deck:
			character.deck = character.starting_deck
		for card in character.deck.cards:
			combined_deck.add_card(card)
	deck = combined_deck.duplicate()
	max_health = total_health
	max_mana = total_mana
	cards_per_turn = total_cards_per_turn

func create_instance() -> Resource:
	var instance: TeamStats = self.duplicate()
	instance.set_combined_stats()
	instance.health = instance.max_health
	instance.block = 0
	instance.reset_mana()
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	return instance
