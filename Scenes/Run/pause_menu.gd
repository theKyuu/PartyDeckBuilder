class_name PauseMenu
extends CanvasLayer

signal  save_and_quit

@onready var back_to_game_button: Button = %BackToGameButton
@onready var save_and_quit_button: Button = %SaveAndQuitButton
@onready var deck_view: CharacterCardPileView = %DeckView
@onready var passive_tooltip_popup: PassiveTooltipPopup = %PassiveTooltipPopup

func _ready() -> void:
	back_to_game_button.pressed.connect(_unpause)
	save_and_quit_button.pressed.connect(_on_save_and_quit_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			_unpause()
		elif not deck_view.visible == true and not passive_tooltip_popup.visible == true:
			_pause()

func _pause() -> void:
	show()
	get_tree().paused = true

func _unpause() -> void:
	hide()
	get_tree().paused = false

func _on_save_and_quit_button_pressed() -> void:
	get_tree().paused = false
	save_and_quit.emit()
