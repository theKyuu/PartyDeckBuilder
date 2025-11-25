class_name CardPile
extends Resource

signal card_pile_size_changed(cards_amount)

@export var cards: Array[Card] = []

func empty() -> bool:
	return cards.is_empty()

func draw_card() -> Card:
	var card = cards.pop_front()
	card_pile_size_changed.emit(cards.size())
	return card

func add_card(card: Card):
	cards.append(card)
	card_pile_size_changed.emit(cards.size())

func remove_card(card: Card):
	cards.erase(card)
	card_pile_size_changed.emit(cards.size())

func replace_card(origin_card: Card, new_card: Card):
	if cards.has(origin_card):
		cards.erase(origin_card)
		cards.append(new_card)

func shuffle() -> void:
	RNG.array_shuffle(cards)

func clear() -> void:
	cards.clear()
	card_pile_size_changed.emit(cards.size())

# Custom card duplications due to error in the Godot base function
# This one to duplicate a card array
func duplicate_cards() -> Array[Card]:
	var new_array: Array[Card]
	
	for card: Card in cards:
		new_array.append(card.duplicate())
	
	return new_array

# This one to duplicate a CardPile object
func duplicate_cardpile() -> CardPile:
	var new_card_pile := CardPile.new()
	new_card_pile.cards = duplicate_cards()
	
	return new_card_pile


func _to_string() -> String:
	var _card_strings: PackedStringArray = []
	for i in range(cards.size()):
		_card_strings.append("%s: %s" % [i+1, cards[i].id])
	return "\n".join(_card_strings)
