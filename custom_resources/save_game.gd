class_name SaveGame
extends Resource

const SAVE_PATH := "user://savegame.tres"

@export var run_stats: RunStats
@export var team_stats: TeamStats
@export var current_deck: CardPile
@export var current_health: int
@export var current_passives: Array[Passive]
@export var map_data: Array[Array]
@export var last_room: Room
@export var rooms_entered: int
@export var was_on_map: bool

func save_data() -> void:
	var err := ResourceSaver.save(self, SAVE_PATH)
	assert(err == OK, "Couldn't save game!")

static func load_data() -> SaveGame:
	if FileAccess.file_exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH) as SaveGame
	
	return null

static func delete_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
