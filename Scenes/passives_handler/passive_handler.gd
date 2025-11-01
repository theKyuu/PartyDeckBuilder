class_name PassiveHandler
extends HBoxContainer

signal passives_activated(type: Passive.Type)

const PASSIVE_APPLY_INTERVAL := 0.5
const PASSIVE_UI = preload("res://Scenes/passives_handler/passive_ui.tscn")

@onready var passives_control: PassivesControl = $PassivesControl
@onready var passives: HBoxContainer = %Passives


func _ready() -> void:
	passives.child_exiting_tree.connect(_on_passives_child_exiting_tree)

func activate_passives_by_type(type: Passive.Type) -> void:
	if type == Passive.Type.EVENT_BASED:
		return
	
	var passive_queue: Array[PassiveUI] = _get_all_passive_ui_nodes().filter(
		func(passive_ui: PassiveUI):
			return passive_ui.passive.type == type
	)
	if passive_queue.is_empty():
		passives_activated.emit(type)
	
	var tween := create_tween()
	for passive_ui: PassiveUI in passive_queue:
		tween.tween_callback(passive_ui.passive.activate_passive.bind(passive_ui))
		tween.tween_interval(PASSIVE_APPLY_INTERVAL)
	
	tween.finished.connect(func(): passives_activated.emit(type))

func add_passives(passives_array: Array[Passive]) -> void:
	for passive: Passive in passives_array:
		add_passive(passive)

func add_passive(passive: Passive) -> void:
	if has_passive(passive.id):
		return
	
	var new_passive_ui := PASSIVE_UI.instantiate() as PassiveUI
	passives.add_child(new_passive_ui)
	new_passive_ui.passive = passive
	new_passive_ui.passive.initialize_passive(new_passive_ui)

func has_passive(id: String) -> bool:
	for passive_ui: PassiveUI in passives.get_children():
		if passive_ui.passive.id == id and is_instance_valid(passive_ui):
			return true
	
	return false

func get_all_passives() -> Array[Passive]:
	var passive_ui_nodes := _get_all_passive_ui_nodes()
	var passives_array: Array[Passive] = []
	
	for passive_ui: PassiveUI in passive_ui_nodes:
		passives_array.append(passive_ui.passive)
	
	return passives_array

func _get_all_passive_ui_nodes() -> Array[PassiveUI]:
	var all_passives: Array[PassiveUI] = []
	for passive_ui: PassiveUI in passives.get_children():
		all_passives.append(passive_ui)
	
	return all_passives

func _on_passives_child_exiting_tree(passive_ui: PassiveUI) -> void:
	if not passive_ui:
		return
	
	if passive_ui.passive:
		passive_ui.passive.deactivate_passive(passive_ui)
