class_name Run
extends Node

const BATTLE_SCENE := preload("res://Scenes/Battle/battle.tscn")
const BATTLE_REWARD_SCENE := preload("res://Scenes/UI/battle_reward.tscn")
const CHARACTER_PICKER_SCENE := preload("res://Scenes/UI/character_picker.tscn")
const TRAINING_SCENE := preload("res://Scenes/Training/training.tscn")
const EVENT_SCENE := preload("res://Scenes/Event/event.tscn")
const WIN_SCREEN_SCENE := preload("res://Scenes/Win_screen/win_screen.tscn")
const MAIN_MENU_PATH := "res://Scenes/UI/main_menu.tscn"

@export var run_startup: RunStartup

@onready var current_view: Node = $CurrentView
@onready var health_ui: HealthUI = %HealthUI
@onready var gold_ui: GoldUI = %GoldUI
@onready var passive_handler: PassiveHandler = %PassiveHandler
@onready var passive_tooltip: PassiveTooltipPopup = %PassiveTooltipPopup
@onready var deck_button: CardPileOpener = %DeckButton
@onready var deck_view: CharacterCardPileView = %DeckView
@onready var map: Map = $Map
@onready var pause_menu: PauseMenu = $PauseMenu

# Debug buttons
@onready var map_button: Button = %MapButton
@onready var battle_button: Button = %BattleButton
@onready var character_pick_button: Button = %CharacterPickButton
@onready var training_button: Button = %TrainingButton
@onready var event_button: Button = %EventButton

var stats: RunStats
var team: TeamStats
var save_data: SaveGame

func _ready() -> void:
	if not run_startup:
		return
	
	pause_menu.save_and_quit.connect(
		func():
			MusicPlayer.stop()
			get_tree().change_scene_to_file(MAIN_MENU_PATH)
	)
	
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			team = run_startup.player_team.create_instance()
			if is_instance_of(run_startup.passive, Passive):
				passive_handler.add_passive(run_startup.passive)
			_start_run()
		RunStartup.Type.CONTINUED_RUN:
			_load_run()
	

func _start_run() -> void:
	stats = RunStats.new()
	
	_setup_event_connections()
	_setup_top_bar()
	map.generate_new_map()
	map.unlock_row(0)
	
	save_data = SaveGame.new()
	_save_run(true)

func _save_run(was_on_map: bool) -> void:
	save_data.rng_seed = RNG.instance.seed
	save_data.rng_state = RNG.instance.state
	save_data.run_stats = stats
	save_data.team_stats = team
	save_data.current_deck = team.deck
	save_data.current_health = team.health
	save_data.current_passives = passive_handler.get_all_passives()
	save_data.last_room = map.last_room
	save_data.map_data = map.map_data.duplicate()
	save_data.rooms_entered = map.rooms_entered
	save_data.was_on_map = was_on_map
	save_data.save_data()

func _load_run() -> void:
	save_data = SaveGame.load_data()
	assert(save_data, "Couldn't load last save!")
	
	RNG.set_from_save_data(save_data.rng_seed, save_data.rng_state)
	stats = save_data.run_stats
	team = save_data.team_stats
	team.deck = save_data.current_deck
	team.health = save_data.current_health
	passive_handler.add_passives(save_data.current_passives)
	_setup_top_bar()
	_setup_event_connections()
	
	map.load_map(save_data.map_data, save_data.rooms_entered, save_data.last_room)
	if save_data.last_room and not save_data.was_on_map:
		_on_map_exited(save_data.last_room)

func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
		
	get_tree().paused = false
	var new_view := scene.instantiate()
	current_view.add_child(new_view)
	map.hide_map()
	
	return new_view

func _show_map() -> void:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
		
	map.show_map()
	map.unlock_next_rooms()
	_save_run(true)

func _setup_event_connections() -> void:
	Events.battle_won.connect(_on_battle_won)
	Events.event_node_exited.connect(_show_map)
	Events.battle_reward_exited.connect(_show_map)
	Events.map_exited.connect(_on_map_exited)
	Events.character_added.connect(_on_character_added)
	Events.card_upgraded.connect(_on_card_upgraded)
	Events.card_removed.connect(_on_card_removed)
	
	map_button.pressed.connect(_show_map)
	battle_button.pressed.connect(_change_view.bind(BATTLE_SCENE))
	character_pick_button.pressed.connect(_change_view.bind(CHARACTER_PICKER_SCENE))
	training_button.pressed.connect(_show_training_room)
	event_button.pressed.connect(_change_view.bind(EVENT_SCENE))

func _setup_top_bar():
	team.stats_changed.connect(health_ui.update_stats.bind(team))
	health_ui.update_stats(team)
	gold_ui.run_stats = stats
	Events.passive_tooltip_requested.connect(passive_tooltip.show_tooltip)
	deck_button.card_pile = team.deck
	deck_view.team = team
	deck_button.pressed.connect(deck_view.list_cards)

func _show_training_room() -> void:
	var training_scene := _change_view(TRAINING_SCENE) as Training
	training_scene.team = team
	training_scene.stats = stats
	pause_menu.temporary_view = training_scene.character_card_view
	training_scene.setup_training_options()
	

func _show_regular_battle_rewards() -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.team_stats = team
	MusicPlayer.stop()
	reward_scene.add_gold_reward(map.last_room.battle_stats.roll_gold_reward())

func _on_battle_room_entered(room: Room) -> void:
	var battle_scene: Battle = _change_view(BATTLE_SCENE) as Battle
	battle_scene.team_stats = team
	battle_scene.battle_stats = room.battle_stats
	battle_scene.passives = passive_handler
	battle_scene.start_battle()

func _on_battle_won() -> void:
	if map.rooms_entered == MapGenerator.ROWS:
		MusicPlayer.stop()
		var win_screen := _change_view(WIN_SCREEN_SCENE) as WinScreen
		win_screen.team_stats = team
		SaveGame.delete_data()
	else:
		_show_regular_battle_rewards()

func _on_map_exited(room: Room) -> void:
	_save_run(false)
	
	match room.type:
		Room.Type.FIGHT:
			_on_battle_room_entered(room)
		Room.Type.TRAINING:
			_show_training_room()
		Room.Type.CHARACTER:
			_change_view(CHARACTER_PICKER_SCENE)
		Room.Type.EVENT:
			_change_view(EVENT_SCENE)
		Room.Type.BOSS:
			_on_battle_room_entered(room)

func _on_character_added(character: CharacterStats) -> void:
	team.team.append(character)
	team.set_combined_stats()
	team.health += character.max_health
	if is_instance_of(character.passive, Passive):
		passive_handler.add_passive(character.passive)
	
	_setup_top_bar()
	

# TODO: Make upgrades and removals char specific (or else Hero might eat them)
func _on_card_upgraded(origin_card: Card, type: CardUpgradePopup.Type, cost: int) -> void:
	for character: CharacterStats in team.team:
		for card: Card in character.deck.cards:
			if card == origin_card:
				character.deck.replace_card(origin_card, origin_card.upgrades_into)
				if type == CardUpgradePopup.Type.PAID:
					stats.gold = stats.gold - cost
					stats.times_bought_upgrades += 1
				break
	team.set_combined_stats()
	deck_button.card_pile = team.deck
	Events.card_upgrade_completed.emit()
	

func _on_card_removed(card_to_remove: Card, type: CardRemovalPopup.Type, cost: int) -> void:
	for character: CharacterStats in team.team:
		for card: Card in character.deck.cards:
			if card == card_to_remove:
				character.deck.remove_card(card_to_remove)
				if type == CardRemovalPopup.Type.PAID:
					stats.gold = stats.gold - cost
					stats.times_bought_removal += 1
				break
	team.set_combined_stats()
	deck_button.card_pile = team.deck
	Events.card_removal_completed.emit()
