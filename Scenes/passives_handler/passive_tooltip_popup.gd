class_name PassiveTooltipPopup
extends Control

@onready var passive_icon: TextureRect = %PassiveIcon
@onready var passive_tooltip: RichTextLabel = %PassiveTooltip
@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(hide)
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		hide()

func show_tooltip(passive: Passive) -> void:
	passive_icon.texture = passive.icon
	passive_tooltip.text = passive.get_tooltip()
	show()

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		hide()
