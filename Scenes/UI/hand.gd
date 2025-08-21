class_name Hand
extends Container

@export var team_stats: TeamStats

@onready var card_ui := preload("res://Scenes/Card_UI/card_ui.tscn")

@export_group("Card layout vars")
@export var hand_curve: Curve
@export var rotation_curve: Curve
@export var max_rotation_degrees := 5
@export var x_sep := -10
@export var y_min := 0
@export var y_max := -15


func add_card(card: Card) -> void:
	var new_card_ui := card_ui.instantiate()
	add_child(new_card_ui)
	new_card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	new_card_ui.card = card
	new_card_ui.parent = self
	new_card_ui.team_stats = team_stats
	_update_cards()

func discard_card(card: CardUI) -> void:
	card.queue_free()
	_update_cards()

func disable_hand() -> void:
	for card in get_children():
		card.disabled = true

func _update_cards() -> void:
	var cards := get_child_count()
	var all_cards_size := CardUI.SIZE.x * cards + x_sep * (cards - 1)
	var final_x_sep: float = x_sep
	
	if all_cards_size > size.x:
		final_x_sep = (size.x - CardUI.SIZE.x * cards) / (cards - 1)
		all_cards_size = size.x
	
	var offset := (size.x - all_cards_size) / 2
	
	for i in cards:
		var card := get_child(i)
		var y_multiplier := hand_curve.sample(1.0 / (cards-1) * i)
		var rot_multiplier := rotation_curve.sample(1.0 / (cards-1) * i)
		
		if cards == 1:
			y_multiplier = 0.0
			rot_multiplier = 0.0
		
		var final_x: float = offset + CardUI.SIZE.x * i + final_x_sep
		var final_y: float = y_min + y_max * y_multiplier
		
		card.position = Vector2(final_x, final_y)
		card.rotation_degrees = max_rotation_degrees * rot_multiplier


func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.disabled = true
	child.reparent(self)
	var new_index := clampi(child.original_index, 0, get_child_count())
	move_child.call_deferred(child, new_index)
	child.set_deferred("disabled", false)


func _on_child_order_changed() -> void:
	_update_cards()
