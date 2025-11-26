class_name CardRemovalPopup
extends Control

const CARD_MENU_UI_SCENE := preload("res://Scenes/UI/card_menu_ui.tscn")

enum Type {EVENT, PAID}

@export var type := Type.EVENT
@export var removal_cost: int = 0

@onready var card_tooltip: CenterContainer = %CardTooltip
@onready var card_description: RichTextLabel = %CardDescription

var card_to_remove: Card
var card_owner: CharacterStats

func _ready() -> void:
	card_to_remove = null
	
	for card: CardMenuUI in card_tooltip.get_children():
		card.queue_free()

func show_tooltip(card: Card, character: CharacterStats) -> void:
	card_to_remove = card
	card_owner = character
	
	var card_ui := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
	card_tooltip.add_child(card_ui)
	card_ui.card = card
	card_ui.tooltip_requested.connect(hide_tooltip.unbind(2))
	card_description.text = card.get_default_tooltip()

	show()

func hide_tooltip() -> void:
	if not visible:
		return
	
	for card: CardMenuUI in card_tooltip.get_children():
		card.queue_free()

	card_to_remove = null
	hide()

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		hide_tooltip()


func _on_remove_button_pressed() -> void:
	if not card_to_remove:
		return

	Events.card_removed.emit(card_to_remove, card_owner, type, removal_cost)
	hide_tooltip()
