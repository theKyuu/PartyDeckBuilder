class_name Run
extends Node

const BATTLE_SCENE := preload("res://Scenes/Battle/battle.tscn")
const BATTLE_REWARD_SCENE := preload("res://Scenes/UI/battle_reward.tscn")
const CHARACTER_PICKER_SCENE := preload("res://Scenes/UI/character_picker.tscn")

@export var run_startup: RunStartup

@onready var current_view: Node = $CurrentView
@onready var gold_ui: GoldUI = %GoldUI
@onready var deck_button: CardPileOpener = %DeckButton
@onready var deck_view: CardPileView = %DeckView
@onready var map: Map = $Map

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
	map.generate_new_map()
	map.unlock_row(0)

func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
		
	get_tree().paused = false
	var new_view := scene.instantiate()
	if "team_stats" in new_view: # Ugly solution only for Battle Scene atm
		new_view.team_stats = team
	current_view.add_child(new_view)
	map.hide_map()
	
	return new_view

func _show_map() -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
		map.show_map()
		map.unlock_next_rooms()

func _setup_event_connections() -> void:
	Events.battle_won.connect(_on_battle_won)
	Events.event_node_exited.connect(_show_map)
	Events.battle_reward_exited.connect(_show_map)
	Events.map_exited.connect(_on_map_exited)
	Events.character_added.connect(_on_character_added)
	
	map_button.pressed.connect(_show_map)
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
	MusicPlayer.stop()
	# Temporary reward data injection
	reward_scene.add_gold_reward(69)

func _on_map_exited(room: Room) -> void:
	match room.type:
		Room.Type.FIGHT:
			_change_view(BATTLE_SCENE)
		Room.Type.TRAINING:
			_change_view(BATTLE_SCENE)
		Room.Type.CHARACTER:
			_change_view(CHARACTER_PICKER_SCENE)
		Room.Type.EVENT:
			_change_view(BATTLE_SCENE)
		Room.Type.BOSS:
			_change_view(BATTLE_SCENE)

func _on_character_added(character: CharacterStats) -> void:
	team.team.append(character)
	team.set_combined_stats()
	_setup_top_bar()
	
