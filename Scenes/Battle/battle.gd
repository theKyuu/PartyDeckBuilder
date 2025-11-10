class_name Battle
extends Node2D

@export var battle_stats: BattleStats
@export var team_stats: TeamStats
@export var music: AudioStream
@export var passives: PassiveHandler

@onready var battle_ui: BattleUI = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player

func _ready() -> void:
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)

func start_battle() -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	
	battle_ui.team_stats = team_stats
	player.stats = team_stats
	player_handler.passives = passives
	enemy_handler.setup_enemies(battle_stats)
	enemy_handler.reset_enemy_actions()
	
	passives.passives_activated.connect(_on_passives_activated)
	passives.activate_passives_by_type(Passive.Type.START_OF_COMBAT)

func _on_passives_activated(type: Passive.Type) -> void:
	match type:
		Passive.Type.START_OF_COMBAT:
			player_handler.start_battle(team_stats)
			battle_ui.initialize_card_pile_ui()
		Passive.Type.END_OF_COMBAT:
			Events.battle_over_screen_requested.emit("Victory!", BattleOverPanel.Type.WIN)

func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0 and is_instance_valid(passives):
		passives.activate_passives_by_type(Passive.Type.END_OF_COMBAT)

func _on_enemy_turn_ended() -> void:
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()

func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Game Over...", BattleOverPanel.Type.LOSE)
	SaveGame.delete_data()
