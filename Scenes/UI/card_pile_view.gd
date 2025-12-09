class_name CardPileView
extends Control

const CARD_MENU_UI_SCENE := preload("res://Scenes/UI/card_menu_ui.tscn")
enum Type {DISPLAY, UPGRADE}

@export var card_pile: CardPile
@export var type: Type = Type.DISPLAY

@onready var title: Label = %Title
@onready var cards: GridContainer = %Cards
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopup
@onready var card_upgrade_popup: CardUpgradePopup = %CardUpgradePopup
@onready var back_button: Button = %BackButton

func _ready() -> void:
	back_button.pressed.connect(hide)
	Events.card_edit_completed.connect(_on_card_edit_completed)
	
	for card: Node in cards.get_children():
		card.queue_free()
		
	card_tooltip_popup.hide_tooltip()
	card_upgrade_popup.hide_tooltip()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if card_tooltip_popup.visible:
			card_tooltip_popup.hide_tooltip()
		elif card_upgrade_popup.visible:
			card_upgrade_popup.hide_tooltip()
		else:
			hide()

func show_current_view(new_title: String, randomized: bool = false) -> void:
	for card: Node in cards.get_children():
		card.queue_free()
	
	card_tooltip_popup.hide_tooltip()
	card_upgrade_popup.hide_tooltip()
	title.text = new_title
	_update_view.call_deferred(randomized)

func set_upgrade_view_type(type: CardUpgradePopup.Type, cost: int) -> void:
	card_upgrade_popup.type = type
	if cost:
		card_upgrade_popup.upgrade_cost = cost

func _update_view(randomized: bool) -> void:
	if not card_pile:
		return
	
	var all_cards := card_pile.cards.duplicate()
	if randomized:
		RNG.array_shuffle(all_cards)
	
	for card: Card in all_cards:
		var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
		cards.add_child(new_card)
		new_card.card = card
		if type == Type.DISPLAY:
			new_card.tooltip_requested.connect(card_tooltip_popup.show_tooltip)
		elif type == Type.UPGRADE:
			new_card.tooltip_requested.connect(card_upgrade_popup.show_tooltip)
	
	show()

func _on_card_edit_completed() -> void:
	if type == Type.UPGRADE:
		hide()
		for card: Node in cards.get_children():
			card.queue_free()
