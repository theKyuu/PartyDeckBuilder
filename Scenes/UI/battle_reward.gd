class_name BattleReward
extends Control

const REWARD_BUTTON = preload("res://Scenes/UI/reward_button.tscn")
const GOLD_ICON := preload("res://art/gold.png")
const GOLD_TEXT := "%s gold"
const COPY_TEXT := "Copy a card"

@export var run_stats: RunStats
@export var team_stats: TeamStats

@onready var rewards: VBoxContainer = %Rewards
@onready var character_card_view: CharacterCardPileView = %CharacterCardView

var copy_button: Button

func _ready() -> void:
	Events.card_edit_completed.connect(_on_copy_completed)
	for node: Node in rewards.get_children():
		node.queue_free()


func add_gold_reward(amount: int) -> void:
	var gold_reward := REWARD_BUTTON.instantiate() as RewardButton
	gold_reward.reward_icon = GOLD_ICON
	gold_reward.reward_text = GOLD_TEXT % amount
	gold_reward.pressed.connect(_on_gold_reward_taken.bind(amount))
	rewards.add_child.call_deferred(gold_reward)

func add_copy_reward() -> void:
	copy_button = Button.new()
	copy_button.text = COPY_TEXT
	copy_button.pressed.connect(_on_copy_reward_taken)
	rewards.add_child.call_deferred(copy_button)

func _on_gold_reward_taken(amount: int) -> void:
	if not run_stats:
		return
	
	run_stats.gold += amount

func _on_copy_reward_taken() -> void:
	character_card_view.team = team_stats
	character_card_view.show_hero = false
	character_card_view.type = CharacterCardPileView.Type.COPY
	character_card_view.set_copy_view_type(CardCopyPopup.Type.EVENT, 0)
	character_card_view.title_text = "Select a card to copy:"
	character_card_view.list_cards()

func _on_copy_completed() -> void:
	copy_button.queue_free()

func _on_continue_button_pressed() -> void:
	Events.battle_reward_exited.emit()
