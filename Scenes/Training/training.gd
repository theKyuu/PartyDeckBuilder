extends Node2D

@onready var back_button = $GoBackButton

func _ready() -> void:
	back_button.pressed.connect(_on_go_back_pressed)

func _on_go_back_pressed() -> void:
	Events.event_node_exited.emit()
