class_name Player
extends Node2D

const WHITE_SPRITE_MATERIAL := preload("res://art/white_sprite_material.tres")

@export var stats: TeamStats : set = set_character_stats

@onready var team_sprite_container: TeamSpriteContainer = %TeamSpriteContainer
@onready var stats_ui: StatsUI = %StatsUI

func set_character_stats(value: TeamStats) -> void:
	stats = value
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
	
	update_player()

func update_player() -> void:
	if not stats is TeamStats:
		return
	if not is_inside_tree():
		await ready
	
	set_team_sprites()
	update_stats()

func set_team_sprites() -> void:
	for char: CharacterStats in stats.team:
		print("Adding char to team_sprites")
		team_sprite_container.team_sprites.append(char.art)
	team_sprite_container.set_team_layout()

func update_stats() -> void:
	stats_ui.update_stats(stats)

func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	
	team_sprite_container.material = WHITE_SPRITE_MATERIAL
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 24, 0.15))
	tween.tween_callback(stats.take_damage.bind(damage))
	tween.tween_interval(0.17)
	
	tween.finished.connect(
		func():
			team_sprite_container.material = null
			
			if stats.health <= 0:
				Events.player_died.emit()
				queue_free()
	)
