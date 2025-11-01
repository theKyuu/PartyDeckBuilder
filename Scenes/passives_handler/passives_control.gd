class_name PassivesControl
extends Control

const PASSIVES_PER_PAGE := 5
const TWEEN_SCROLL_DURATION := 0.2

@export var left_button: TextureButton
@export var right_button: TextureButton

@onready var passives: HBoxContainer = %Passives
@onready var page_width = self.custom_minimum_size.x

var no_of_passives := 0
var current_page := 1
var max_page := 0
var tween: Tween
var passives_start_position: Vector2


func _ready() -> void:
	left_button.pressed.connect(_on_left_button_pressed)
	right_button.pressed.connect(_on_right_button_pressed)
	passives_start_position = passives.position
	
	for passive_ui: PassiveUI in passives.get_children():
		passive_ui.free()
	
	passives.child_order_changed.connect(_on_passives_child_order_changed)
	_on_passives_child_order_changed()

func update() -> void:
	if not is_instance_valid(left_button) or not is_instance_valid(right_button):
		return # Safety check to prevent error in this method when game is closed
	
	no_of_passives = passives.get_child_count()
	max_page = ceili(no_of_passives / float(PASSIVES_PER_PAGE))
	
	if no_of_passives > 5:
		left_button.show()
		right_button.show()
	else:
		left_button.hide()
		right_button.hide()
		passives.position = passives_start_position
		current_page = 1
	
	left_button.disabled = current_page <= 1
	right_button.disabled = current_page >= max_page

func _tween_to(x_position: float) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(passives, "position:x", x_position, TWEEN_SCROLL_DURATION)

func _on_left_button_pressed() -> void:
	if current_page > 1:
		current_page -= 1
		update()
		_tween_to(passives.position.x + page_width)

func _on_right_button_pressed() -> void:
	if current_page < max_page:
		current_page += 1
		update()
		_tween_to(passives.position.x - page_width)

func _on_passives_child_order_changed() -> void:
	update()
