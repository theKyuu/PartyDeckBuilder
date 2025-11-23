class_name CharacterCardPileView
extends Control

const CHARACTER_CARDS_COMPONENT = preload("res://Scenes/UI/character_cards_component.tscn")
enum Type {DISPLAY, UPGRADE}

@export var team: TeamStats
@export var type: Type = Type.DISPLAY
@export var show_hero: bool = true

@onready var character_cards_container: VBoxContainer = %CharacterCardsContainer
@onready var back_button: Button = %BackButton
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopup
@onready var card_upgrade_popup: CardUpgradePopup = %CardUpgradePopup

func _ready() -> void:
	back_button.pressed.connect(hide)
	Events.card_upgrade_completed.connect(_on_card_upgrade_completed)

	card_tooltip_popup.hide_tooltip()
	card_upgrade_popup.hide_tooltip()

	for character_cards_component: Control in character_cards_container.get_children():
		character_cards_component.queue_free()
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if card_tooltip_popup.visible:
			card_tooltip_popup.hide_tooltip()
		elif card_upgrade_popup.visible:
			card_upgrade_popup.hide_tooltip()
		else:
			hide()

func set_upgrade_view_type(type: CardUpgradePopup.Type, cost: int) -> void:
	card_upgrade_popup.type = type
	if cost:
		card_upgrade_popup.upgrade_cost = cost


func list_cards() -> void:
	for character: CharacterStats in team.team:
		if show_hero or character.character_name != "Hero":
			var character_cards_component := CHARACTER_CARDS_COMPONENT.instantiate() as CharacterCardsComponent
			character_cards_component.character = character
			character_cards_component.card_tooltip_popup = card_tooltip_popup
			character_cards_component.card_upgrade_popup = card_upgrade_popup
			character_cards_container.add_child(character_cards_component)
			character_cards_component.list_cards(type)
	
	show()

func _on_card_upgrade_completed() -> void:
	if type == Type.UPGRADE:
		hide()
		for character_cards_component: Node in character_cards_container.get_children():
			character_cards_component.queue_free()
