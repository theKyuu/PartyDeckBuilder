class_name CardUpgradePopup
extends Control

const CARD_MENU_UI_SCENE := preload("res://Scenes/UI/card_menu_ui.tscn")

enum Type {EVENT, PAID}

@export var type := Type.EVENT
@export var upgrade_cost: int = 0

@onready var tooltip_origin_card: CenterContainer = %TooltipOriginCard
@onready var origin_card_description: RichTextLabel = %OriginCardDescription
@onready var tooltip_upgrade_card: CenterContainer = %TooltipUpgradeCard
@onready var upgrade_card_description: RichTextLabel = %UpgradeCardDescription

var card_to_upgrade: Card
var card_owner: CharacterStats

func _ready() -> void:
	card_to_upgrade = null
	
	for card: CardMenuUI in tooltip_origin_card.get_children():
		card.queue_free()
	for card: CardMenuUI in tooltip_upgrade_card.get_children():
		card.queue_free()

func show_tooltip(origin_card: Card, character: CharacterStats) -> void:
	card_to_upgrade = origin_card
	card_owner = character
	
	var upgrade_card := origin_card.upgrades_into as Card
	if not upgrade_card:
		return
	
	var origin_card_ui := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
	tooltip_origin_card.add_child(origin_card_ui)
	origin_card_ui.card = origin_card
	origin_card_ui.tooltip_requested.connect(hide_tooltip.unbind(2))
	origin_card_description.text = origin_card.get_default_tooltip()
	var upgrade_card_ui := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
	tooltip_upgrade_card.add_child(upgrade_card_ui)
	upgrade_card_ui.card = upgrade_card
	upgrade_card_ui.tooltip_requested.connect(hide_tooltip.unbind(2))
	upgrade_card_description.text = upgrade_card.get_default_tooltip()
	show()


func hide_tooltip() -> void:
	if not visible:
		return
	
	for card: CardMenuUI in tooltip_origin_card.get_children():
		card.queue_free()
	for card: CardMenuUI in tooltip_upgrade_card.get_children():
		card.queue_free()
	
	card_to_upgrade = null
	hide()


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		hide_tooltip()

func _on_upgrade_button_pressed() -> void:
	if not card_to_upgrade:
		return

	Events.card_upgraded.emit(card_to_upgrade, card_owner, type, upgrade_cost)
	hide_tooltip()
