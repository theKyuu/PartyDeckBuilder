class_name Run
extends Node

const BATTLE_SCENE := preload("res://Scenes/Battle/battle.tscn")
const CHARACTER_PICKER_SCENE := preload("res://Scenes/UI/character_picker.tscn")
const MAP_SCENE := preload("res://Scenes/UI/Map/map.tscn")

@export var run_startup: RunStartup

@onready var current_view: Node = $CurrentView
@onready var map_button: Button = %MapButton
@onready var battle_button: Button = %BattleButton
@onready var character_pick_button: Button = %CharacterPickButton

var team: TeamStats

func _ready() -> void:
	if not run_startup:
		return
	
	print("Hi")
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			team = run_startup.player_team.create_instance()
			_start_run()
		RunStartup.Type.CONTINUED_RUN:
			print("TODO: load previous run")
	

func _start_run() -> void:
	_setup_event_connections()
	print("TODO: Generate map")

func _change_view(scene: PackedScene) -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	
	get_tree().paused = false
	var new_view := scene.instantiate()
	current_view.add_child(new_view)

func _setup_event_connections() -> void:
	Events.battle_won.connect(_change_view.bind(MAP_SCENE))
	Events.map_exited.connect(_on_map_exited)
	
	map_button.pressed.connect(_change_view.bind(MAP_SCENE))
	battle_button.pressed.connect(_change_view.bind(BATTLE_SCENE))
	character_pick_button.pressed.connect(_change_view.bind(CHARACTER_PICKER_SCENE))

func _on_map_exited() -> void:
	print("TODO: From the MAP, change view based on room type")
