class_name CardMenuUI
extends CenterContainer

signal tooltip_requested(card: Card, card_owner: CharacterStats)

const BASE_STYLEBOX := preload("res://Scenes/Card_UI/card_base_stylebox.tres")
const HOVER_STYLEBOX := preload("res://Scenes/Card_UI/card_hover_stylebox.tres")

@export var card: Card : set = set_card
@export var card_owner: CharacterStats

@onready var panel: Panel = $Visuals/Panel
@onready var cost: Label = $Visuals/Cost
@onready var icon: TextureRect = $Visuals/Icon


func _on_visuals_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		tooltip_requested.emit(card, card_owner)

func _on_visuals_mouse_entered() -> void:
	panel.set("theme_override_styles/panel", HOVER_STYLEBOX)

func _on_visuals_mouse_exited() -> void:
	panel.set("theme_override_styles/panel", BASE_STYLEBOX)

func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	cost.text = str(card.cost)
	icon.texture = card.icon
