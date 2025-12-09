extends Node

# Card-related events
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_aim_started(card_ui: CardUI)
signal card_aim_ended(card_ui: CardUI)
signal card_played(card: Card)
signal card_tooltip_requested(card: Card)
signal tooltip_hide_requested

# Player-related events
signal player_hand_drawn
signal player_hand_discarded
signal player_turn_ended
signal player_hit
signal player_died

# Enemy-related events
signal enemy_action_completed(enemy: Enemy)
signal enemy_turn_ended
signal enemy_died(enemy: Enemy)

# Battle-related events
signal battle_over_screen_requested(text:String, type: BattleOverPanel.Type)
signal battle_won
signal status_tooltip_requested(statuses: Array[Status])

# Battle reward-related events
signal battle_reward_exited

# Map-related events
signal map_exited(room: Room)
signal event_node_exited

# Team-related events
signal character_added(character: CharacterStats)
signal card_upgraded(card: Card, card_owner: CharacterStats, type: CardUpgradePopup.Type, cost: int)
signal card_removed(card: Card, card_owner: CharacterStats, type: CardRemovalPopup.Type, cost: int)
signal card_copy_initiated(card: Card)
signal card_replaced(origin_card: Card, new_card: Card, card_owner: CharacterStats, type: CardCopyPopup.Type, cost: int)
signal card_edit_completed()

# Passive-related events
signal passive_tooltip_requested(passive: Passive)
