class_name CardCopyPopup
extends Control

const CARD_MENU_UI_SCENE := preload("res://Scenes/UI/card_menu_ui.tscn")

enum Type {EVENT, PAID}
enum ViewState {COPY, REPLACE}

@export var type := Type.EVENT
@export var view_state := ViewState.COPY: set = set_view_state
@export var copy_cost: int = 0

@onready var card_tooltip: CenterContainer = %CardTooltip
@onready var card_description: RichTextLabel = %CardDescription
@onready var replace_arrow: TextureRect = %ReplaceArrow
@onready var replace_card_container: VBoxContainer = %ReplaceCardContainer
@onready var replace_card_description: RichTextLabel = %ReplaceCardDescription

@onready var copy_button: Button = %CopyButton
@onready var replace_button: Button = %ReplaceButton

var focus_card: Card
var focus_character: CharacterStats
var card_to_copy: Card

func _ready() -> void:
	focus_card = null
	
	for card: CardMenuUI in card_tooltip.get_children():
		card.queue_free()

func set_view_state(new_state: ViewState) -> void:
	view_state = new_state
	if view_state == ViewState.COPY:
		copy_button.show()
		replace_button.hide()
		replace_arrow.hide()
		replace_card_container.hide()
	elif view_state == ViewState.REPLACE:
		replace_button.show()
		copy_button.hide()
		replace_arrow.show()
		replace_card_container.show()

func show_tooltip(card: Card, character: CharacterStats) -> void:
	focus_card = card
	focus_character = character
	
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

	focus_card = null
	hide()

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		hide_tooltip()


func _on_copy_button_pressed() -> void:
	if not focus_card:
		return
	
	card_to_copy = focus_card
	Events.card_copy_initiated.emit(card_to_copy)

	hide_tooltip()
