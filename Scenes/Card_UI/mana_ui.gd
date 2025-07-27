class_name ManaUI
extends Panel

@export var team_stats: TeamStats : set = _set_team_stats

@onready var mana_label: Label = $ManaLabel


func _set_team_stats(value: TeamStats) -> void:
	team_stats = value
	
	if not team_stats.stats_changed.is_connected(_on_stats_changed):
		team_stats.stats_changed.connect(_on_stats_changed)
	
	if not is_node_ready():
		await ready
	
	_on_stats_changed()

func _on_stats_changed() -> void:
	mana_label.text = "%s/%s" % [team_stats.mana, team_stats.max_mana]
