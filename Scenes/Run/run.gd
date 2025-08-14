class_name Run
extends Node

const BATTLE_SCENE := preload("res://Scenes/Battle/battle.tscn")
const BATTLE_REWARD_SCENE := preload("res://Scenes/UI/battle_reward.tscn")
const CHARACTER_PICKER_SCENE := preload("res://Scenes/UI/character_picker.tscn")
const MAP_SCENE := preload("res://Scenes/UI/Map/map.tscn")

@export var run_startup: RunStartup

@onready var current_view: Node = $CurrentView
@onready var gold_ui: GoldUI = %GoldUI
@onready var deck_button: CardPileOpener = %DeckButton
@onready var deck_view: CardPileView = %DeckView

# Debug buttons
@onready var map_button: Button = %MapButton
@onready var battle_button: Button = %BattleButton
@onready var character_pick_button: Button = %CharacterPickButton

var stats: RunStats
var team: TeamStats

func _ready() -> void:
	if not run_startup:
		return

	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			team = run_startup.player_team.create_instance()
			_start_run()
		RunStartup.Type.CONTINUED_RUN:
			print("TODO: load previous run")
	

func _start_run() -> void:
	stats = RunStats.new()
	
	_setup_event_connections()
	_setup_top_bar()
	print("TODO: Generate map")

func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	
	get_tree().paused = false
	var new_view := scene.instantiate()
	if "team_stats" in new_view:
		new_view.team_stats = team
	
	current_view.add_child(new_view)
	
	return new_view

func _setup_event_connections() -> void:
	Events.battle_won.connect(_on_battle_won)
	Events.event_node_exited.connect(_change_view.bind(MAP_SCENE))
	Events.battle_reward_exited.connect(_change_view.bind(MAP_SCENE))
	Events.map_exited.connect(_on_map_exited)
	Events.team_updated.connect(_on_team_updated)
	
	map_button.pressed.connect(_change_view.bind(MAP_SCENE))
	battle_button.pressed.connect(_change_view.bind(BATTLE_SCENE))
	character_pick_button.pressed.connect(_change_view.bind(CHARACTER_PICKER_SCENE))

func _setup_top_bar():
	gold_ui.run_stats = stats
	deck_button.card_pile = team.deck
	deck_view.card_pile = team.deck
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))

func _on_battle_won() -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.team_stats = team
	
	# Temporary reward data injection
	reward_scene.add_gold_reward(69)

func _on_map_exited() -> void:
	print("TODO: From the MAP, change view based on room type")

func _on_team_updated(new_team: TeamStats) -> void:
	team = new_team
